import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/load_state.dart';
import '../services/app_data.dart';
import 'state_views.dart';

/// Standard page wrapper used by every pushed screen: app bar with title and
/// actions, safe scrolling body and optional floating button.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottom,
    this.bottomBar,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions, bottom: bottom),
    body: SafeArea(top: false, child: body),
    floatingActionButton: floatingActionButton,
    bottomNavigationBar: bottomBar,
  );
}

/// Scroll view with standard page padding and a max content width so tablets
/// and landscape phones do not stretch forms.
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.children,
    this.onRefresh,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
  });

  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      children: children,
    );
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: list,
      ),
    );
    return onRefresh == null
        ? content
        : RefreshIndicator(onRefresh: onRefresh!, child: content);
  }
}

/// Wraps content with the loading / error / offline handling of [AppData].
class DataGate extends StatelessWidget {
  const DataGate({super.key, required this.data, required this.builder});
  final AppData data;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    switch (data.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const LoadingView();
      case LoadStatus.offline:
        return OfflineState(onRetry: data.refresh);
      case LoadStatus.error:
        return ErrorState(
          message: context.t('error_generic'),
          onRetry: data.refresh,
        );
      case LoadStatus.ready:
        return builder(context);
    }
  }
}
