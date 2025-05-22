import 'package:flutter/material.dart';
import 'order.dart';
import 'order_storage.dart';

void main() {
  runApp(OrderApp());
}

class OrderApp extends StatefulWidget {
  @override
  _OrderAppState createState() => _OrderAppState();
}

class _OrderAppState extends State<OrderApp> {
  List<Order> orders = [];
  String searchTerm = "";

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    final data = await OrderStorage.readOrders();
    setState(() {
      orders = data;
    });
  }

  void addOrder(Order order) async {
    setState(() {
      orders.add(order);
    });
    await OrderStorage.writeOrders(orders);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order Added')),
    );
  }

  void _deleteOrder(Order order) async {
    setState(() {
      orders.remove(order);
    });
    await OrderStorage.writeOrders(orders);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order Deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = searchTerm.isEmpty
        ? orders
        : orders
        .where((o) => o.itemName.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Order Management")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: InputDecoration(
                    labelText: 'Search by Item Name', border: OutlineInputBorder()),
                onChanged: (value) {
                  setState(() {
                    searchTerm = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final order = filtered[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(order.item[0])),
                      title: Text("${order.itemName} (${order.currency} ${order.price})",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Item: ${order.item} - Quantity: ${order.quantity}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOrder(filtered[index]),
                      ),

                    ),
                  );
                },
              ),
            ),
            OrderForm(onAdd: addOrder),
          ],
        ),
      ),
    );
  }
}


class OrderForm extends StatefulWidget {
  final Function(Order) onAdd;

  OrderForm({required this.onAdd});

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _currencyController = TextEditingController();
  final _quantityController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newOrder = Order(
        item: _itemController.text,
        itemName: _itemNameController.text,
        price: double.parse(_priceController.text),
        currency: _currencyController.text,
        quantity: int.parse(_quantityController.text),
      );
      widget.onAdd(newOrder);
      _itemController.clear();
      _itemNameController.clear();
      _priceController.clear();
      _currencyController.clear();
      _quantityController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("➕ Add New Order", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _itemController,
                decoration: InputDecoration(labelText: 'Item'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(labelText: 'Item Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _currencyController,
                decoration: InputDecoration(labelText: 'Currency'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (int.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _submit, child: Text("Insert Order")),
            ],
          ),
        ),
      ),
    );
  }
}
