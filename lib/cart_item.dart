class CartItem {
  final String id;
  final String name;
  final String image;
  final String size;
  final String color;
  final double price;
  int quantity;

  CartItem({
    String? id,
    required this.name,
    required this.image,
    required this.size,
    required this.color,
    required this.price,
    required this.quantity,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory CartItem.fromFirestore(Map<String, dynamic> data, String id) {
    return CartItem(
      id: id,
      name: data['name'] ?? 'Unknown',
      image: data['image'] ?? '',
      size: data['size'] ?? 'M',
      color: data['color'] ?? 'white',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'size': size,
      'color': color,
      'price': price,
      'quantity': quantity,
    };
  }

  // نسخة من CartItem مع تغيير الكمية
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      image: image,
      size: size,
      color:color,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}