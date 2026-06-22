import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../../../../shared/widgets/ember_wordmark.dart';
import '../../../../shared/widgets/glowing_brand_dot.dart';
import '../viewmodels/sign_in_view_model.dart';
import '../widgets/auth_button.dart';
import '../widgets/sign_in_error_card.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final state = ref.watch(signInViewModelProvider);
    final viewModel = ref.read(signInViewModelProvider.notifier);

    final googleLoading = state.loading == AuthProviderKind.google;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 28),
          child: Column(
            children: [
              const Center(child: EmberWordmark(size: 18)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const GlowingBrandDot(size: 48),
                    const SizedBox(height: 26),
                    Text.rich(
                      TextSpan(
                        text: 'Just show up',
                        children: [
                          TextSpan(
                            text: '.',
                            style: EmberText.display(
                              30,
                              color: EmberAccent.neon,
                              letterSpacingEm: -0.04,
                              height: 1.04,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: EmberText.display(
                        30,
                        color: palette.text,
                        letterSpacingEm: -0.04,
                        height: 1.04,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Small daily sparks build lasting flames.',
                      textAlign: TextAlign.center,
                      style: EmberText.display(
                        13,
                        color: palette.dim,
                        weight: FontWeight.w400,
                        letterSpacingEm: -0.01,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.error != null) ...[
                SignInErrorCard(message: state.error),
                const SizedBox(height: 11),
              ],
              // Apple sign-in temporarily removed — re-add AuthButton.apple
              // here once the Services ID / Xcode capability setup is done.
              AuthButton.google(
                label: 'Continue with Google',
                loading: googleLoading,
                onPressed: viewModel.signInWithGoogle,
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  text: 'By continuing you agree to our ',
                  children: [
                    TextSpan(
                      text: 'Terms',
                      style: EmberText.display(
                        9,
                        color: palette.dim,
                        weight: FontWeight.w400,
                      ),
                    ),
                    const TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: EmberText.display(
                        9,
                        color: palette.dim,
                        weight: FontWeight.w400,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: EmberText.display(
                  9,
                  color: palette.dimmer,
                  weight: FontWeight.w400,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
