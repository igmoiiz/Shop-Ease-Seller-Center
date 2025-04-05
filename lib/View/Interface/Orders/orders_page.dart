// ignore_for_file: library_prefixes

import 'dart:math' as Math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seller_center/Controller/Database/database_services.dart';
import 'package:seller_center/View/Components/order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        spacing: 15,
        children: [
          Consumer<DatabaseServices>(
            builder: (context, databaseServices, child) {
              return StreamBuilder(
                stream:
                    databaseServices.fireStore.collection("orders").snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: Colors.yellow.shade800,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Unexpected Error Occurred: ${snapshot.error}",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .5,
                          fontFamily: GoogleFonts.urbanist().fontFamily,
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
                                    Icons.shopping_basket_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No orders yet",
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.urbanist().fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
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
                                final orderDate =
                                    orderData['timestamp'] != null
                                        ? DateFormat('MMM dd, yyyy').format(
                                          (orderData['timestamp'] as Timestamp)
                                              .toDate(),
                                        )
                                        : 'Recent order';
                                final orderStatus =
                                    orderData['status'] ?? 'Pending';
                                final orderAmount =
                                    orderData['totalAmount'] ?? 0.0;
                                final orderItems = orderData['items'] ?? [];

                                // Determine status color
                                Color statusColor;
                                switch (orderStatus.toString().toLowerCase()) {
                                  case 'completed':
                                    statusColor = Colors.green;
                                    break;
                                  case 'cancelled':
                                    statusColor = Colors.red;
                                    break;
                                  case 'processing':
                                    statusColor = Colors.blue;
                                    break;
                                  default:
                                    statusColor = Colors.orange;
                                }

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
                                    orderDate: orderDate,
                                    orderStatus: orderStatus,
                                    statusColor: statusColor,
                                    orderAmount: orderAmount,
                                    itemCount: orderItems.length,
                                    index: index,
                                    onTap: () {
                                      // Navigate to order details or expand
                                      showOrderDetails(
                                        context,
                                        orderData,
                                        orderId,
                                      );
                                    },
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
