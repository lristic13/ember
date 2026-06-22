import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../viewmodels/handle_setup_view_model.dart';
import '../widgets/ember_primary_button.dart';
import '../widgets/handle_field.dart';
import '../widgets/immutable_handle_note.dart';

class HandleSetupScreen extends ConsumerStatefulWidget {
  const HandleSetupScreen({super.key});

  @override
  ConsumerState<HandleSetupScreen> createState() => _HandleSetupScreenState();
}

class _HandleSetupScreenState extends ConsumerState<HandleSetupScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _messageColor(HandleStatus status, EmberPalette palette) {
    switch (status) {
      case HandleStatus.available:
        return EmberSemantic.good;
      case HandleStatus.taken:
      case HandleStatus.invalid:
        return EmberSemantic.dangerSoft;
      case HandleStatus.checking:
      case HandleStatus.idle:
        return palette.dim;
    }
  }

  Future<void> _onContinue() async {
    // On success the handle is set; the router redirect moves us off this
    // screen once the auth-state stream reflects it.
    await ref.read(handleSetupViewModelProvider.notifier).claim();
  }

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final state = ref.watch(handleSetupViewModelProvider);
    final viewModel = ref.read(handleSetupViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'STEP 2 OF 2',
                style: EmberText.mono(10, color: EmberAccent.neon),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: 'Claim your handle',
                  children: [
                    TextSpan(
                      text: '.',
                      style: EmberText.display(
                        25,
                        color: EmberAccent.neon,
                        letterSpacingEm: -0.03,
                      ),
                    ),
                  ],
                ),
                style: EmberText.display(
                  25,
                  color: palette.text,
                  letterSpacingEm: -0.03,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is how friends find you on ember.',
                style: EmberText.display(
                  13,
                  color: palette.dim,
                  weight: FontWeight.w400,
                  letterSpacingEm: -0.01,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              HandleField(
                controller: _controller,
                status: state.status,
                onChanged: viewModel.onChanged,
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 16,
                child: Text(
                  state.message ?? '',
                  style: EmberText.display(
                    11,
                    color: _messageColor(state.status, palette),
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'letters, numbers, _ · 3–20',
                style: EmberText.mono(9, color: palette.dimmer),
              ),
              const SizedBox(height: 16),
              const ImmutableHandleNote(),
              const Spacer(),
              if (state.error != null) ...[
                Text(
                  state.error!,
                  style: EmberText.display(
                    11,
                    color: EmberSemantic.dangerSoft,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              EmberPrimaryButton(
                label: 'Continue',
                arrow: true,
                enabled: state.canContinue,
                loading: state.submitting,
                onPressed: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

