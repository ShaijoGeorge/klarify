import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheViewerScreen extends StatefulWidget {
  const CacheViewerScreen({super.key});

  @override
  State<CacheViewerScreen> createState() => _CacheViewerScreenState();
}

class _CacheViewerScreenState extends State<CacheViewerScreen> {
  Map<String, dynamic> _cacheData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCache();
  }

  Future<void> _loadCache() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    final Map<String, dynamic> data = {};
    for (var key in keys) {
      data[key] = prefs.get(key);
    }
    
    setState(() {
      _cacheData = data;
      _isLoading = false;
    });
  }

  Future<void> _editValue(String key, dynamic currentValue) async {
    final controller = TextEditingController(text: currentValue.toString());
    
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newValue != null && newValue != currentValue.toString()) {
      final prefs = await SharedPreferences.getInstance();
      
      // Attempt to save in the correct type, falling back to String
      if (currentValue is bool) {
        await prefs.setBool(key, newValue.toLowerCase() == 'true');
      } else if (currentValue is int) {
        await prefs.setInt(key, int.tryParse(newValue) ?? 0);
      } else if (currentValue is double) {
        await prefs.setDouble(key, double.tryParse(newValue) ?? 0.0);
      } else {
        await prefs.setString(key, newValue);
      }
      
      _loadCache();
    }
  }

  Future<void> _addKeyValue() async {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cache Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Key (e.g. GEMINI_API_KEY)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (keyController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'key': keyController.text,
                  'value': valueController.text,
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(result['key']!, result['value']!);
      _loadCache();
    }
  }

  Future<void> _deleteKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    _loadCache();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _addKeyValue,
            tooltip: 'Add Key',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _cacheData.isEmpty
          ? Center(
              child: Text(
                'Cache is empty',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _cacheData.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final key = _cacheData.keys.elementAt(index);
                final value = _cacheData[key];
                
                return Card(
                  elevation: 0,
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      key,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        value.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          onPressed: () => _editValue(key, value),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, size: 20),
                          color: scheme.error,
                          onPressed: () => _deleteKey(key),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
