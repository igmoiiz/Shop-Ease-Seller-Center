// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:seller_center/Controller/Authentication/auth_services.dart';
import 'package:seller_center/Controller/Bottom%20Nav%20Bar/bottom_nav_bar_provider.dart';
import 'package:seller_center/View/Components/drawer_component.dart';
import 'package:seller_center/View/Interface/about_page.dart';
import 'package:seller_center/View/Interface/analytics.dart';
import 'package:seller_center/View/Interface/interface.dart';
import 'package:seller_center/View/Interface/Orders/completed_orders_page.dart';
import 'package:seller_center/View/Interface/Orders/orders_page.dart';
import 'package:seller_center/View/Interface/upload_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final AuthServices authServices = AuthServices();
  @override
  Widget build(BuildContext context) {
    //List of Pages
    final List<Widget> pages = [
      InterfacePage(),
      UploadPage(),
      OrdersPage(),
      AnalyticsPage(),
    ];
    return Consumer<BottomNavProvider>(
      builder: (context, bottomNav, child) {
        final size = MediaQuery.sizeOf(context);
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          drawer: Drawer(
            backgroundColor: Colors.grey.shade100,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: Colors.yellow.shade700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Seller Ease",
                          style: TextStyle(
                            color: Colors.black,
                            letterSpacing: 2,
                            fontSize: size.height * 0.03,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.lobsterTwo().fontFamily,
                          ),
                        ),
                        Text(
                          "One stop shop for all needs",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.height * 0.018,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DrawerComponent(
                  title: "About Us",
                  icon: Icons.info_outline,
                  onTap:
                      () => Navigator.of(
                        context,
                      ).push(_elegantRoute(AboutPage())).then((value) {
                        Navigator.of(context).pop();
                      }),
                  subtitle: "Know more about us",
                ),
                DrawerComponent(
                  title: "Completed Orders",
                  icon: Icons.check_circle_outline,
                  onTap:
                      () => Navigator.of(context)
                          .push(_elegantRoute(CompletedOrdersPage()))
                          .then((value) {
                            Navigator.of(context).pop();
                          }),
                  subtitle: "View all completed orders",
                ),
                const Spacer(),
                const Divider(),
                // Add drawer items here
                DrawerComponent(
                  title: "Sign Out",
                  icon: Icons.logout_rounded,
                  onTap:
                      () => authServices
                          .signOutAndEndSession(context)
                          .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.green.shade700,
                                content: Text(
                                  "Hope to see you soon!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: .5,
                                    fontFamily:
                                        GoogleFonts.urbanist().fontFamily,
                                  ),
                                ),
                              ),
                            );
                          })
                          .onError((error, stackTrace) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.red.shade700,
                                content: Text(
                                  "Error Occurred: $error",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: .5,
                                    fontFamily:
                                        GoogleFonts.urbanist().fontFamily,
                                  ),
                                ),
                              ),
                            );
                          }),
                  subtitle: "See you Soon!",
                ),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.grey.shade100,
            iconTheme: IconThemeData(color: Colors.yellow.shade800),
            elevation: 0.0,
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade800.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    color: Colors.yellow.shade800,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Seller Ease",
                  style: TextStyle(
                    fontFamily: GoogleFonts.lobsterTwo().fontFamily,
                    color: Colors.yellow.shade800,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),
          body: pages[bottomNav.selectedIndex],
          bottomNavigationBar: CurvedNavigationBar(
            onTap: bottomNav.changeIndex,
            backgroundColor: Colors.grey.shade100,
            color: Colors.yellow.shade700,
            animationCurve: Curves.easeIn,
            animationDuration: Duration(milliseconds: 200),
            buttonBackgroundColor: Colors.yellow.shade800,
            items: [
              Icon(Iconsax.home, color: Colors.white),
              Icon(Iconsax.add_circle, color: Colors.white),
              Icon(Icons.inventory_rounded, color: Colors.white),
              Icon(Iconsax.graph, color: Colors.white),
            ],
          ),
        );
      },
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
