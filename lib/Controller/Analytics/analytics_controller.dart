import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  Map<String, int> categoryProductCounts = {};
  int totalProducts = 0;
  List<Map<String, dynamic>> recentProducts = [];
  Map<String, double> categoryRevenue = {};
  double totalRevenue = 0;
  List<Map<String, dynamic>> dailySalesData = [];

  // Categories from InterfaceController
  final List<String> categories = [
    'Clothing',
    'Electronics',
    'Household',
    'Cosmetics',
    'Female FootWear',
    'Male FootWear',
    'Male Gear',
    'Female Gear',
    'Men Wear',
    'Women Wear',
    'Furniture',
    'Smoke',
  ];

  Future<void> fetchAnalytics() async {
    try {
      isLoading = true;
      notifyListeners();

      // Reset counters
      categoryProductCounts.clear();
      categoryRevenue.clear();
      totalProducts = 0;
      totalRevenue = 0;
      dailySalesData.clear();

      // Create a map to store daily sales data
      Map<String, Map<String, dynamic>> dailyData = {};

      // Fetch data for each category
      for (String category in categories) {
        final QuerySnapshot snapshot =
            await _firestore.collection(category).get();

        int count = snapshot.docs.length;
        double revenue = 0;

        // Calculate revenue for this category and collect daily sales data
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          double price = (data['price'] ?? 0.0).toDouble();
          revenue += price;

          // Get the date from createdAt timestamp
          Timestamp timestamp = data['createdAt'] as Timestamp;
          DateTime date = timestamp.toDate();
          String dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

          if (!dailyData.containsKey(dateKey)) {
            dailyData[dateKey] = {'date': date, 'sales': 0.0, 'products': 0};
          }

          dailyData[dateKey]!['sales'] =
              (dailyData[dateKey]!['sales'] as double) + price;
          dailyData[dateKey]!['products'] =
              (dailyData[dateKey]!['products'] as int) + 1;
        }

        categoryProductCounts[category] = count;
        categoryRevenue[category] = revenue;

        totalProducts += count;
        totalRevenue += revenue;
      }

      // Convert daily data to sorted list
      List<Map<String, dynamic>> tempDailyData =
          dailyData.entries.map((entry) {
            return {
              'date': entry.value['date'],
              'sales': entry.value['sales'],
              'products': entry.value['products'],
            };
          }).toList();

      // Sort by date
      tempDailyData.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
      );

      // Keep only last 30 days of data
      if (tempDailyData.length > 30) {
        tempDailyData = tempDailyData.sublist(tempDailyData.length - 30);
      }

      dailySalesData = tempDailyData;

      // Fetch recent products (limited to 10)
      List<Future<QuerySnapshot>> queries =
          categories.map((category) {
            return _firestore
                .collection(category)
                .orderBy('createdAt', descending: true)
                .limit(3)
                .get();
          }).toList();

      List<QuerySnapshot> results = await Future.wait(queries);

      recentProducts.clear();
      for (var snapshot in results) {
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          recentProducts.add(data);
        }
      }

      // Sort recent products by creation date
      recentProducts.sort((a, b) {
        Timestamp aTime = a['createdAt'] as Timestamp;
        Timestamp bTime = b['createdAt'] as Timestamp;
        return bTime.compareTo(aTime);
      });

      // Limit to most recent 10 products
      if (recentProducts.length > 10) {
        recentProducts = recentProducts.sublist(0, 10);
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Error fetching analytics: $e');
    }
  }
}
