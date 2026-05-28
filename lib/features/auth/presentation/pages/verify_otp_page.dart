import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../auth.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;
  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  static const int _length = 8;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _otp => _controller.text;

  void _submit() {
    if (_otp.length == _length) {
      context.read<AuthCubit>().verifyResetOtp(
            email: widget.email,
            token: _otp,
          );
    }
  }

  void _resend() {
    context.read<AuthCubit>().forgotPassword(email: widget.email);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeMap(
          otpVerified: (_) => context.go(RouteNames.resetPassword),
          passwordResetEmailSent: (_) =>
              ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código reenviado. Revisa tu correo.')),
          ),
          error: (s) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.message), backgroundColor: AppColors.error),
          ),
          orElse: () {},
        );
      },
      child: Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.onPrimaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verifica tu código',
                  style: theme.textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Ingresa el código de $_length dígitos que enviamos a',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // OTP input: un TextField invisible + cajas visuales encima
                SizedBox(
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cajas visuales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_length, (i) {
                          final char = i < _controller.text.length
                              ? _controller.text[i]
                              : '';
                          final isCurrent = _focusNode.hasFocus &&
                              i == _controller.text.length;
                          return Padding(
                            padding: EdgeInsets.only(
                                right: i < _length - 1 ? 8 : 0),
                            child:
                                OtpBox(char: char, isCurrent: isCurrent),
                          );
                        }),
                      ),
                      // TextField transparente que captura todo el input
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.0,
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(_length),
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state.maybeMap(
                      loading: (_) => true,
                      orElse: () => false,
                    );
                    final ready = _otp.length == _length;
                    return ElevatedButton(
                      onPressed: (isLoading || !ready) ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verificar código'),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No recibiste el código?',
                        style: theme.textTheme.bodyMedium),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state.maybeMap(
                          loading: (_) => true,
                          orElse: () => false,
                        );
                        return TextButton(
                          onPressed: isLoading ? null : _resend,
                          child: const Text('Reenviar'),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'El código expira en 10 minutos',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

