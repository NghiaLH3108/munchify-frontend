import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../admin/presentation/pages/admin_shell_screen.dart';
import '../../../main/presentation/screens/main_app_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmittedEvent(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: ColorPalette.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            AppToast.error(state.message, context: context);
          } else if (state is Authenticated) {
            if (state.user.isAdmin) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminShellScreen(initialTab: 'dashboard'),
                ),
                (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainAppScreen(),
                ),
                (route) => false,
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                decoration: BoxDecoration(
                  color: ColorPalette.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDesktop
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                  border: isDesktop
                      ? Border.all(color: ColorPalette.divider.withValues(alpha: 0.5))
                      : null,
                ),
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo & App Name
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                ColorPalette.appetizingOrange,
                                ColorPalette.amber,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: ColorPalette.appetizingOrange
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Munchify POS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Đăng nhập để bắt đầu phiên làm việc',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorPalette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Username Field
                      const Text(
                        'Tên đăng nhập',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên đăng nhập',
                          hintStyle: const TextStyle(
                            color: ColorPalette.textHint,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: ColorPalette.textSecondary,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: ColorPalette.surfaceVariant.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: ColorPalette.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: ColorPalette.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: ColorPalette.borderFocused,
                              width: 1.8,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên đăng nhập';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mật khẩu',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ColorPalette.appetizingOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu',
                          hintStyle: const TextStyle(
                            color: ColorPalette.textHint,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: ColorPalette.textSecondary,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: ColorPalette.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: ColorPalette.surfaceVariant.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: ColorPalette.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: ColorPalette.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: ColorPalette.borderFocused,
                              width: 1.8,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _onLoginPressed(),
                      ),
                      const SizedBox(height: 28),

                      // Login Button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.appetizingOrange,
                            foregroundColor: ColorPalette.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Munchify F&B Solutions • Phiên bản 1.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: ColorPalette.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
