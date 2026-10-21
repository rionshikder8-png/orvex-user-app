import 'dart:io';

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
import '../onboarding/onboarding_screen.dart' show kBusinessTypes;
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final q = _query.trim().toLowerCase();
    final list = data.products.where((p) {
      if (_category != null && p.category != _category) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('products'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const ProductFormScreen()),
        ),
        icon: const Icon(AppIcons.add),
        label: Text(context.t('add_product')),
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
                    hint: context.t('search_products'),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilterChips<String?>(
                      options: {
                        null: context.t('all'),
                        for (final c in kBusinessTypes) c: context.t(c),
                      },
                      selected: _category,
                      onSelected: (v) => setState(() => _category = v),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: data.products.isEmpty
                  ? EmptyState(
                      icon: AppIcons.products,
                      title: context.t('no_products'),
                      message: context.t('no_products_hint'),
                      actionLabel: context.t('add_product'),
                      onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const ProductFormScreen(),
                        ),
                      ),
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
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ProductTile(p: list[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductThumb extends StatelessWidget {
  const ProductThumb({super.key, required this.product, this.size = 56});
  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget child;
    if (product.imagePath != null && File(product.imagePath!).existsSync()) {
      child = Image.file(
        File(product.imagePath!),
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    } else if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      child = Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, _, _) =>
            Icon(AppIcons.image, color: scheme.onSurfaceVariant),
      );
    } else {
      child = Icon(AppIcons.image, color: scheme.onSurfaceVariant);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        color: scheme.primary.withValues(alpha: 0.07),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.p});
  final Product p;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailScreen(productId: p.id),
        ),
      ),
      child: Row(
        children: [
          ProductThumb(product: p),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  p.sku.isEmpty
                      ? context.t(p.category)
                      : '${p.sku}  |  ${context.t(p.category)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Chips.stock(context, p.stockLevel),
                    if (p.status != ProductStatus.published)
                      Chips.product(context, p.status),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Fmt.money(context, p.price),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '${p.stock}',
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
