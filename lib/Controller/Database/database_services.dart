import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class DatabaseServices extends ChangeNotifier {
  //  Variables
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  //  Instance for Firebase Firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  //  Instance for Supabase Client
  final SupabaseClient _supabase = Supabase.instance.client;
  //  Getters
  FirebaseFirestore get fireStore => _fireStore;
  SupabaseClient get supabase => _supabase;
  File? get image => _image;
  bool get isLoading => _isLoading;
  ImagePicker get picker => _picker;
  //  Setters
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set image(final value) {
    _image = value;
    notifyListeners();
  }

  //  Method to pick an image from the gallery
  Future<void> pickImageFromGallery(BuildContext context) async {
    final snackBar = ScaffoldMessenger.of(context);
    try {
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) {
        log("No image selected");
        snackBar.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Please Select a Image",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        return;
      }

      _image = File(pickedImage.path);
      notifyListeners();
    } catch (error) {
      log(error.toString());
    }
  }

  //  Method to Post Data to Database
  Future<void> postData(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController descriptionController,
    TextEditingController priceController,
    TextEditingController brandNameController,
    String category,
  ) async {
    final snackBar = ScaffoldMessenger.of(context);
    try {
      isLoading = true;
      if (_image == null) {
        snackBar.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Please Select a Image",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

      if (descriptionController.text.isEmpty ||
          titleController.text.isEmpty ||
          priceController.text.isEmpty ||
          brandNameController.text.isEmpty ||
          category.isEmpty) {
        snackBar.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Insufficient Information about Product. Please fill all the fields.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

      //  Setting Product ID and File Name
      String productId = Uuid().v4();
      String fileName = "$productId.jpg";

      //  Reading Image as Bytes
      final bytes = _image!.readAsBytesSync();

      //  Uploading Image to Storage
      await _supabase.storage.from('products').uploadBinary(fileName, bytes);

      //  Getting Image URL
      final imageUrl = supabase.storage.from('products').getPublicUrl(fileName);

      //  Post Product Data to Firestore database
      await _fireStore.collection(category).doc(productId).set({
        "productId": productId,
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "price": priceController.text.trim(),
        "brand": brandNameController.text.trim(),
        "category": category.trim(),
        "imageUrl": imageUrl,
        "createdAt": Timestamp.now(),
      });

      //  Resetting the Text Controllers
      titleController.clear();
      descriptionController.clear();
      priceController.clear();
      _image = null;
      isLoading = false;
      notifyListeners();
      snackBar.showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Product Added Successfully",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (error) {
      log(error.toString());
    }
  }
}
