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
  bool isDarkMode = true;
  String selectedCategory = "All";
  List<String> categories = ["All"];

  @override
  void initState() {
    super.initState();
    productsFuture = service.getProducts();
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  bool matchCategory(Product p) {
    if (selectedCategory == "All") return true;
    return p.category.toLowerCase() == selectedCategory.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        colorScheme: isDarkMode
            ? ColorScheme.dark(
                primary: Colors.tealAccent,
                secondary: Colors.deepOrangeAccent)
            : ColorScheme.light(
                primary: Colors.blueAccent,
                secondary: Colors.orangeAccent),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Products"),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: toggleTheme,
            ),
          ],
        ),
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

            // Populate categories dynamically
            final allCategories = products.map((p) => p.category).toSet().toList();
            allCategories.sort();
            categories = ["All", ...allCategories];

            // Filter products
            final filteredProducts = products.where(matchCategory).toList();

            return Column(
              children: [
                // Filter Chips
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = cat;
                            });
                          },
                          selectedColor: Colors.tealAccent,
                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Animated Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, i) {
                        final p = filteredProducts[i];

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 500 + (i * 50)),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: _AnimatedProductCard(
                            product: p,
                            isDarkMode: isDarkMode,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Animated product card widget
class _AnimatedProductCard extends StatefulWidget {
  final Product product;
  final bool isDarkMode;
  const _AnimatedProductCard({required this.product, required this.isDarkMode});

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(id: widget.product.id),
          ),
        );
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isPressed ? 1.05 : 1.0),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  widget.product.thumbnail,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              offset: isPressed ? const Offset(0, -0.05) : Offset.zero,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      widget.product.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text("\$${widget.product.price}"),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text("${widget.product.rating}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
