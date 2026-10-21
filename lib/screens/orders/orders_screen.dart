import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../courier/courier_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _query = '';
  OrderStatus? _status;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final q = _query.trim().toLowerCase();
    final list = data.orders.where((o) {
      if (_status != null && o.status != _status) return false;
      if (q.isEmpty) return true;
      return o.number.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.phone.contains(q);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('orders')),
        actions: [
          IconButton(
            tooltip: context.t('couriers'),
            icon: const Icon(AppIcons.courier),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const CourierScreen()),
            ),
          ),
        ],
      ),
      body: DataGate(
        data: data,
        builder: (_) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                children: [
                  if (data.isDemo) ...[
                    const DemoBanner(),
                    const SizedBox(height: 10),
                  ],
                  AppSearchField(
                    hint: context.t('search_orders'),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilterChips<OrderStatus?>(
                      options: {
                        null: context.t('all'),
                        for (final s in OrderStatus.values)
                          s: context.t(_statusKey(s)),
                      },
                      selected: _status,
                      onSelected: (v) => setState(() => _status = v),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: data.orders.isEmpty
                  ? EmptyState(
                      icon: AppIcons.orders,
                      title: context.t('no_orders'),
                      message: context.t('no_orders_hint'),
                    )
                  : list.isEmpty
                  ? EmptyState(
                      icon: AppIcons.search,
                      title: context.t('no_results'),
                      message: context.t('no_results_hint'),
                    )
                  : RefreshIndicator(
                      onRefresh: data.refresh,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _OrderTile(o: list[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusKey(OrderStatus s) => switch (s) {
  OrderStatus.pending => 'os_pending',
  OrderStatus.confirmed => 'os_confirmed',
  OrderStatus.processing => 'os_processing',
  OrderStatus.shipped => 'os_shipped',
  OrderStatus.delivered => 'os_delivered',
  OrderStatus.cancelled => 'os_cancelled',
};

String orderStatusKey(OrderStatus s) => _statusKey(s);

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.o});
  final Order o;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailScreen(orderId: o.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  o.number,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                Fmt.money(context, o.total),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(o.customerName, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            '${o.items.length} ${context.t('items').toLowerCase()}  |  ${Fmt.dateTime(o.createdAt)}',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Chips.order(context, o.status),
              Chips.payment(context, o.payment),
            ],
          ),
        ],
      ),
    );
  }
}
