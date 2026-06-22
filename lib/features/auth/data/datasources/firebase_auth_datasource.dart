import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/constants/firebase_constants.dart';

/// Wraps Firebase Auth and the Google/Apple credential flows. All provider/SDK
/// types stay inside the data layer.
class FirebaseAuthDatasource {
  FirebaseAuthDatasource({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFunctions? functions,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _google = googleSignIn ?? GoogleSignIn.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: kCloudFunctionsRegion);

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  final FirebaseFunctions _functions;
  bool _googleReady = false;

  // Public web OAuth client ID (from google-services.json). Not a secret — it
  // ships in the app; required as serverClientId on Android so the returned
  // idToken is usable by Firebase.
  static const _googleServerClientId =
      '1048215039705-r83mtm91on5hpj2ko5nrur4anv0ld56t.apps.googleusercontent.com';

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signInWithGoogle() async {
    final credential = await _googleCredential();
    final result = await _auth.signInWithCredential(credential);
    return result.user!;
  }

  Future<User> signInWithApple() async {
    final apple = await _appleCredential();
    final result = await _auth.signInWithCredential(apple.credential);
    // Apple only returns the name on the first authorization; persist it once.
    if (apple.displayName != null &&
        (result.user!.displayName == null ||
            result.user!.displayName!.isEmpty)) {
      await result.user!.updateDisplayName(apple.displayName);
    }
    return result.user!;
  }

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    if (_auth.currentUser == null) return;
    // The Cloud Function cleans up Firestore and deletes the auth user with
    // admin privileges — no client reauthentication required.
    await _functions.httpsCallable('deleteAccount').call();
    await _google.signOut();
    await _auth.signOut();
  }

  Future<AuthCredential> _googleCredential() async {
    await _ensureGoogleInitialized();
    final account = await _google.authenticate(scopeHint: const ['email']);
    return GoogleAuthProvider.credential(idToken: account.authentication.idToken);
  }

  Future<({AuthCredential credential, String? displayName})>
  _appleCredential() async {
    final rawNonce = _generateNonce();
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: _sha256(rawNonce),
    );
    final credential = OAuthProvider('apple.com').credential(
      idToken: apple.identityToken,
      rawNonce: rawNonce,
      accessToken: apple.authorizationCode,
    );
    final name = [apple.givenName, apple.familyName]
        .where((e) => e != null && e.isNotEmpty)
        .join(' ');
    return (credential: credential, displayName: name.isEmpty ? null : name);
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleReady) return;
    await _google.initialize(
      serverClientId: Platform.isAndroid ? _googleServerClientId : null,
    );
    _googleReady = true;
  }

  String _generateNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  String _sha256(String input) => sha256.convert(utf8.encode(input)).toString();
}
