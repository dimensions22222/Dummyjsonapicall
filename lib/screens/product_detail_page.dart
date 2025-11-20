import 'package:flutter/material.dart';
import 'package:project_api/model/product.dart';
import '../services/product_service.dart';

class ProductDetailPage extends StatelessWidget {
  final int id;

  const ProductDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final ProductService service = ProductService();

    return Scaffold(
      appBar: AppBar(title: Text("Product $id")),
      body: FutureBuilder<Product>(
        future: service.getProduct(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final product = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Price: \$${product.price}"),
                Text("Rating: ⭐ ${product.rating}"),
                const SizedBox(height: 20),
                Expanded(child: Image.network(product.thumbnail)),
              ],
            ),
          );
        },
      ),
    );
  }
}
