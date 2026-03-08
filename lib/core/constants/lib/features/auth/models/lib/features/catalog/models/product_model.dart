// lib/features/catalog/models/product_model.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String barcode;
  final String? customBarcode; // Custom barcode inscription
  final int stockQuantity;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.barcode,
    this.customBarcode,
    required this.stockQuantity,
    required this.category,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Generate barcode for this product
  String generateBarcode() {
    // Format: AMB + category code + product ID
    return "AMB${category.substring(0, 2).toUpperCase()}${id.padLeft(6, '0')}";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'barcode': barcode,
      'customBarcode': customBarcode,
      'stockQuantity': stockQuantity,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// lib/features/catalog/screens/barcode_creator_screen.dart
import 'package:barcode_widget/barcode_widget.dart';

class BarcodeCreatorScreen extends StatefulWidget {
  @override
  _BarcodeCreatorScreenState createState() => _BarcodeCreatorScreenState();
}

class _BarcodeCreatorScreenState extends State<BarcodeCreatorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedBarcodeFormat = 'code128';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConstants.companyName} - Barcode Creator'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedBarcodeFormat,
              items: ['code128', 'ean13', 'qr']
                  .map((format) => DropdownMenuItem(
                        value: format,
                        child: Text(format.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedBarcodeFormat = value!),
            ),
            SizedBox(height: 20),
            if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BarcodeWidget(
                        barcode: Barcode.code128(), // Or dynamic based on selection[citation:2]
                        data: 'AMB-${_nameController.text.substring(0, 3).toUpperCase()}-${_priceController.text}',
                        width: 200,
                        height: 100,
                        drawText: true,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'AMB-${_nameController.text.substring(0, 3).toUpperCase()}-${_priceController.text}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Ambrose Milean Enterprise', 
                           style: TextStyle(color: AppConstants.primaryColor)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _saveProduct(),
                        child: Text('Save Product'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
