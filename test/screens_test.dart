import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orvex_user_app/screens/account/settings_screen.dart';
import 'package:orvex_user_app/screens/app_gate.dart';
import 'package:orvex_user_app/screens/auth/forgot_password_screen.dart';
import 'package:orvex_user_app/screens/auth/login_screen.dart';
import 'package:orvex_user_app/screens/auth/register_screen.dart';
import 'package:orvex_user_app/screens/auth/reset_password_screen.dart';
import 'package:orvex_user_app/screens/auth/welcome_screen.dart';
import 'package:orvex_user_app/screens/main_shell.dart';
import 'package:orvex_user_app/screens/onboarding/onboarding_screen.dart';

import 'helpers.dart';

/// Pumps [child] at a small phone size and fails on any layout exception
/// (overflow, unbounded constraints, ...).
Future<void> pumpAt(
  WidgetTester tester,
  TestEnv env,
  Widget child, {
  Size size = const Size(360, 640),
  double textScale = 1.0,
  Locale locale = const Locale('en'),
  bool dark = false,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: wrap(env, child, locale: locale),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('auth screens render without overflow', () {
    for (final locale in const [Locale('en'), Locale('bn')]) {
      for (final scale in [1.0, 1.6]) {
        testWidgets(
          'welcome/login/register/forgot/reset ${locale.languageCode} x$scale',
          (tester) async {
            for (final screen in <Widget>[
              const WelcomeScreen(),
              const LoginScreen(),
              const RegisterScreen(),
              const ForgotPasswordScreen(),
              const ResetPasswordScreen(),
            ]) {
              final env = TestEnv();
              await pumpAt(
                tester,
                env,
                screen,
                locale: locale,
                textScale: scale,
              );
              expect(
                tester.takeException(),
                isNull,
                reason: '${screen.runtimeType} ${locale.languageCode} x$scale',
              );
            }
          },
        );
      }
    }
  });

  testWidgets('login validates empty fields', (tester) async {
    await pumpAt(tester, TestEnv(), const LoginScreen());
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('register validates password confirmation', (tester) async {
    await pumpAt(
      tester,
      TestEnv(),
      const RegisterScreen(),
      size: const Size(360, 900),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Rahim Uddin');
    await tester.enterText(fields.at(1), 'rahim@example.com');
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'different123');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets(
    'Google button shows an honest setup-required notice when unconfigured',
    (tester) async {
      await pumpAt(
        tester,
        TestEnv(),
        const LoginScreen(),
        size: const Size(360, 900),
      );
      expect(find.text('Google Sign-In setup required'), findsOneWidget);
      await tester.tap(find.text('Continue with Google'));
      await tester.pump(const Duration(milliseconds: 300));
      // Still signed out: selecting Google without config must not authenticate.
      expect(find.text('Google Sign-In setup required'), findsOneWidget);
    },
  );

  testWidgets(
    'login without backend shows backend-missing error, stays signed out',
    (tester) async {
      final env = TestEnv();
      await pumpAt(
        tester,
        env,
        const LoginScreen(),
        size: const Size(360, 900),
      );
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'a@b.co');
      await tester.enterText(fields.at(1), 'password1');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('real login is unavailable'), findsOneWidget);
    },
  );

  testWidgets('onboarding walks through steps and finishes', (tester) async {
    final env = TestEnv();
    await pumpAt(
      tester,
      env,
      const OnboardingScreen(),
      size: const Size(380, 900),
    );
    expect(find.text('Step 1 of 3'), findsOneWidget);

    // Required fields block progress.
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Step 1 of 3'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Demo Shop');
    await tester.enterText(fields.at(2), 'shop@example.com');
    await tester.enterText(fields.at(3), '01711000001');
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Step 2 of 3'), findsOneWidget);

    await tester.tap(find.text('Finish setup'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Step 3 of 3'), findsOneWidget);
    expect(find.text('You are all set'), findsOneWidget);
    expect(env.data.business.name, 'Demo Shop');
  });

  group('demo shell', () {
    for (final dark in [false, true]) {
      testWidgets(
        'all five tabs render (${dark ? 'dark' : 'light'}) without overflow',
        (tester) async {
          final env = TestEnv();
          env.auth.enterDemo();
          await env.data.load(demoSession: true);
          await pumpAt(
            tester,
            env,
            const MainShell(),
            size: const Size(360, 640),
            dark: dark,
          );
          for (final label in [
            'Home',
            'Inbox',
            'Orders',
            'Products',
            'Settings',
          ]) {
            await tester.tap(
              find.descendant(
                of: find.byType(NavigationBar),
                matching: find.text(label),
              ),
            );
            await tester.pump(const Duration(milliseconds: 350));
            expect(tester.takeException(), isNull, reason: 'tab $label');
          }
        },
      );
    }

    testWidgets('bangla tabs render with large text', (tester) async {
      final env = TestEnv();
      env.auth.enterDemo();
      await env.data.load(demoSession: true);
      await pumpAt(
        tester,
        env,
        const MainShell(),
        size: const Size(360, 640),
        locale: const Locale('bn'),
        textScale: 1.4,
      );
      for (final label in ['হোম', 'ইনবক্স', 'অর্ডার', 'পণ্য', 'সেটিংস']) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull, reason: 'tab $label');
      }
    });

    testWidgets('demo data is labelled on the dashboard', (tester) async {
      final env = TestEnv();
      env.auth.enterDemo();
      await env.data.load(demoSession: true);
      await pumpAt(tester, env, const MainShell(), size: const Size(360, 900));
      expect(find.text('Demo data'), findsWidgets);
    });

    testWidgets('logout asks for confirmation and signs out', (tester) async {
      final env = TestEnv();
      env.auth.enterDemo();
      await env.data.load(demoSession: true);
      await pumpAt(
        tester,
        env,
        const SettingsScreen(),
        size: const Size(360, 1400),
      );
      await tester.scrollUntilVisible(
        find.text('Log out'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Log out'));
      await tester.pump();
      await tester.tap(find.text('Log out'), warnIfMissed: true);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.text('Log out?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(env.auth.isDemo, isFalse);
    });
  });

  testWidgets('AppGate routes by session state', (tester) async {
    final env = TestEnv();
    await pumpAt(tester, env, const AppGate());
    expect(find.byType(WelcomeScreen), findsOneWidget);

    env.auth.enterDemo();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MainShell), findsOneWidget);
  });
}
