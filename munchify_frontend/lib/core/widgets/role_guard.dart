import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

/// Chỉ hiển thị [child] nếu người dùng hiện tại có role nằm trong [allowedRoles]
/// (so sánh không phân biệt hoa/thường). Ngược lại hiển thị [fallback].
class RoleGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget fallback;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    if (state is Authenticated) {
      final role = state.user.role.toUpperCase();
      if (allowedRoles.map((r) => r.toUpperCase()).contains(role)) {
        return child;
      }
    }
    return fallback;
  }
}
