class Product {
  String id;
  String name;
  int quantity;

  Product(this.id, this.name, this.quantity);

  Product.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    quantity = json['quantity'];
  }
}
