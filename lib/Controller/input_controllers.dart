import 'package:flutter/material.dart';

class InputControllers {
  //  Form Validators
  final formKey = GlobalKey<FormState>();
  //  Loading Variable
  bool loading = false;
  //  Text Editing Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
}
