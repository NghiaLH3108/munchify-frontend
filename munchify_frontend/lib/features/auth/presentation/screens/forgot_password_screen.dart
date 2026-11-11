import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 1; // 1: Send OTP, 2: Reset with OTP
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String _targetEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSendOtpPressed() {
    if (_emailFormKey.currentState?.validate() ?? false) {
      _targetEmail = _emailController.text.trim();
      context.read<AuthBloc>().add(ForgotPasswordEvent(email: _targetEmail));
    }
  }

  void _onResetPasswordPressed() {
    if (_resetFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            ResetPasswordEvent(
              email: _targetEmail,
              otp: _otpController.text.trim(),
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: ColorPalette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorPalette.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
            setState(() {
              _currentStep = 2;
            });
          } else if (state is ForgotPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorPalette.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          } else if (state is ResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorPalette.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
            // Navigate back to login
            Navigator.pop(context);
          } else if (state is ResetPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorPalette.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isOtpLoading = state is ForgotPasswordLoading;
          final isResetLoading = state is ResetPasswordLoading;

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
                child: _currentStep == 1
                    ? _buildStep1Email(isOtpLoading)
                    : _buildStep2Reset(isResetLoading),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep1Email(bool isLoading) {
    return Form(
      key: _emailFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ColorPalette.appetizingOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: ColorPalette.appetizingOrange,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quên mật khẩu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhập địa chỉ email đã đăng ký của bạn. Chúng tôi sẽ gửi mã xác thực OTP để tạo mật khẩu mới.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: ColorPalette.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Địa chỉ Email',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            decoration: InputDecoration(
              hintText: 'vidu@munchify.vn',
              prefixIcon: const Icon(
                Icons.email_outlined,
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
                return 'Vui lòng nhập email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Email không đúng định dạng';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _onSendOtpPressed,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Gửi mã xác nhận OTP',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Quay lại đăng nhập',
                style: TextStyle(
                  color: ColorPalette.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Reset(bool isLoading) {
    return Form(
      key: _resetFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ColorPalette.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: ColorPalette.success,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đặt lại mật khẩu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: ColorPalette.textSecondary,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Mã xác thực đã được gửi đến '),
                TextSpan(
                  text: _targetEmail,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // OTP Field
          const Text(
            'Mã xác thực (OTP)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: !isLoading,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              letterSpacing: 6,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '000000',
              hintStyle: TextStyle(
                fontSize: 18,
                letterSpacing: 6,
                color: ColorPalette.textHint.withValues(alpha: 0.5),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().length != 6) {
                return 'Vui lòng nhập đủ 6 chữ số OTP';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // New Password
          const Text(
            'Mật khẩu mới',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            enabled: !isLoading,
            decoration: InputDecoration(
              hintText: 'Tối thiểu 6 ký tự',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: ColorPalette.textSecondary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: ColorPalette.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
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
              if (value == null || value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          const Text(
            'Xác nhận mật khẩu mới',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            enabled: !isLoading,
            decoration: InputDecoration(
              hintText: 'Nhập lại mật khẩu mới',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: ColorPalette.textSecondary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: ColorPalette.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
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
              if (value != _newPasswordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Submit Reset Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _onResetPasswordPressed,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Đặt lại mật khẩu',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          _currentStep = 1;
                        });
                      },
                child: const Text('Thay đổi Email'),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(
                              ForgotPasswordEvent(email: _targetEmail),
                            );
                      },
                child: const Text('Gửi lại mã OTP'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
