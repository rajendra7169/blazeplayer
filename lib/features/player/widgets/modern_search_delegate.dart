import 'package:flutter/material.dart';

enum SearchFilter { all, songs, albums, artists, playlists }

class ModernSearchDelegate<T> extends SearchDelegate<String> {
  final List<T> items;
  final String Function(T) getTitle;
  final String Function(T) getSubtitle;
  final Function(T) onItemTap;
  final Function(String)? onQueryChanged;
  final String? Function(T)? getAlbum;
  final String? Function(T)? getArtist;
  final String? Function(T)? getType;

  SearchFilter _selectedFilter = SearchFilter.all;

  ModernSearchDelegate({
    required this.items,
    required this.getTitle,
    required this.getSubtitle,
    required this.onItemTap,
    this.onQueryChanged,
    this.getAlbum,
    this.getArtist,
    this.getType,
  });

  List<T> _filterItems() {
    List<T> filtered = items;

    // Apply filter type
    if (_selectedFilter != SearchFilter.all) {
      filtered = filtered.where((item) {
        final type = getType?.call(item)?.toLowerCase() ?? '';
        switch (_selectedFilter) {
          case SearchFilter.songs:
            return type == 'song' || type.isEmpty;
          case SearchFilter.albums:
            return type == 'album';
          case SearchFilter.artists:
            return type == 'artist';
          case SearchFilter.playlists:
            return type == 'playlist';
          default:
            return true;
        }
      }).toList();
    }

    // Apply search query
    if (query.isEmpty) return filtered;
    return filtered
        .where(
          (item) =>
              getTitle(item).toLowerCase().contains(query.toLowerCase()) ||
              (getAlbum
                      ?.call(item)
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false) ||
              (getArtist
                      ?.call(item)
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        titleSpacing: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        isDense: true,
        hintStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.black38,
          fontSize: 14,
          height: 1.8,
        ),
        suffixIconColor: isDark ? Colors.white54 : Colors.black38,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  PreferredSizeWidget? buildBottom(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);

    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip(
                    'All',
                    SearchFilter.all,
                    isDark,
                    accentColor,
                    setState,
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    'Songs',
                    SearchFilter.songs,
                    isDark,
                    accentColor,
                    setState,
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    'Albums',
                    SearchFilter.albums,
                    isDark,
                    accentColor,
                    setState,
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    'Artists',
                    SearchFilter.artists,
                    isDark,
                    accentColor,
                    setState,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, size: 24),
      padding: const EdgeInsets.only(left: 4),
      onPressed: () => close(context, ''),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: IconButton(
          icon: Icon(
            Icons.clear_rounded,
            size: 20,
            color: query.isEmpty
                ? (isDark ? Colors.white24 : Colors.black26)
                : (isDark ? Colors.white54 : Colors.black54),
          ),
          onPressed: query.isEmpty
              ? null
              : () {
                  query = '';
                  onQueryChanged?.call(query);
                },
        ),
      ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF232323)
            : Colors.white,
      );
    }

    final suggestions = _filterItems();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF232323) : Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return ListTile(
            title: Text(
              getTitle(item),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              getSubtitle(item),
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
            ),
            onTap: () {
              onItemTap(item);
              onQueryChanged?.call(query);
              close(context, '');
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    SearchFilter filter,
    bool isDark,
    Color accentColor,
    StateSetter setState,
  ) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
          height: 1.2,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      backgroundColor: isDark
          ? const Color(0xFF2C2C2C)
          : const Color(0xFFF5F5F5),
      selectedColor: accentColor,
      checkmarkColor: Colors.transparent,
      showCheckmark: false,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      labelPadding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide.none,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  String get searchFieldLabel => 'Search...';
}
