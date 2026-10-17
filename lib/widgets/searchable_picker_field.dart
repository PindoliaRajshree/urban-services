// File: lib/widgets/searchable_picker_field.dart
// Purpose: A form field that picks one value from a long list (e.g.
// countries, states, cities) through a searchable bottom sheet. Looks and
// validates like AddressFormField.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/address_form_field.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class SearchablePickerField extends StatefulWidget {
  const SearchablePickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    required this.onSelected,
    this.value,
    this.isLoading = false,
    this.validator,
  });

  final String label;
  final String hintText;
  final List<String> options;
  final ValueChanged<String> onSelected;

  /// The selected option; the hint is shown when null.
  final String? value;

  /// Options are still loading — shows a spinner and ignores taps.
  final bool isLoading;
  final String? Function(String?)? validator;

  @override
  State<SearchablePickerField> createState() => _SearchablePickerFieldState();
}

class _SearchablePickerFieldState extends State<SearchablePickerField> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(SearchablePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) _controller.text = widget.value ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (widget.isLoading || widget.options.isEmpty) return;
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius10r),
        ),
      ),
      builder: (_) => _PickerSheet(
        title: widget.label,
        options: widget.options,
        selected: widget.value,
      ),
    );
    if (picked != null && mounted) widget.onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AddressFormField(
      label: widget.label,
      hintText: widget.hintText,
      controller: _controller,
      readOnly: true,
      onTap: _open,
      validator: widget.validator,
      suffixIcon: widget.isLoading
          ? Padding(
              padding: EdgeInsets.all(AppDimensions.padding12w),
              child: SizedBox.square(
                dimension: AppDimensions.containerHeight16h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    this.selected,
  });

  final String title;
  final List<String> options;
  final String? selected;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final matches = q.isEmpty
        ? widget.options
        : widget.options.where((o) => o.toLowerCase().contains(q)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.padding20w,
                AppDimensions.padding15h,
                AppDimensions.padding8w,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select ${widget.title}',
                      style: customTextStyle(
                        AppTextSizes.largeTextSize,
                        AppColors.text,
                        FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
                vertical: AppDimensions.padding8h,
              ),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                style: customTextStyle(
                  AppTextSizes.smallTextSize,
                  AppColors.black,
                  FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title.toLowerCase()}',
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radius10r,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? Center(
                      child: Text(
                        'No matches',
                        style: customTextStyle(
                          AppTextSizes.smallTextSize,
                          AppColors.grey,
                          FontWeight.w400,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (_, i) {
                        final option = matches[i];
                        final isSelected = option == widget.selected;
                        return ListTile(
                          dense: true,
                          title: Text(
                            option,
                            style: customTextStyle(
                              AppTextSizes.smallTextSize,
                              isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.black,
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: AppColors.primaryDark,
                                )
                              : null,
                          onTap: () => Navigator.pop(context, option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
