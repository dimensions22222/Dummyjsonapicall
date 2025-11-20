import 'package:flutter/material.dart';
import 'package:project_api/model/product.dart';
import '../services/product_service.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService service = ProductService();
  late Future<List<Product>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = service.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: FutureBuilder<List<Product>>(
        future: productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final products = snapshot.data ?? [];

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];

              return ListTile(
                leading: Image.network(p.thumbnail, width: 50),
                title: Text(p.title),
                subtitle: Text("Price: \$${p.price}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(id: p.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
