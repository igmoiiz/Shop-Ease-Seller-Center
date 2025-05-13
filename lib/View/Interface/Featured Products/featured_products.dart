// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:seller_center/Controller/Database/database_services.dart';
import 'package:seller_center/Controller/Interface/interface_controller.dart';
import 'package:seller_center/Controller/input_controllers.dart';
import 'package:seller_center/Model/featured_product_model.dart';
import 'package:seller_center/View/Interface/Featured%20Products/featured_details.dart';

class FeaturedProducts extends StatefulWidget {
  final String category;
  const FeaturedProducts({super.key, required this.category});

  @override
  State<FeaturedProducts> createState() => _FeaturedProductsState();
}

class _FeaturedProductsState extends State<FeaturedProducts> {
  //  Instance for Input Controller
  final InputControllers inputController = InputControllers();
  //  Instance for Database Services
  final DatabaseServices databaseServices = DatabaseServices();

  // Add search functionality
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Add listener to search controller
    inputController.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    inputController.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  // Debounce search to prevent excessive rebuilds
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = inputController.searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        iconTheme: IconThemeData(color: Colors.yellow.shade800),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow.shade800.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag, color: Colors.yellow.shade800),
            ),
            const SizedBox(width: 10),
            Text(
              widget.category,
              style: TextStyle(
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                color: Colors.yellow.shade800,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.025,
          vertical: size.height * 0.02,
        ),
        child: Column(
          children: [
            // Search field
            _buildSearchField(size),
            SizedBox(height: size.height * 0.02),

            // Products grid - optimized
            Expanded(
              child: Consumer<InterfaceController>(
                builder: (context, interfaceController, _) {
                  return StreamBuilder(
                    stream:
                        interfaceController.fireStore
                            .collection(widget.category)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingIndicator();
                      }

                      if (snapshot.hasError) {
                        return _buildErrorWidget(snapshot.error);
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyStateWidget();
                      }

                      // Filter products based on search query
                      final docs =
                          _searchQuery.isEmpty
                              ? snapshot.data!.docs
                              : snapshot.data!.docs.where((doc) {
                                final title =
                                    (doc['title'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                final description =
                                    (doc['description'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                return title.contains(_searchQuery) ||
                                    description.contains(_searchQuery);
                              }).toList();

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No products match your search",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildProductGrid(docs);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Extract widgets to improve readability and performance
  Widget _buildSearchField(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
      child: TextField(
        controller: inputController.searchController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.yellow.shade800, width: 2),
          ),
          labelText: "Search for products",
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIcon: Icon(Icons.search, color: Colors.yellow.shade800),
          suffixIcon:
              inputController.searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      inputController.searchController.clear();
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(color: Colors.yellow.shade800),
    );
  }

  Widget _buildErrorWidget(dynamic error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 16),
          Text("Error: $error", style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            color: Colors.grey.shade400,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "No products found in ${widget.category}",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<dynamic> docs) {
    return GridView.builder(
      itemCount: docs.length,
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return _buildProductCard(docs[index]);
      },
    );
  }

  Widget _buildProductCard(dynamic doc) {
    // Create product object
    final product = FeaturedProduct(
      id: doc.id,
      title: doc['title'] ?? '',
      image: doc['image'] ?? '',
      price: (doc['price'] ?? 0.0).toDouble(),
      description: doc['description'] ?? '',
      category: doc['category'] ?? widget.category,
    );

    // Use Consumer only for the part that needs to rebuild
    return GestureDetector(
      
      onTap:
          () => Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      FeaturedProductDetails(product: product),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with Hero animation
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'featured_${product.id}',
                    child: Image.network(
                      doc["image"] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              color: Colors.yellow.shade800,
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade800,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        doc['category'] ?? widget.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      doc['title'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Price
                    Text(
                      "Rs.${doc['price'] ?? 0.0}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.yellow.shade900,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Description
                    Expanded(
                      child: Text(
                        doc['description'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
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
