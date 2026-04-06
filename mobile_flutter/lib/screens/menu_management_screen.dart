import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/menu_item.dart';
import '../providers/menu_provider.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/menu_item_form_sheet.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor({MenuItem? item}) async {
    final result = await showModalBottomSheet<MenuItemFormData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => MenuItemFormSheet(initialItem: item),
    );

    if (!mounted || result == null) {
      return;
    }

    final menuProvider = context.read<MenuProvider>();

    try {
      if (item == null) {
        await menuProvider.addMenuItem(
          name: result.name,
          description: result.description,
          price: result.price,
          category: result.category,
          available: result.available,
          imagePath: result.imagePath,
          imageValue: result.imageValue,
        );
      } else {
        await menuProvider.updateMenuItem(
          id: item.id,
          name: result.name,
          description: result.description,
          price: result.price,
          category: result.category,
          available: result.available,
          imagePath: result.imagePath,
          imageValue: result.imageValue,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              item == null ? 'Menu item added.' : 'Menu item updated.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _deleteItem(MenuItem item) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Archive menu item'),
            content: Text(
              'Archive ${item.name}? Existing order history will remain intact.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Archive'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    try {
      await context.read<MenuProvider>().deleteMenuItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Menu item archived.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final items = menuProvider.items.where((item) {
          final haystack = '${item.name} ${item.category} ${item.description}'
              .toLowerCase();
          return haystack.contains(_searchTerm.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: menuProvider.isSaving ? null : () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add item'),
          ),
          body: RefreshIndicator(
            onRefresh: menuProvider.loadMenuItems,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search menu items, categories, or descriptions',
                  ),
                  onChanged: (value) {
                    setState(() => _searchTerm = value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MenuStatsCard(
                        label: 'Total',
                        value: '${menuProvider.items.length}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MenuStatsCard(
                        label: 'Available',
                        value:
                            '${menuProvider.items.where((item) => item.available).length}',
                      ),
                    ),
                  ],
                ),
                if (menuProvider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded),
                      title: const Text('Menu sync issue'),
                      subtitle: Text(menuProvider.errorMessage!),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (menuProvider.isLoading && menuProvider.items.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (items.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No menu items found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term or add a new item using the floating action button.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MenuItemCard(
                        item: item,
                        isBusy: menuProvider.busyItemIds.contains(item.id),
                        onEdit: () => _openEditor(item: item),
                        onDelete: () => _deleteItem(item),
                        onToggleAvailability: () async {
                          try {
                            await context
                                .read<MenuProvider>()
                                .toggleAvailability(item);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  item.available
                                      ? '${item.name} marked unavailable.'
                                      : '${item.name} is now available.',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuStatsCard extends StatelessWidget {
  const _MenuStatsCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
