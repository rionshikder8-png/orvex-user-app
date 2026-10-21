import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_config.dart';
import '../../core/l10n.dart';
import '../../services/app_data.dart';
import '../../services/auth_controller.dart';
import '../../services/settings_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';
import '../ai/ai_agent_screen.dart';
import '../automation/automation_screen.dart';
import '../automation/insights_screen.dart';
import '../courier/courier_screen.dart';
import '../facebook/comments_screen.dart';
import '../integrations/integrations_screen.dart';
import 'language_screen.dart';
import 'notifications_screen.dart';
import 'password_screen.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';
import 'team_screen.dart';
import 'theme_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _push(BuildContext c, Widget w) =>
      Navigator.push(c, MaterialPageRoute<void>(builder: (_) => w));

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: context.t('logout_confirm_title'),
      message: context.t('logout_confirm_msg'),
      confirmLabel: context.t('logout'),
      destructive: true,
    );
    if (ok && context.mounted) await context.read<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final data = context.watch<AppData>();
    final settings = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;
    final user = auth.user;

    final themeLabel = switch (settings.themeMode) {
      ThemeMode.light => context.t('theme_light'),
      ThemeMode.dark => context.t('theme_dark'),
      ThemeMode.system => context.t('theme_system'),
    };

    return Scaffold(
      appBar: AppBar(title: Text(context.t('settings'))),
      body: PageBody(
        children: [
          if (auth.isDemo) ...[
            NoticeBanner(
              kind: NoticeKind.warning,
              title: context.t('demo_mode'),
              message: context.t('demo_mode_msg'),
              trailing: TextButton(
                onPressed: auth.logout,
                child: Text(context.t('exit_demo')),
              ),
            ),
            const SizedBox(height: 14),
          ],
          AppCard(
            onTap: () => _push(context, const ProfileScreen()),
            child: Row(
              children: [
                AvatarBadge(
                  text: (user?.name.isNotEmpty ?? false)
                      ? user!.name.characters.first.toUpperCase()
                      : '?',
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(AppIcons.chevron),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: context.t('workspace')),
          GroupedCard(
            children: [
              NavRow(
                icon: AppIcons.agent,
                title: context.t('ai_agent'),
                onTap: () => _push(context, const AiAgentScreen()),
              ),
              NavRow(
                icon: AppIcons.comments,
                title: context.t('fb_comments'),
                onTap: () => _push(context, const CommentsScreen()),
              ),
              NavRow(
                icon: AppIcons.courier,
                title: context.t('couriers'),
                onTap: () => _push(context, const CourierScreen()),
              ),
              NavRow(
                icon: AppIcons.automation,
                title: context.t('automation'),
                onTap: () => _push(context, const AutomationScreen()),
              ),
              NavRow(
                icon: AppIcons.insights,
                title: context.t('insights'),
                onTap: () => _push(context, const InsightsScreen()),
              ),
              NavRow(
                icon: AppIcons.integrations,
                title: context.t('integrations'),
                subtitle: context.t('channels_summary', {
                  'n': '${data.connectedChannels}',
                  'total': '${data.totalChannels}',
                }),
                onTap: () => _push(context, const IntegrationsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(title: context.t('account')),
          GroupedCard(
            children: [
              NavRow(
                icon: AppIcons.subscription,
                title: context.t('subscription'),
                onTap: () => _push(context, const SubscriptionScreen()),
              ),
              NavRow(
                icon: AppIcons.notifications,
                title: context.t('notifications'),
                trailing: data.unreadNotifications > 0
                    ? Badge(label: Text('${data.unreadNotifications}'))
                    : const Icon(AppIcons.chevron, size: 20),
                onTap: () => _push(context, const NotificationsScreen()),
              ),
              NavRow(
                icon: AppIcons.team,
                title: context.t('team_members'),
                onTap: () => _push(context, const TeamScreen()),
              ),
              NavRow(
                icon: AppIcons.profile,
                title: context.t('profile_settings'),
                onTap: () => _push(context, const ProfileScreen()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(title: context.t('preferences')),
          GroupedCard(
            children: [
              NavRow(
                icon: AppIcons.language,
                title: context.t('language_settings'),
                subtitle: settings.locale.languageCode == 'bn'
                    ? context.t('lang_bn')
                    : context.t('lang_en'),
                onTap: () => _push(context, const LanguageScreen()),
              ),
              NavRow(
                icon: AppIcons.theme,
                title: context.t('theme_settings'),
                subtitle: themeLabel,
                onTap: () => _push(context, const ThemeScreen()),
              ),
              NavRow(
                icon: AppIcons.lock,
                title: context.t('password_settings'),
                onTap: () => _push(context, const PasswordScreen()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GroupedCard(
            children: [
              NavRow(
                icon: AppIcons.help,
                title: context.t('help_support'),
                onTap: () => infoDialog(
                  context,
                  title: context.t('help_support'),
                  message: context.t('help_msg'),
                ),
              ),
              NavRow(
                icon: AppIcons.logout,
                title: context.t('logout'),
                destructive: true,
                onTap: () => _logout(context),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              '${AppConfig.appName}  |  ${context.t('version')} 1.0.0',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
