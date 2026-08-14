import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:grocerylist/data/models/models.dart';

class ShareService {
  static Future<void> shareList(
    ShoppingList list,
    List<GroceryItem> items,
  ) async {
    final checkedItems = items.where((item) => item.isChecked).toList();
    final uncheckedItems = items.where((item) => !item.isChecked).toList();

    final buffer = StringBuffer();
    buffer.writeln('🛒 ${list.name}');
    buffer.writeln('');

    if (checkedItems.isNotEmpty) {
      buffer.writeln('✅ Completed:');
      for (final item in checkedItems) {
        buffer.writeln('✓ ${item.name} (${item.quantity} ${item.unit})');
      }
      buffer.writeln('');
    }

    if (uncheckedItems.isNotEmpty) {
      buffer.writeln('📝 Still needed:');
      for (final item in uncheckedItems) {
        buffer.writeln('○ ${item.name} (${item.quantity} ${item.unit})');
      }
    }

    buffer.writeln('');
    buffer.writeln('Shared from Shopping list - Grocery Planner 📱');

    await Share.share(
      buffer.toString(),
      subject: '${list.name} - Shopping list - Grocery Planner',
    );
  }

  static Future<void> shareItem(GroceryItem item, String listName) async {
    final text =
        '''
🛒 Grocery Item from "$listName"

📦 ${item.name}
📊 Quantity: ${item.quantity} ${item.unit}
📝 Notes: ${item.notes.isNotEmpty ? item.notes : 'None'}
${item.isChecked ? '✅ Completed' : '⏳ Pending'}

Shared from Shopping list - Grocery Planner 📱
''';

    await Share.share(text, subject: '${item.name} - Grocery Item');
  }

  static Future<void> shareApp() async {
    const text = '''
🛒 Shopping list - Grocery Planner

Your AI-powered shopping assistant!

✨ Features:
• AI-powered item suggestions
• Voice input
• Barcode scanning
• Smart categorization
• Cloud sync
• Premium features

Download now: [Play Store Link]

#ShoppingList #GroceryPlanner #ShoppingApp #AIAssistant
''';

    await Share.share(text, subject: 'Check out Shopping list - Grocery Planner!');
  }

  static Future<void> shareMultipleItems(
    List<GroceryItem> items,
    String listName,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('🛒 Selected items from "$listName"');
    buffer.writeln('');

    for (final item in items) {
      buffer.writeln(
        '${item.isChecked ? '✅' : '○'} ${item.name} (${item.quantity} ${item.unit})',
      );
    }

    buffer.writeln('');
    buffer.writeln('Shared from Shopping list - Grocery Planner 📱');

    await Share.share(buffer.toString(), subject: 'Selected Grocery Items');
  }

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}

