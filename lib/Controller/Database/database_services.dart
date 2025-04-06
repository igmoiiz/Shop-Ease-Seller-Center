// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks, unused_local_variable

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this dependency

class DatabaseServices extends ChangeNotifier {
  //  Variables
  final ImagePicker picker = ImagePicker();
  File? _image;
  bool isLoading = false;
  String imageUrl = "";
  // Supabase Client
  final _supabase = Supabase.instance.client;
  //  Firebase Client
  final _fireStore = FirebaseFirestore.instance;
  // Connectivity checker
  final Connectivity _connectivity = Connectivity();

  //  Getters
  File? get image => _image;
  bool get loading => isLoading;
  SupabaseClient get supabase => _supabase;
  FirebaseFirestore get fireStore => _fireStore;

  //  Setters
  set image(File? value) {
    _image = value;
    notifyListeners();
  }

  // Check network connectivity
  Future<bool> _checkConnectivity() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  //  Method to pick an image from the gallery
  Future<void> pickImageFromGallery(BuildContext context) async {
    final snackBar = ScaffoldMessenger.of(context);
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        notifyListeners();
      } else {
        _image = null;
        notifyListeners();
        snackBar.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "No Image Selected",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
          ),
        );
      }
    } catch (error) {
      log("Error picking image: ${error.toString()}");
      rethrow;
    }
  }

  // Upload image to Supabase with retry mechanism
  Future<String?> _uploadImageToSupabase(
    String fileName,
    final imageBytes,
    BuildContext context,
  ) async {
    final snackBar = ScaffoldMessenger.of(context);

    // Check connectivity first
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      snackBar.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "No internet connection. Please check your network settings.",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
          ),
        ),
      );
      return null;
    }

    // Try up to 3 times
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await _supabase.storage
            .from("products")
            .uploadBinary(fileName, imageBytes);

        // Get public URL
        String url = _supabase.storage.from('products').getPublicUrl(fileName);
        return url;
      } catch (error) {
        log("Upload attempt $attempt failed: ${error.toString()}");

        // On last attempt, show error to user
        if (attempt == 3) {
          snackBar.showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              content: Text(
                "Failed to upload image. Error: ${error.toString()}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .5,
                ),
              ),
            ),
          );
          return null;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }
    return null;
  }

  //  Method to upload Data to Database
  Future<bool> uploadData(
    TextEditingController titleController,
    TextEditingController descriptionController,
    TextEditingController priceController,
    TextEditingController brandNameController,
    String category,
    BuildContext context,
  ) async {
    final snackBar = ScaffoldMessenger.of(context);

    // Validation check before setting loading state
    if (_image == null ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        brandNameController.text.isEmpty ||
        category == 'Select Category') {
      snackBar.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Please fill all the fields and select an image",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
          ),
        ),
      );
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      // Check network connectivity
      bool isConnected = await _checkConnectivity();
      if (!isConnected) {
        isLoading = false;
        notifyListeners();
        snackBar.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "No internet connection. Please check your network settings.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
          ),
        );
        return false;
      }

      // Generating fileName, productID and Converting image data to bytes
      String productId = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = "product_$productId.jpg";
      final imageBytes = await _image!.readAsBytes();

      // Upload image and get URL
      String? uploadedImageUrl = await _uploadImageToSupabase(
        fileName,
        imageBytes,
        context,
      );

      // If image upload failed, stop the process
      if (uploadedImageUrl == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      imageUrl = uploadedImageUrl;

      // Upload data to Firestore
      try {
        await fireStore.collection(category).doc(productId).set({
          "title": titleController.text,
          "description": descriptionController.text,
          "price": double.parse(priceController.text),
          "brandName": brandNameController.text,
          "image": imageUrl,
          "category": category,
          "productId": productId,
          "createdAt": DateTime.now(),
          "timeStamp": DateTime.timestamp(),
        });

        // Clear form data after successful upload
        titleController.clear();
        descriptionController.clear();
        priceController.clear();
        brandNameController.clear();
        _image = null;

        snackBar.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Product Added Successfully",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
          ),
        );

        return true;
      } catch (error) {
        log("Error While Uploading Data to Firestore", error: error.toString());
        snackBar.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Failed to save product data: ${error.toString()}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
          ),
        );
        return false;
      }
    } catch (error) {
      log("Error Occurred in Backend", error: error);
      snackBar.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "An unexpected error occurred: ${error.toString()}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
          ),
        ),
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markOrderAsCompleted(
    String orderId,
    BuildContext context,
  ) async {
    final snackBar = ScaffoldMessenger.of(context);
    bool isCompleting = false;

    try {
      // Update loading state
      isCompleting = true;
      notifyListeners();

      // Check network connectivity
      bool isConnected = await _checkConnectivity();
      if (!isConnected) {
        isCompleting = false;
        notifyListeners();
        snackBar.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "No internet connection. Please check your network settings.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
          ),
        );
        return false;
      }

      // Get the order document
      DocumentSnapshot orderSnapshot =
          await _fireStore.collection('orders').doc(orderId).get();

      if (!orderSnapshot.exists) {
        isCompleting = false;
        notifyListeners();
        snackBar.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Order not found",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
          ),
        );
        return false;
      }

      // Get order data
      Map<String, dynamic> orderData =
          orderSnapshot.data() as Map<String, dynamic>;

      // Add timestamp for completion
      orderData['completedAt'] = DateTime.now();

      // Start a batch operation for atomicity
      WriteBatch batch = _fireStore.batch();

      // Add to completedOrders collection
      DocumentReference completedOrderRef = _fireStore
          .collection('completedOrders')
          .doc(orderId);
      batch.set(completedOrderRef, orderData);

      // Delete from orders collection
      DocumentReference orderRef = _fireStore.collection('orders').doc(orderId);
      batch.delete(orderRef);

      // Commit the batch
      await batch.commit();

      snackBar.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Order marked as completed",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
          ),
        ),
      );

      return true;
    } catch (error) {
      log("Error marking order as completed", error: error.toString());
      snackBar.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Failed to complete order: ${error.toString()}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
          ),
        ),
      );
      return false;
    } finally {
      isCompleting = false;
      notifyListeners();
    }
  }
}
