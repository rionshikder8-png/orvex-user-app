import 'package:flutter/material.dart';

import '../core/l10n.dart';

/// Confirmation dialog. Returns true when confirmed.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final scheme = Theme.of(context).colorScheme;
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel ?? ctx.t('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            minimumSize: const Size(96, 42),
            backgroundColor: destructive ? scheme.error : null,
            foregroundColor: destructive ? scheme.onError : null,
          ),
          child: Text(confirmLabel ?? ctx.t('confirm')),
        ),
      ],
    ),
  );
  return res ?? false;
}

/// Informational dialog with a single close button.
Future<void> infoDialog(
  BuildContext context, {
  required String title,
  required String message,
}) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(ctx),
        style: FilledButton.styleFrom(minimumSize: const Size(96, 42)),
        child: Text(ctx.t('close')),
      ),
    ],
  ),
);

void showSnack(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
    ),
  );
}

/// Shows a modal bottom sheet sized to its content with keyboard padding.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (ctx) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
    child: builder(ctx),
  ),
);

/// Standard sheet for choosing one option from a list.
Future<T?> pickOne<T>(
  BuildContext context, {
  required String title,
  required Map<T, String> options,
  T? selected,
}) => showAppSheet<T>(
  context,
  builder: (ctx) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            title,
            style: Theme.of(ctx).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final e in options.entries)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text(e.value),
                  trailing: e.key == selected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(ctx).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(ctx, e.key),
                ),
            ],
          ),
        ),
      ],
    ),
  ),
);

/// A reusable "backend required" explanation dialog.
Future<void> backendRequiredDialog(
  BuildContext context, {
  String? messageKey,
}) => infoDialog(
  context,
  title: context.t('backend_required'),
  message: context.t(messageKey ?? 'backend_not_configured'),
);
