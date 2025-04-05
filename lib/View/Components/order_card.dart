// ignore_for_file: deprecated_member_use, library_prefixes

import 'dart:math' as Math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:seller_center/Controller/Database/database_services.dart';
import 'package:seller_center/View/Components/network_image_widget.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String orderName;
  final String orderDate;
  final String orderStatus;
  final Color statusColor;
  final dynamic orderAmount;
  final int itemCount;
  final int index;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.orderName,
    required this.orderDate,
    required this.orderStatus,
    required this.statusColor,
    required this.orderAmount,
    required this.itemCount,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
          tag: 'order-$orderId',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow.shade700, Colors.orange.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with order ID and status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'ID: ${orderId.substring(0, Math.min(6, orderId.length))}',
                              style: TextStyle(
                                fontFamily: GoogleFonts.urbanist().fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              orderStatus,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontFamily: GoogleFonts.urbanist().fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Order details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  orderName,
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.urbanist().fontFamily,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Text(
                                orderAmount is num
                                    ? 'Rs. ${NumberFormat('#,##,###.##').format(orderAmount)}'
                                    : 'Rs. 0.00',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.urbanist().fontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.black.withOpacity(0.6),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  orderDate,
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.urbanist().fontFamily,
                                    color: Colors.black.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 16,
                                color: Colors.black.withOpacity(0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.urbanist().fontFamily,
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuad,
        );
  }
}

// Function to show order details dialog/bottom sheet
void showOrderDetails(
  BuildContext context,
  Map<String, dynamic> orderData,
  String orderId,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder:
        (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: OrderDetailsBottomSheet(
            orderData: orderData,
            orderId: orderId,
          ),
        ),
  );
}

class OrderDetailsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  const OrderDetailsBottomSheet({
    super.key,
    required this.orderData,
    required this.orderId,
  });

  @override
  State<OrderDetailsBottomSheet> createState() =>
      _OrderDetailsBottomSheetState();
}

class _OrderDetailsBottomSheetState extends State<OrderDetailsBottomSheet> {
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final items = widget.orderData['items'] as List? ?? [];
    final orderName =
        widget.orderData['orderName'] ??
        'Order #${widget.orderId.substring(0, Math.min(6, widget.orderId.length))}';
    final orderStatus = widget.orderData['status'] ?? 'Pending';
    final orderDate =
        widget.orderData['timestamp'] != null
            ? DateFormat(
              'MMM dd, yyyy, hh:mm a',
            ).format((widget.orderData['timestamp'] as Timestamp).toDate())
            : 'Recent order';
    final totalAmount = widget.orderData['totalAmount'] ?? 0.0;
    final customerName =
        widget.orderData['customerName'] ??
        widget.orderData['userEmail'] ??
        'Customer';
    final customerEmail = widget.orderData['userEmail'] ?? '';
    final shippingAddress =
        widget.orderData['shippingAddress'] ??
        widget.orderData['address'] ??
        'No address provided';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Order title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Hero(
                  tag: 'title-${widget.orderId}',
                  child: Text(
                    orderName,
                    style: TextStyle(
                      fontFamily: GoogleFonts.urbanist().fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(orderStatus).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  orderStatus,
                  style: TextStyle(
                    color: getStatusColor(orderStatus),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: GoogleFonts.urbanist().fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 400)),

        const SizedBox(height: 8),

        // Order metadata
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: ${widget.orderId}',
                style: TextStyle(
                  fontFamily: GoogleFonts.urbanist().fontFamily,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Placed on: $orderDate',
                style: TextStyle(
                  fontFamily: GoogleFonts.urbanist().fontFamily,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Text(
                'Customer Details',
                style: TextStyle(
                  fontFamily: GoogleFonts.urbanist().fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              customerEmail.isNotEmpty
                  ? orderDetailRow(Icons.email_outlined, 'Email', customerEmail)
                  : orderDetailRow(Icons.person_outline, 'Name', customerName),
              const SizedBox(height: 8),
              orderDetailRow(
                Icons.location_on_outlined,
                'Address',
                shippingAddress,
              ),
            ],
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
        ),

        const SizedBox(height: 24),

        // Item list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Items (${items.length})',
            style: TextStyle(
              fontFamily: GoogleFonts.urbanist().fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child:
              items.isEmpty
                  ? Center(
                    child: Text(
                      'No items in this order',
                      style: TextStyle(
                        fontFamily: GoogleFonts.urbanist().fontFamily,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                  : ListView.builder(
                    itemCount: items.length,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return orderItemTile(item, index);
                    },
                  ),
        ),

        // Total amount and Mark as Completed button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.yellow.shade50,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontFamily: GoogleFonts.urbanist().fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    totalAmount is num
                        ? 'Rs. ${NumberFormat('#,##,###.##').format(totalAmount)}'
                        : 'Rs. 0.00',
                    style: TextStyle(
                      fontFamily: GoogleFonts.urbanist().fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mark as Completed button
              Consumer<DatabaseServices>(
                builder: (context, databaseServices, index) {
                  return InkWell(
                        onTap: () async {
                          if (!_isCompleting) {
                            setState(() {
                              _isCompleting = true;
                            });

                            // Assuming you have the orderId available in your widget
                            // Replace 'widget.orderId' with however you're accessing the order ID
                            bool success = await databaseServices
                                .markOrderAsCompleted(widget.orderId, context);

                            if (success) {
                              // Additional actions after successful completion if needed
                              // e.g., Navigator.pop(context) or refreshing a list
                            }

                            setState(() {
                              _isCompleting = false;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow.shade600,
                                Colors.yellow.shade800,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child:
                                _isCompleting
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Processing...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily:
                                                GoogleFonts.urbanist()
                                                    .fontFamily,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Text(
                                      'Mark as Completed',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily:
                                            GoogleFonts.urbanist().fontFamily,
                                      ),
                                    ),
                          ),
                        ),
                      )
                      .animate(
                        onPlay:
                            (controller) => controller.repeat(reverse: true),
                      )
                      .shimmer(
                        duration: const Duration(seconds: 2),
                        color: Colors.white.withOpacity(0.2),
                      )
                      .animate()
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.02, 1.02),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.02, 1.02),
                        end: const Offset(1, 1),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                },
              ),
            ],
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 400),
        ),
      ],
    );
  }

  Widget orderDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: GoogleFonts.urbanist().fontFamily,
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: GoogleFonts.urbanist().fontFamily,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget orderItemTile(dynamic item, int index) {
    final itemName = item['title'] ?? 'Unknown Item';
    final itemQuantity = item['quantity'] ?? 1;
    final itemPrice = item['price'] ?? 0.0;
    final itemTotal = itemQuantity * itemPrice;
    final imageUrl = item['image'];

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: NetworkImageWidget(imageUrl: imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: TextStyle(
                        fontFamily: GoogleFonts.urbanist().fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Qty: $itemQuantity x Rs. ${itemPrice is num ? NumberFormat('#,##0.00').format(itemPrice) : '0.00'}',
                      style: TextStyle(
                        fontFamily: GoogleFonts.urbanist().fontFamily,
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs. ${itemTotal is num ? NumberFormat('#,##0.00').format(itemTotal) : '0.00'}',
                style: TextStyle(
                  fontFamily: GoogleFonts.urbanist().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideX(
          begin: 0.1,
          end: 0,
          duration: const Duration(milliseconds: 400),
        );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
