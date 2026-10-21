import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import 'product_form_screen.dart';
import 'products_screen.dart' show ProductThumb;

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  Future<void> _delete(BuildContext context, AppData data, String id) async {
    final ok = await confirmDialog(
      context,
      title: context.t('delete_product_title'),
      message: context.t('delete_product_msg'),
      confirmLabel: context.t('delete'),
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final res = await data.deleteProduct(id);
    if (!context.mounted) return;
    showSnack(
      context,
      res == null ? context.t('settings_saved') : context.t(res),
      error: res == 'error_generic' || res == 'offline_msg',
    );
    if (res == null || res == 'product_saved_local') Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final found = data.products.where((p) => p.id == productId);
    if (found.isEmpty) {
      return AppScaffold(
        title: context.t('product_details'),
        body: EmptyState(
          icon: AppIcons.products,
          title: context.t('no_results'),
        ),
      );
    }
    final p = found.first;
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: context.t('product_details'),
      actions: [
        IconButton(
          tooltip: context.t('edit'),
          icon: const Icon(AppIcons.edit),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ProductFormScreen(productId: p.id),
            ),
          ),
        ),
      ],
      body: PageBody(
        children: [
          Center(child: ProductThumb(product: p, size: 140)),
          const SizedBox(height: 16),
          Text(
            p.name,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Chips.stock(context, p.stockLevel),
              Chips.product(context, p.status),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                InfoRow(
                  label: context.t('price'),
                  value: Fmt.money(context, p.price),
                ),
                InfoRow(
                  label: context.t('sku'),
                  value: p.sku.isEmpty ? '-' : p.sku,
                ),
                InfoRow(label: context.t('stock'), value: '${p.stock}'),
                InfoRow(
                  label: context.t('category'),
                  value: context.t(p.category),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      context.t('low_stock_threshold', {
                        'n': '${p.lowStockThreshold}',
                      }),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(title: context.t('description')),
          AppCard(
            child: Text(
              p.description.isEmpty ? '-' : p.description,
              style: const TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _delete(context, data, p.id),
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
            ),
            icon: const Icon(AppIcons.delete, size: 18),
            label: Text(context.t('delete')),
          ),
        ],
      ),
    );
  }
}
