// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:seller_center/Controller/Authentication/auth_services.dart';
import 'package:seller_center/Controller/Interface/interface_controller.dart';
import 'package:seller_center/View/Components/large_category_tile.dart';
import 'package:seller_center/View/Interface/Featured%20Products/featured_products.dart';

class InterfacePage extends StatefulWidget {
  const InterfacePage({super.key});

  @override
  State<InterfacePage> createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {
  //  Instance for Auth Services
  final AuthServices authServices = AuthServices();

  // Use lazy loading for better performance
  late final InterfaceController interfaceController;

  @override
  void initState() {
    super.initState();
    // Initialize controller in initState
    interfaceController = Provider.of<InterfaceController>(
      context,
      listen: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: _buildBody(size),
    );
  }

  Widget _buildBody(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: size.height * 0.02,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Featured Categories",
            style: TextStyle(
              color: Colors.yellow.shade900,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
              fontSize: size.height * 0.03,
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: interfaceController.largeCategoryItems.length,
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(5.0),
                  child: LargeCategoryTile(
                    backgroundImage:
                        interfaceController.largeCategoryItems[index],
                    onTap:
                        () => Navigator.of(context).push(
                          _elegantRoute(
                            FeaturedProducts(
                              category:
                                  interfaceController
                                      .largeCategoryTitles[index],
                            ),
                          ),
                        ),
                    title: interfaceController.largeCategoryTitles[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PageRouteBuilder _elegantRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = Tween<double>(begin: 0, end: 1).animate(animation);
        var scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
        );
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
