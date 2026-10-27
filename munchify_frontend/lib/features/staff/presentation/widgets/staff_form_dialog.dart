import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/ColorPalette.dart';
import '../../../../core/theme/AppTypography.dart';
import '../../../../core/utils/Validators.dart';
import '../../domain/entities/staff_entity.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../../../../core/widgets/app_toast.dart';

class StaffFormDialog extends StatefulWidget {
  final StaffEntity? staffToEdit;

  const StaffFormDialog({super.key, this.staffToEdit});

  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _fullName;
  String? _phone;
  String? _email;
  late String _role;
  String? _password;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _username = widget.staffToEdit?.username ?? '';
    _fullName = widget.staffToEdit?.fullName ?? '';
    _phone = widget.staffToEdit?.phone;
    _email = widget.staffToEdit?.email;
    _role = widget.staffToEdit?.role ?? 'STAFF';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final staffData = <String, dynamic>{
        'username': _username.trim(),
        'fullName': _fullName.trim(),
        'phone': _phone?.trim().isEmpty == true ? null : _phone?.trim(),
        'email': _email?.trim().isEmpty == true ? null : _email?.trim(),
        'role': _role,
      };

      if (widget.staffToEdit == null) {
        if (_password == null || _password!.isEmpty) {
          AppToast.error('Vui lòng nhập mật khẩu cho tài khoản mới', context: context);
          return;
        }
        staffData['password'] = _password!;
        context.read<StaffBloc>().add(CreateStaffEvent(staffData));
      } else {
        context.read<StaffBloc>().add(UpdateStaffEvent(widget.staffToEdit!.userId, staffData));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.staffToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ColorPalette.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ─────────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorPalette.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
                          color: ColorPalette.appetizingOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Cập nhật thông tin nhân viên' : 'Thêm nhân viên mới',
                              style: AppTypography.dashboardHeadline.copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isEditing
                                  ? 'Chỉnh sửa quyền hạn và liên hệ của nhân viên'
                                  : 'Cấp tài khoản truy cập hệ thống Munchify POS',
                              style: AppTypography.dashboardSubtitle,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 20, color: ColorPalette.textMuted),
                        tooltip: 'Đóng',
                        style: IconButton.styleFrom(
                          backgroundColor: ColorPalette.webBgAdmin,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(34, 34),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: ColorPalette.borderSubtle, height: 1),
                  const SizedBox(height: 20),

                  // ─── Username ───────────────────────────────────────────
                  _buildFieldLabel('Tên đăng nhập (Username)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: _username,
                    style: const TextStyle(fontSize: 13),
                    decoration: _inputDecoration(
                      hint: 'VD: staff_nam',
                      icon: Icons.alternate_email_rounded,
                      enabled: !isEditing,
                    ),
                    enabled: !isEditing,
                    validator: isEditing ? null : Validators.validateUsername,
                    onSaved: (val) => _username = val ?? '',
                  ),
                  const SizedBox(height: 16),

                  // ─── Password (chỉ khi tạo mới) ─────────────────────────
                  if (!isEditing) ...[
                    _buildFieldLabel('Mật khẩu khởi tạo'),
                    const SizedBox(height: 6),
                    TextFormField(
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration(
                        hint: 'Tối thiểu 6 ký tự',
                        icon: Icons.lock_outline_rounded,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: ColorPalette.textMuted,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: Validators.validatePassword,
                      onSaved: (val) => _password = val,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── Full Name ──────────────────────────────────────────
                  _buildFieldLabel('Họ và tên đầy đủ'),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: _fullName,
                    style: const TextStyle(fontSize: 13),
                    decoration: _inputDecoration(
                      hint: 'VD: Nguyễn Văn A',
                      icon: Icons.badge_outlined,
                    ),
                    validator: (val) => Validators.validateRequired(val, fieldName: 'Họ và tên'),
                    onSaved: (val) => _fullName = val ?? '',
                  ),
                  const SizedBox(height: 16),

                  // ─── Phone & Email ──────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Số điện thoại'),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: _phone,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDecoration(
                                hint: '0901234567',
                                icon: Icons.phone_outlined,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return null;
                                return Validators.validatePhoneNumber(val);
                              },
                              onSaved: (val) => _phone = val,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Email liên hệ'),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: _email,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDecoration(
                                hint: 'staff@fnb.com',
                                icon: Icons.email_outlined,
                              ),
                              validator: Validators.validateEmail,
                              onSaved: (val) => _email = val,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Role Information (Fixed / Default: STAFF) ─────────
                  _buildFieldLabel('Phân quyền tài khoản'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: ColorPalette.webBgAdmin.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorPalette.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _role == 'ADMIN'
                                ? ColorPalette.amber.withValues(alpha: 0.15)
                                : ColorPalette.info.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _role,
                            style: TextStyle(
                              color: _role == 'ADMIN' ? const Color(0xFF92400E) : const Color(0xFF1E40AF),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _role == 'ADMIN' ? 'Quản trị viên toàn quyền' : 'Nhân viên bán hàng / Phục vụ (Mặc định)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ColorPalette.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEditing
                                    ? 'Vai trò hệ thống được cố định để đảm bảo an toàn phân quyền.'
                                    : 'Tài khoản mới được gán mặc định vai trò STAFF theo chính sách bảo mật.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: ColorPalette.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: ColorPalette.textMuted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Dialog Actions ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorPalette.borderSubtle),
                          foregroundColor: ColorPalette.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Hủy bỏ'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: Text(isEditing ? 'Lưu thay đổi' : 'Tạo tài khoản'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.appetizingOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helper: Field Label ────────────────────────────────────────────────
  Widget _buildFieldLabel(String text) {
    return Text(text, style: AppTypography.labelLarge.copyWith(fontSize: 12));
  }

  // ─── Helper: Consistent Input Decoration ────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool enabled = true,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: ColorPalette.textMuted),
      prefixIcon: Icon(icon, size: 18, color: ColorPalette.textMuted),
      filled: true,
      fillColor: enabled ? ColorPalette.webBgAdmin.withValues(alpha: 0.5) : ColorPalette.webBgAdmin,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ColorPalette.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ColorPalette.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ColorPalette.appetizingOrange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ColorPalette.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ColorPalette.error, width: 1.5),
      ),
    );
  }
}
