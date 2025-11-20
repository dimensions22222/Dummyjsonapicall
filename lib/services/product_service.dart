import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';
class ProductService {
  static const String baseUrl = "https://dummyjson.com/products";

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List products = data["products"];
      return products.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<Product> getProduct(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load product");
    }
  }
}
