import 'dart:async';
import 'package:flutter/material.dart';

enum ToastType { success, info, warning, error }

class AppToast {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext? context, {
    required String message,
    ToastType type = ToastType.info,
    Duration? duration,
  }) {
    final overlayState = (context != null ? Overlay.maybeOf(context) : null) ??
        navigatorKey.currentState?.overlay;

    if (overlayState == null) return;

    if (_currentEntry != null) {
      if (_currentEntry!.mounted) {
        _currentEntry!.remove();
      }
      _currentEntry = null;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastOverlay(
        message: message,
        type: type,
        duration: duration ?? const Duration(milliseconds: 3500),
        onDismiss: () {
          if (_currentEntry == entry) {
            _currentEntry = null;
          }
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }

  static void success(String message, {BuildContext? context, Duration? duration}) {
    show(context, message: message, type: ToastType.success, duration: duration);
  }

  static void error(String message, {BuildContext? context, Duration? duration}) {
    show(context, message: message, type: ToastType.error, duration: duration);
  }

  static void warning(String message, {BuildContext? context, Duration? duration}) {
    show(context, message: message, type: ToastType.warning, duration: duration);
  }

  static void info(String message, {BuildContext? context, Duration? duration}) {
    show(context, message: message, type: ToastType.info, duration: duration);
  }

  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    show(context, message: message, type: ToastType.success, duration: duration);
  }

  static void showError(BuildContext context, String message, {Duration? duration}) {
    show(context, message: message, type: ToastType.error, duration: duration);
  }

  static void showWarning(BuildContext context, String message, {Duration? duration}) {
    show(context, message: message, type: ToastType.warning, duration: duration);
  }

  static void showInfo(BuildContext context, String message, {Duration? duration}) {
    show(context, message: message, type: ToastType.info, duration: duration);
  }
}

class _ToastConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color badgeColor;
  final IconData icon;

  const _ToastConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.badgeColor,
    required this.icon,
  });
}

_ToastConfig _getToastConfig(ToastType type) {
  switch (type) {
    case ToastType.success:
      return const _ToastConfig(
        backgroundColor: Color(0xFFEBF7EE),
        borderColor: Color(0xFF86EFAC),
        badgeColor: Color(0xFF22C55E),
        icon: Icons.check_rounded,
      );
    case ToastType.info:
      return const _ToastConfig(
        backgroundColor: Color(0xFFEFF6FF),
        borderColor: Color(0xFFBFDBFE),
        badgeColor: Color(0xFF3B82F6),
        icon: Icons.info_rounded,
      );
    case ToastType.warning:
      return const _ToastConfig(
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
        badgeColor: Color(0xFFF59E0B),
        icon: Icons.priority_high_rounded,
      );
    case ToastType.error:
      return const _ToastConfig(
        backgroundColor: Color(0xFFFEF2F2),
        borderColor: Color(0xFFFECACA),
        badgeColor: Color(0xFFEF4444),
        icon: Icons.close_rounded,
      );
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    _timer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _timer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          heightFactor: 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Dismissible(
                    key: const ValueKey('app_toast_dismissible'),
                    direction: DismissDirection.horizontal,
                    onDismissed: (_) {
                      _timer?.cancel();
                      widget.onDismiss();
                    },
                    child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! < -100) {
                          _dismiss();
                        }
                      },
                      child: _ToastCard(
                        message: widget.message,
                        type: widget.type,
                        onClose: _dismiss,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback onClose;

  const _ToastCard({
    required this.message,
    required this.type,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getToastConfig(type);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: config.borderColor, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: config.badgeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  config.icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onClose,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
