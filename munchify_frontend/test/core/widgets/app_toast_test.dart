import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/widgets/app_toast.dart';

void main() {
  testWidgets('AppToast displays message and dismisses on close button tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppToast.navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppToast.showSuccess(context, 'Test success message');
              },
              child: const Text('Show Toast'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test success message'), findsNothing);

    await tester.tap(find.text('Show Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Test success message'), findsOneWidget);

    // Tap close button
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Test success message'), findsNothing);
  });

  testWidgets('AppToast displays error and warning toasts correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppToast.navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppToast.error('Error message', context: context);
              },
              child: const Text('Show Error'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Error message'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNWidgets(2)); // One badge, one close button
  });

  testWidgets('AppToast auto-dismisses after duration',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppToast.navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AppToast.show(
                  context,
                  message: 'Auto dismiss message',
                  type: ToastType.info,
                  duration: const Duration(milliseconds: 500),
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Auto dismiss message'), findsOneWidget);

    // Wait for timer and dismiss animation
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Auto dismiss message'), findsNothing);
  });

  testWidgets('AppToast does NOT block clicks on underlying screen widgets',
      (WidgetTester tester) async {
    int buttonClickCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppToast.navigatorKey,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                buttonClickCount++;
              },
              child: const Text('Underlying Button'),
            ),
          ),
        ),
      ),
    );

    // Show toast without context (using navigatorKey)
    AppToast.info('Notification toast');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Notification toast'), findsOneWidget);

    // Click the button behind / below the toast
    await tester.tap(find.text('Underlying Button'));
    await tester.pump();

    // Verify the click passed through to the underlying widget
    expect(buttonClickCount, equals(1));
  });

  testWidgets('AppToast works seamlessly without context via AppToast.navigatorKey',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppToast.navigatorKey,
        home: const Scaffold(
          body: Text('Home Screen'),
        ),
      ),
    );

    // Show toast without passing BuildContext
    AppToast.success('Global Success without context');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Global Success without context'), findsOneWidget);

    // Clean up
    await tester.pump(const Duration(milliseconds: 4000));
    await tester.pumpAndSettle();
  });

  testWidgets('AppToast handles null overlay safely when no Navigator is mounted',
      (WidgetTester tester) async {
    // Calling AppToast when navigatorKey has no currentState should not throw
    expect(() => AppToast.show(null, message: 'Orphan toast'), returnsNormally);
    expect(() => AppToast.error('Orphan error'), returnsNormally);
  });

  testWidgets('AppToast dismisses cleanly via horizontal swipe gesture',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppToast.navigatorKey,
        home: const Scaffold(
          body: Text('Swipe Test Screen'),
        ),
      ),
    );

    AppToast.warning('Swipeable Warning Toast');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Swipeable Warning Toast'), findsOneWidget);

    // Swipe horizontally to dismiss
    await tester.drag(find.text('Swipeable Warning Toast'), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Swipeable Warning Toast'), findsNothing);
  });

  testWidgets('AppToast replaces existing toast smoothly when called consecutively',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppToast.navigatorKey,
        home: const Scaffold(
          body: Text('Consecutive Toast Screen'),
        ),
      ),
    );

    AppToast.info('First Toast');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('First Toast'), findsOneWidget);

    // Trigger second toast immediately
    AppToast.success('Second Toast');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // First toast should be removed, second should be displayed
    expect(find.text('First Toast'), findsNothing);
    expect(find.text('Second Toast'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 4000));
    await tester.pumpAndSettle();
  });

  testWidgets('All 4 ToastTypes have correct visual styles, icons and badges',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppToast.navigatorKey,
        home: const Scaffold(
          body: Text('Types Test Screen'),
        ),
      ),
    );

    // 1. Success
    AppToast.success('Success Msg');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    // 2. Info
    AppToast.info('Info Msg');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.info_rounded), findsOneWidget);

    // 3. Warning
    AppToast.warning('Warning Msg');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);

    // 4. Error
    AppToast.error('Error Msg');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.close_rounded), findsNWidgets(2)); // Icon badge + close button

    await tester.pump(const Duration(milliseconds: 4000));
    await tester.pumpAndSettle();
  });

  testWidgets('AppToast static helper wrappers call show correctly with context',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppToast.navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => AppToast.showInfo(ctx, 'ShowInfo Msg'),
                  child: const Text('BtnInfo'),
                ),
                ElevatedButton(
                  onPressed: () => AppToast.showWarning(ctx, 'ShowWarning Msg'),
                  child: const Text('BtnWarning'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('BtnInfo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ShowInfo Msg'), findsOneWidget);

    await tester.tap(find.text('BtnWarning'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ShowInfo Msg'), findsNothing);
    expect(find.text('ShowWarning Msg'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 4000));
    await tester.pumpAndSettle();
  });
}
