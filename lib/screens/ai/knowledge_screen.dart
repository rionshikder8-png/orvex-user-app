import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  Future<void> _edit(BuildContext context, [KnowledgeEntry? e]) async {
    final q = TextEditingController(text: e?.question ?? '');
    final a = TextEditingController(text: e?.answer ?? '');
    final form = GlobalKey<FormState>();
    final saved = await showAppSheet<bool>(
      context,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  e == null ? ctx.t('add_entry') : ctx.t('edit_entry'),
                  style: Theme.of(ctx).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: q,
                  label: ctx.t('question'),
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? ctx.t('required')
                      : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: a,
                  label: ctx.t('answer'),
                  maxLines: 4,
                  minLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? ctx.t('required')
                      : null,
                ),
                const SizedBox(height: 16),
                LoadingButton(
                  label: ctx.t('save'),
                  onPressed: () {
                    if (form.currentState!.validate()) Navigator.pop(ctx, true);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (saved == true && context.mounted) {
      context.read<AppData>().upsertKnowledge(
        KnowledgeEntry(
          id: e?.id ?? 'local-${DateTime.now().microsecondsSinceEpoch}',
          question: q.text.trim(),
          answer: a.text.trim(),
        ),
      );
      showSnack(context, context.t('settings_saved_local'));
    }
    q.dispose();
    a.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    return AppScaffold(
      title: context.t('faq_knowledge'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(AppIcons.add),
        label: Text(context.t('add_entry')),
      ),
      body: data.knowledge.isEmpty
          ? EmptyState(
              icon: AppIcons.book,
              title: context.t('no_faq'),
              message: context.t('no_faq_hint'),
              actionLabel: context.t('add_entry'),
              onAction: () => _edit(context),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              children: [
                if (data.isDemo) ...[
                  const DemoBanner(),
                  const SizedBox(height: 12),
                ],
                NoticeBanner(message: context.t('not_saved_notice')),
                const SizedBox(height: 12),
                for (final e in data.knowledge)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      onTap: () => _edit(context, e),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.question,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  e.answer,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: context.t('delete'),
                            icon: const Icon(AppIcons.delete, size: 20),
                            onPressed: () async {
                              final ok = await confirmDialog(
                                context,
                                title: context.t('delete'),
                                message: e.question,
                                confirmLabel: context.t('delete'),
                                destructive: true,
                              );
                              if (ok && context.mounted) {
                                context.read<AppData>().removeKnowledge(e.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
