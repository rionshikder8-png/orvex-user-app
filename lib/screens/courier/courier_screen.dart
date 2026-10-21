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
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';

/// Courier hub: connection status, shipment creation, tracking, booking history.
/// Nothing is booked or tracked locally: all of it needs the backend and valid
/// official courier credentials.
class CourierScreen extends StatefulWidget {
  const CourierScreen({super.key, this.initialOrderId});
  final String? initialOrderId;

  @override
  State<CourierScreen> createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final scheme = Theme.of(context).colorScheme;
    final anyConnected = data.couriers.any(
      (c) => c.state == LinkState.connected,
    );

    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialOrderId != null ? 1 : 0,
      child: AppScaffold(
        title: context.t('couriers'),
        bottom: TabBar(
          tabs: [
            Tab(text: context.t('courier_status')),
            Tab(text: context.t('shipment_creation')),
            Tab(text: context.t('booking_history')),
          ],
        ),
        body: TabBarView(
          children: [
            // Status
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (!anyConnected) ...[
                  NoticeBanner(
                    kind: NoticeKind.warning,
                    title: context.t('not_connected'),
                    message: context.t('courier_not_connected_msg'),
                  ),
                  const SizedBox(height: 14),
                ],
                for (final c in data.couriers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      child: AdaptiveRow(
                        trailingWidthHint: 130,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            AppIcons.courier,
                            color: scheme.primary,
                            size: 20,
                          ),
                        ),
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Chips.connection(context, c.state),
                          ],
                        ),
                        trailing: [
                          TextButton(
                            onPressed: () => infoDialog(
                              context,
                              title: context.t('setup_courier'),
                              message: context.t('courier_setup_steps', {
                                'name': c.name,
                              }),
                            ),
                            child: Text(context.t('setup_courier')),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                SectionHeader(title: context.t('tracking')),
                const _TrackingBox(),
              ],
            ),
            // Shipment creation
            _ShipmentForm(initialOrderId: widget.initialOrderId),
            // History
            data.shipments.isEmpty
                ? EmptyState(
                    icon: AppIcons.courier,
                    title: context.t('no_bookings'),
                    message: context.t('no_bookings_hint'),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      for (final s in data.shipments)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.orderNumber,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    StatusChip(
                                      label: s.status,
                                      tone: Tone.info,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${context.t('tracking_id')}: ${s.trackingId}',
                                ),
                                Text(
                                  Fmt.dateTime(s.createdAt),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _TrackingBox extends StatefulWidget {
  const _TrackingBox();

  @override
  State<_TrackingBox> createState() => _TrackingBoxState();
}

class _TrackingBoxState extends State<_TrackingBox> {
  final _id = TextEditingController();
  bool _tried = false;

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _id,
            label: context.t('tracking_id'),
            hint: context.t('tracking_hint'),
            prefixIcon: AppIcons.track,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) =>
                setState(() => _tried = _id.text.trim().isNotEmpty),
          ),
          const SizedBox(height: 12),
          LoadingButton(
            label: context.t('track'),
            onPressed: () =>
                setState(() => _tried = _id.text.trim().isNotEmpty),
          ),
          if (_tried) ...[
            const SizedBox(height: 12),
            NoticeBanner(
              kind: NoticeKind.warning,
              message: context.t('tracking_unavailable'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShipmentForm extends StatefulWidget {
  const _ShipmentForm({this.initialOrderId});
  final String? initialOrderId;

  @override
  State<_ShipmentForm> createState() => _ShipmentFormState();
}

class _ShipmentFormState extends State<_ShipmentForm> {
  final _form = GlobalKey<FormState>();
  final _weight = TextEditingController(text: '0.5');
  final _cod = TextEditingController();
  String? _courier;
  String? _orderId;
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    _orderId = widget.initialOrderId;
    final data = context.read<AppData>();
    if (_orderId != null) {
      final o = data.orders.where((o) => o.id == _orderId);
      if (o.isNotEmpty) _cod.text = o.first.total.round().toString();
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _cod.dispose();
    super.dispose();
  }

  Future<void> _book() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _attempted = true);
    final data = context.read<AppData>();
    final selected = data.couriers.where((c) => c.id == _courier);
    final connected =
        selected.isNotEmpty && selected.first.state == LinkState.connected;
    if (!connected) {
      await infoDialog(
        context,
        title: context.t('booking_unavailable'),
        message: context.t('booking_unavailable_msg'),
      );
      return;
    }
    // A connected courier would be booked through the backend here. The booking
    // is shown only after the API returns a confirmed shipment.
    showSnack(context, context.t('backend_required'));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final open = data.orders
        .where(
          (o) =>
              o.status != OrderStatus.cancelled &&
              o.status != OrderStatus.delivered,
        )
        .toList();
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          NoticeBanner(
            kind: NoticeKind.warning,
            title: context.t('backend_required'),
            message: context.t('courier_not_connected_msg'),
          ),
          const SizedBox(height: 16),
          AppDropdown<String>(
            label: context.t('select_courier'),
            value: _courier,
            items: [
              for (final c in data.couriers)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _courier = v),
            validator: (v) => v == null ? context.t('required') : null,
          ),
          const SizedBox(height: 14),
          AppDropdown<String>(
            label: context.t('select_order'),
            value: open.any((o) => o.id == _orderId) ? _orderId : null,
            items: [
              for (final o in open)
                DropdownMenuItem(
                  value: o.id,
                  child: Text(
                    '${o.number}  ${o.customerName}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) {
              setState(() {
                _orderId = v;
                final o = open.where((o) => o.id == v);
                if (o.isNotEmpty) _cod.text = o.first.total.round().toString();
              });
            },
            validator: (v) => v == null ? context.t('required') : null,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  controller: _weight,
                  label: context.t('weight_kg'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').trim());
                    return (n == null || n <= 0)
                        ? context.t('invalid_number')
                        : null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _cod,
                  label: context.t('cod_amount'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = double.tryParse((v ?? '').trim());
                    return (n == null || n < 0)
                        ? context.t('invalid_number')
                        : null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LoadingButton(
            label: context.t('book_shipment'),
            icon: AppIcons.courier,
            onPressed: _book,
          ),
          if (_attempted) ...[
            const SizedBox(height: 14),
            NoticeBanner(
              title: context.t('booking_confirmation'),
              message: context.t('booking_unavailable_msg'),
              kind: NoticeKind.info,
            ),
          ],
        ],
      ),
    );
  }
}
