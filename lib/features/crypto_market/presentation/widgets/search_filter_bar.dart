import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SearchFilterBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSortChanged;
  final String? initialSearch;
  final String? initialSort;

  const SearchFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onSortChanged,
    this.initialSearch,
    this.initialSort,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late final TextEditingController _searchController;
  late String _selectedSort;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch ?? '');
    _selectedSort = widget.initialSort ?? 'market_cap';
    _searchController.addListener(_onTextChange);
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  void _onSearchInput(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      widget.onSearchChanged(query);
    });
  }

  void _onClearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    widget.onSearchChanged('');
  }

  @override
  void didUpdateWidget(covariant SearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final expectedSearch = widget.initialSearch ?? '';
    if (expectedSearch != _searchController.text) {
      _searchController.text = expectedSearch;
    }
    final expectedSort = widget.initialSort ?? 'market_cap';
    if (expectedSort != _selectedSort) {
      setState(() {
        _selectedSort = expectedSort;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onTextChange);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final containerBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = theme.colorScheme.onSurface;
    final hintColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final iconColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accentColor = isDark ? AppColors.accentCyanBright : AppColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textColor, fontSize: 14),
                onChanged: _onSearchInput,
                decoration: InputDecoration(
                  hintText: 'Search crypto (e.g. BTC, Solana)...',
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: iconColor,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: iconColor,
                            size: 18,
                          ),
                          onPressed: _onClearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: containerBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
              boxShadow: isDark
                  ? []
                  : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSort,
                dropdownColor: containerBg,
                icon: Icon(
                  Icons.tune_rounded,
                  color: accentColor,
                  size: 20,
                ),
                style: TextStyle(color: textColor, fontSize: 13),
                items: [
                  DropdownMenuItem(
                    value: 'market_cap',
                    child: Text('Market Cap', style: TextStyle(color: textColor)),
                  ),
                  DropdownMenuItem(
                    value: 'price',
                    child: Text('Price', style: TextStyle(color: textColor)),
                  ),
                  DropdownMenuItem(
                    value: 'change',
                    child: Text('24h Change', style: TextStyle(color: textColor)),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSort = val;
                    });
                    widget.onSortChanged(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
