import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

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
        if (state is AuthOtpVerified) {
          context.go(RouteNames.resetPassword);
        } else if (state is AuthPasswordResetEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Código reenviado. Revisa tu correo.')),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
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
                                _OtpBox(char: char, isCurrent: isCurrent),
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
                    final ready = _otp.length == _length;
                    return ElevatedButton(
                      onPressed:
                          (state is AuthLoading || !ready) ? null : _submit,
                      child: state is AuthLoading
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
                        return TextButton(
                          onPressed:
                              state is AuthLoading ? null : _resend,
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

class _OtpBox extends StatelessWidget {
  final String char;
  final bool isCurrent;

  const _OtpBox({required this.char, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 36,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: char.isNotEmpty
            ? AppColors.onPrimaryContainer
            : Colors.transparent,
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }
}
