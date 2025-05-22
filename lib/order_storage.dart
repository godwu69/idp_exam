import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'order.dart';

class OrderStorage {
  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/orders.json');
  }

  static Future<List<Order>> readOrders() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        await file.writeAsString('[]');
        return [];
      }
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      print('Error reading orders: $e');
      return [];
    }
  }

  static Future<void> writeOrders(List<Order> orders) async {
    final file = await _getLocalFile();
    final jsonString = jsonEncode(orders.map((o) => o.toJson()).toList());
    await file.writeAsString(jsonString);
  }
}
