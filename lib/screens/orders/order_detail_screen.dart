import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../courier/courier_screen.dart';
import 'orders_screen.dart' show orderStatusKey;

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _note = TextEditingController();
  bool _noteInit = false;
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(AppData data, Order o) async {
    final choice = await pickOne<OrderStatus>(
      context,
      title: context.t('update_status'),
      options: {
        for (final s in OrderStatus.values.where(
          (s) => s != OrderStatus.cancelled,
        ))
          s: context.t(orderStatusKey(s)),
      },
      selected: o.status,
    );
    if (choice == null || choice == o.status || !mounted) return;
    setState(() => _busy = true);
    final res = await data.confirmOrderStatus(o.id, choice);
    if (!mounted) return;
    setState(() => _busy = false);
    // res == null means the backend confirmed. Any other value is an honest notice.
    showSnack(
      context,
      res == null ? context.t('settings_saved') : context.t(res),
      error: res == 'error_generic' || res == 'offline_msg',
    );
  }

  Future<void> _cancel(AppData data, Order o) async {
    final ok = await confirmDialog(
      context,
      title: context.t('cancel_order_title'),
      message: context.t('cancel_order_msg'),
      confirmLabel: context.t('cancel_order'),
      cancelLabel: context.t('keep_order'),
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final res = await data.confirmOrderStatus(o.id, OrderStatus.cancelled);
    if (!mounted) return;
    setState(() => _busy = false);
    showSnack(
      context,
      res == null ? context.t('settings_saved') : context.t(res),
      error: res == 'error_generic' || res == 'offline_msg',
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final found = data.orders.where((o) => o.id == widget.orderId);
    if (found.isEmpty) {
      return AppScaffold(
        title: context.t('order_details'),
        body: EmptyState(icon: AppIcons.orders, title: context.t('no_results')),
      );
    }
    final o = found.first;
    if (!_noteInit) {
      _note.text = o.note;
      _noteInit = true;
    }
    final scheme = Theme.of(context).colorScheme;
    final cancellable =
        o.status != OrderStatus.cancelled && o.status != OrderStatus.delivered;

    return AppScaffold(
      title: context.t('order_number', {'id': o.number}),
      body: PageBody(
        children: [
          if (data.isDemo) ...[const DemoBanner(), const SizedBox(height: 12)],
          AppCard(
            child: Column(
              children: [
                InfoRow(
                  label: context.t('order_status'),
                  value: '',
                  valueWidget: Chips.order(context, o.status),
                ),
                InfoRow(
                  label: context.t('payment_status'),
                  value: '',
                  valueWidget: Chips.payment(context, o.payment),
                ),
                InfoRow(
                  label: context.t('status'),
                  value: Fmt.dateTime(o.createdAt),
                ),
                if (o.channel != null)
                  InfoRow(
                    label: context.t('conversation'),
                    value: '',
                    valueWidget: Chips.channel(context, o.channel!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(title: context.t('customer')),
          AppCard(
            child: Column(
              children: [
                InfoRow(label: context.t('customer'), value: o.customerName),
                InfoRow(label: context.t('phone_number'), value: o.phone),
                InfoRow(label: context.t('delivery_address'), value: o.address),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(title: context.t('items')),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final it in o.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${context.t('quantity')} ${it.quantity} x ${Fmt.money(context, it.unitPrice)}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Fmt.money(context, it.lineTotal),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                InfoRow(
                  label: context.t('subtotal'),
                  value: Fmt.money(context, o.subtotal),
                ),
                InfoRow(
                  label: context.t('delivery_fee'),
                  value: Fmt.money(context, o.deliveryFee),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.t('total'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        Fmt.money(context, o.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(title: context.t('order_notes')),
          AppTextField(
            controller: _note,
            label: context.t('add_note'),
            maxLines: 3,
            minLines: 2,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () {
                data.setOrderNote(o.id, _note.text.trim());
                showSnack(context, context.t('status_change_local'));
              },
              child: Text(context.t('save_note')),
            ),
          ),
          const SizedBox(height: 12),
          if (data.isDemo || !data.backendConfigured) ...[
            NoticeBanner(message: context.t('status_change_local')),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: _busy || o.status == OrderStatus.cancelled
                ? null
                : () => _changeStatus(data, o),
            icon: const Icon(AppIcons.edit, size: 18),
            label: Text(context.t('update_status')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => CourierScreen(initialOrderId: o.id),
              ),
            ),
            icon: const Icon(AppIcons.courier, size: 18),
            label: Text(context.t('create_shipment')),
          ),
          if (cancellable) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _cancel(data, o),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
              ),
              icon: const Icon(AppIcons.close, size: 18),
              label: Text(context.t('cancel_order')),
            ),
          ],
        ],
      ),
    );
  }
}
