import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../utils/validators.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';
import '../onboarding/onboarding_screen.dart' show kBusinessTypes;

/// Add or edit a product. When [productId] is null a new product is created.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});
  final String? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _sku = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  String _category = 'type_fashion';
  ProductStatus _status = ProductStatus.published;
  String? _imagePath;
  Product? _existing;
  bool _saving = false;
  String? _imageError;

  bool get _isNew => widget.productId == null;

  @override
  void initState() {
    super.initState();
    if (!_isNew) {
      final list = context.read<AppData>().products.where(
        (p) => p.id == widget.productId,
      );
      if (list.isNotEmpty) {
        _existing = list.first;
        final p = _existing!;
        _name.text = p.name;
        _desc.text = p.description;
        _sku.text = p.sku;
        _price.text = p.price == p.price.roundToDouble()
            ? '${p.price.round()}'
            : '${p.price}';
        _stock.text = '${p.stock}';
        _category = p.category;
        _status = p.status;
        _imagePath = p.imagePath;
      }
    } else {
      _stock.text = '0';
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _sku, _price, _stock]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _imageError = null);
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (x != null && mounted) setState(() => _imagePath = x.path);
    } catch (_) {
      if (mounted) setState(() => _imageError = context.t('image_failed'));
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final data = context.read<AppData>();
    final id =
        _existing?.id ?? 'local-${DateTime.now().microsecondsSinceEpoch}';
    final product = Product(
      id: id,
      name: _name.text.trim(),
      description: _desc.text.trim(),
      sku: _sku.text.trim(),
      price: double.parse(_price.text.trim()),
      stock: int.parse(_stock.text.trim()),
      category: _category,
      status: _status,
      imagePath: _imagePath,
      imageUrl: _existing?.imageUrl,
    );
    setState(() => _saving = true);
    final res = await data.saveProduct(product, isNew: _isNew);
    if (!mounted) return;
    setState(() => _saving = false);
    if (res == 'error_generic' || res == 'offline_msg') {
      showSnack(context, context.t(res!), error: true);
      return;
    }
    showSnack(
      context,
      res == null ? context.t('settings_saved') : context.t(res),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final data = context.watch<AppData>();
    return AppScaffold(
      title: _isNew ? context.t('add_product') : context.t('edit_product'),
      body: Form(
        key: _form,
        child: PageBody(
          children: [
            if (data.isDemo || !data.backendConfigured) ...[
              NoticeBanner(
                title: context.t('preview_only'),
                message: context.t('product_saved_local'),
              ),
              const SizedBox(height: 16),
            ],
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          _imagePath != null && File(_imagePath!).existsSync()
                          ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  AppIcons.image,
                                  color: scheme.primary,
                                  size: 30,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  context.t('select_image'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: _pickImage,
                        child: Text(
                          _imagePath == null
                              ? context.t('select_image')
                              : context.t('change_image'),
                        ),
                      ),
                      if (_imagePath != null)
                        TextButton(
                          onPressed: () => setState(() => _imagePath = null),
                          child: Text(context.t('remove_image')),
                        ),
                    ],
                  ),
                  if (_imageError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _imageError!,
                        style: TextStyle(color: scheme.error, fontSize: 12.5),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _name,
              label: context.t('product_name'),
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(context, v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _desc,
              label: context.t('description'),
              maxLines: 4,
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _sku,
              label: '${context.t('sku')} (${context.t('optional')})',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _price,
                    label: context.t('price'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.price(context, v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _stock,
                    label: context.t('stock'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.stock(context, v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppDropdown<String>(
              label: context.t('category'),
              value: _category,
              items: [
                for (final c in kBusinessTypes)
                  DropdownMenuItem(value: c, child: Text(context.t(c))),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 14),
            AppDropdown<ProductStatus>(
              label: context.t('product_status'),
              value: _status,
              items: [
                DropdownMenuItem(
                  value: ProductStatus.published,
                  child: Text(context.t('status_published')),
                ),
                DropdownMenuItem(
                  value: ProductStatus.draft,
                  child: Text(context.t('status_draft')),
                ),
                DropdownMenuItem(
                  value: ProductStatus.archived,
                  child: Text(context.t('status_archived')),
                ),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 24),
            LoadingButton(
              label: context.t('save'),
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
