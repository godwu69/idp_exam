class Order {
  final String item;
  final String itemName;
  final double price;
  final String currency;
  final int quantity;

  Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    item: json['item'] as String,
    itemName: json['itemName'] as String,
    price: (json['price'] as num).toDouble(),
    currency: json['currency'] as String,
    quantity: json['quantity'] as int,
  );

  Map<String, dynamic> toJson() => {
    'item': item,
    'itemName': itemName,
    'price': price,
    'currency': currency,
    'quantity': quantity,
  };
}
