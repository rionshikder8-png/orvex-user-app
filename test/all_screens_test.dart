import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orvex_user_app/screens/account/language_screen.dart';
import 'package:orvex_user_app/screens/account/notifications_screen.dart';
import 'package:orvex_user_app/screens/account/password_screen.dart';
import 'package:orvex_user_app/screens/account/profile_screen.dart';
import 'package:orvex_user_app/screens/account/settings_screen.dart';
import 'package:orvex_user_app/screens/account/subscription_screen.dart';
import 'package:orvex_user_app/screens/account/team_screen.dart';
import 'package:orvex_user_app/screens/account/theme_screen.dart';
import 'package:orvex_user_app/screens/ai/agent_test_screen.dart';
import 'package:orvex_user_app/screens/ai/ai_agent_screen.dart';
import 'package:orvex_user_app/screens/ai/knowledge_screen.dart';
import 'package:orvex_user_app/screens/automation/automation_screen.dart';
import 'package:orvex_user_app/screens/automation/insights_screen.dart';
import 'package:orvex_user_app/screens/courier/courier_screen.dart';
import 'package:orvex_user_app/screens/facebook/comment_detail_screen.dart';
import 'package:orvex_user_app/screens/facebook/comment_rules_screen.dart';
import 'package:orvex_user_app/screens/facebook/comments_screen.dart';
import 'package:orvex_user_app/screens/facebook/moderation_screen.dart';
import 'package:orvex_user_app/screens/home/home_screen.dart';
import 'package:orvex_user_app/screens/inbox/conversation_screen.dart';
import 'package:orvex_user_app/screens/inbox/customer_screen.dart';
import 'package:orvex_user_app/screens/inbox/inbox_screen.dart';
import 'package:orvex_user_app/screens/integrations/integration_detail_screen.dart';
import 'package:orvex_user_app/screens/integrations/integrations_screen.dart';
import 'package:orvex_user_app/screens/orders/order_detail_screen.dart';
import 'package:orvex_user_app/screens/orders/orders_screen.dart';
import 'package:orvex_user_app/screens/products/product_detail_screen.dart';
import 'package:orvex_user_app/screens/products/product_form_screen.dart';
import 'package:orvex_user_app/screens/products/products_screen.dart';

import 'helpers.dart';

/// Every screen, built against the demo data set (ids from DemoData).
Map<String, Widget> allScreens() => {
  'home': HomeScreen(onOpenTab: (_) {}),
  'inbox': const InboxScreen(),
  'conversation': const ConversationScreen(conversationId: 'c1'),
  'customer': const CustomerScreen(conversationId: 'c1'),
  'comments': const CommentsScreen(),
  'comment_detail': const CommentDetailScreen(commentId: 'fc1'),
  'comment_rules': const CommentRulesScreen(),
  'moderation': const ModerationScreen(),
  'activity_logs': const ActivityLogsScreen(),
  'ai_agent': const AiAgentScreen(),
  'knowledge': const KnowledgeScreen(),
  'agent_test': const AgentTestScreen(),
  'products': const ProductsScreen(),
  'product_detail': const ProductDetailScreen(productId: 'p2'),
  'product_form_new': const ProductFormScreen(),
  'product_form_edit': const ProductFormScreen(productId: 'p1'),
  'orders': const OrdersScreen(),
  'order_detail': const OrderDetailScreen(orderId: 'o1'),
  'courier': const CourierScreen(),
  'courier_for_order': const CourierScreen(initialOrderId: 'o1'),
  'automation': const AutomationScreen(),
  'insights': const InsightsScreen(),
  'integrations': const IntegrationsScreen(),
  'integration_messenger': const IntegrationDetailScreen(
    integrationId: 'messenger',
  ),
  'integration_whatsapp': const IntegrationDetailScreen(
    integrationId: 'whatsapp',
  ),
  'integration_comments': const IntegrationDetailScreen(
    integrationId: 'comments',
  ),
  'integration_website': const IntegrationDetailScreen(
    integrationId: 'website',
  ),
  'settings': const SettingsScreen(),
  'subscription': const SubscriptionScreen(),
  'notifications': const NotificationsScreen(),
  'team': const TeamScreen(),
  'profile': const ProfileScreen(),
  'language': const LanguageScreen(),
  'theme': const ThemeScreen(),
  'password': const PasswordScreen(),
};

Future<List<String>> render(
  WidgetTester tester,
  TestEnv env,
  Widget screen, {
  required Locale locale,
  required double scale,
  required bool dark,
}) async {
  tester.view.physicalSize = const Size(720, 1280); // 360x640 dp
  tester.view.devicePixelRatio = 2;
  final errors = <String>[];
  final old = FlutterError.onError;
  FlutterError.onError = (d) {
    final full = d.toString();
    final loc = RegExp(r'(lib/[A-Za-z_/]+\.dart:\d+)')
        .allMatches(full)
        .map((m) => m.group(1))
        .toSet()
        .take(3)
        .join(',');
    errors.add('${d.exceptionAsString().split('\n').first} @ $loc');
  };
  try {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: const Size(360, 640),
          textScaler: TextScaler.linear(scale),
          platformBrightness: dark ? Brightness.dark : Brightness.light,
        ),
        child: wrap(env, screen, locale: locale, dark: dark),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
  } finally {
    FlutterError.onError = old;
  }
  return errors;
}

void main() {
  tearDown(() {});

  for (final demo in [true, false]) {
    for (final locale in const [Locale('en'), Locale('bn')]) {
      for (final dark in [false, true]) {
        final name =
            '${demo ? 'demo' : 'empty'}/${locale.languageCode}/${dark ? 'dark' : 'light'}';
        testWidgets('every screen renders cleanly: $name (text x1.5)', (
          tester,
        ) async {
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final failures = <String>[];
          for (final e in allScreens().entries) {
            final env = TestEnv();
            if (demo) {
              env.auth.enterDemo();
            }
            await env.data.load(demoSession: demo);
            final errs = await render(
              tester,
              env,
              e.value,
              locale: locale,
              scale: 1.5,
              dark: dark,
            );
            if (errs.isNotEmpty) {
              failures.add('${e.key}: ${errs.toSet().join(' | ')}');
            }
          }
          expect(failures, isEmpty, reason: failures.join('\n'));
        });
      }
    }
  }
}
