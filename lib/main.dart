import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seller_center/Controller/Analytics/analytics_controller.dart';
import 'package:seller_center/Controller/Bottom%20Nav%20Bar/bottom_nav_bar_provider.dart';
import 'package:seller_center/Controller/Cart%20Services/cart_services.dart';
import 'package:seller_center/Controller/Database/database_services.dart';
import 'package:seller_center/Controller/Interface/interface_controller.dart';
import 'package:seller_center/View/home_page.dart';
import 'package:seller_center/Utils/consts.dart';
import 'package:seller_center/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //  Firebase Intialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) {
        log("Firebase Initialized");
        // Initializing Supabase
        Supabase.initialize(url: url, anonKey: anonKey)
            .then((value) {
              log("Supabase Initialized");
              runApp(
                MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => InterfaceController(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => BottomNavProvider(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => DatabaseServices(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => AnalyticsController(),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => CartServices(),
                    ),
                  ],
                  child: MainApp(),
                ),
              );
            })
            .onError((error, stackTrace) {
              log("Supabase Initialization Error: $error");
            });
      })
      .onError((error, stackTrace) {
        log("Firebase Initialization Error: $error");
      });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SellerEase",
      home: HomePage(),
    );
  }
}
