import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fe/models/Category.dart';
import 'package:fe/services/ApiCategoryService.dart';
import 'package:intl/intl.dart'; // Add this import at the top


class CreateAuctionItemsPage extends StatefulWidget {
  const CreateAuctionItemsPage({super.key});

  @override
  State createState() => _CreateAuctionItemsPageState();
}

class _CreateAuctionItemsPageState extends State {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _startingPriceController = TextEditingController();
  final TextEditingController _bidStepController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Category? _selectedCategory;
  List<Category> _categories = [];
  DateTime? _startDate;
  DateTime? _endDate;
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      ApiCategoryService apiService = ApiCategoryService();
      List<Category> categories = await apiService.getAllCategory();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future _pickDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _submitAuctionItem() {
    print("Auction Item Submitted: ${_itemNameController.text}, Category: ${_selectedCategory?.category_name}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Auction Item")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputBox("Item Name", _itemNameController),
              _buildDropdown(),
              _buildInputBox("Starting Price", _startingPriceController, isNumber: true),
              _buildInputBox("Bid Step", _bidStepController, isNumber: true),
              _buildInputBox("Description", _descriptionController, isMultiline: true),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker("Start Date", _startDate, () => _pickDate(context, true)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDatePicker("End Date", _endDate, () => _pickDate(context, false)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildImagePicker(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAuctionItem,
                  child: const Text("Create Auction Item"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox(String label, TextEditingController controller, {bool isNumber = false, bool isMultiline = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: isMultiline ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category>(
          isExpanded: true,
          hint: const Text("Select Category"),
          value: _selectedCategory,
          onChanged: (Category? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          items: _categories.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Text(category.category_name ?? "Unknown"),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    String formattedDate = date != null ? DateFormat('yyyy-MM-dd').format(date) : label;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          formattedDate, // Display formatted date instead of raw DateTime object
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text("Add Images", style: TextStyle(fontSize: 16)))
          ),
        ),
      ],
    );
  }
}
