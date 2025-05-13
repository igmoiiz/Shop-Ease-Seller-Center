// ignore_for_file: library_prefixes

import 'dart:math' as Math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seller_center/Controller/Database/database_services.dart';
import 'package:seller_center/View/Components/order_card.dart';

class CompletedOrdersPage extends StatefulWidget {
  const CompletedOrdersPage({super.key});

  @override
  State<CompletedOrdersPage> createState() => _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends State<CompletedOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: Text(
          "Completed Orders",
          style: TextStyle(
            color: Colors.yellow.shade800,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.urbanist().fontFamily,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellow.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Consumer<DatabaseServices>(
            builder: (context, databaseServices, child) {
              return StreamBuilder(
                stream:
                    databaseServices.fireStore
                        .collection("completedOrders")
                        .orderBy('completedAt', descending: true)
                        .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.yellow.shade800,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          "Unexpected Error Occurred: ${snapshot.error}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: .5,
                            fontFamily: GoogleFonts.urbanist().fontFamily,
                          ),
                        ),
                      ),
                    );
                  }

                  final documents = snapshot.data.docs;

                  return Expanded(
                    child:
                        documents.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No completed orders yet",
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.urbanist().fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Completed orders will appear here",
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.urbanist().fontFamily,
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.sizeOf(context).height * 0.01,
                              ),
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final orderData = documents[index].data();
                                final orderId = documents[index].id;

                                // Extract order details with fallbacks
                                final orderName =
                                    orderData['orderName'] ??
                                    'Order #${orderId.substring(0, Math.min(6, orderId.length))}';

                                // Format the completion date
                                final completedDate =
                                    orderData['completedAt'] != null
                                        ? DateFormat('MMM dd, yyyy').format(
                                          (orderData['completedAt']
                                                  as Timestamp)
                                              .toDate(),
                                        )
                                        : DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(DateTime.now());

                                // Always set status to completed
                                const orderStatus = 'Completed';
                                final orderAmount =
                                    orderData['totalAmount'] ?? 0.0;
                                final orderItems = orderData['items'] ?? [];

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.sizeOf(context).width *
                                        0.025,
                                    vertical:
                                        MediaQuery.sizeOf(context).height *
                                        0.01,
                                  ),
                                  child: OrderCard(
                                    orderId: orderId,
                                    orderName: orderName,
                                    orderDate: "Completed on: $completedDate",
                                    orderStatus: orderStatus,
                                    statusColor: Colors.green,
                                    orderAmount: orderAmount,
                                    itemCount: orderItems.length,
                                    index: index,
                                    onTap: () {},

                                    // Navigate to order details or expand
                                    // showOrderDetails(
                                    //   context,
                                    //   orderData,
                                    //   orderId,
                                    // );
                                  ),
                                );
                              },
                            ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
