// lib/features/sales/screens/checkout_screen.dart
import 'package:mobile_scanner/mobile_scanner.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final List<CartItem> _cart = [];
  double _subtotal = 0.0;
  double _tax = 0.0;
  double _total = 0.0;
  String _selectedPaymentMethod = 'Cash';
  
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConstants.companyName} - POS'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Row(
        children: [
          // Left side - Scanner and Cart
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Barcode Scanner
                Container(
                  height: 200,
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _handleBarcodeScan,
                  ),
                ),
                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('Qty: ${item.quantity}'),
                        trailing: Text('${AppConstants.currencySymbol}${item.totalPrice.toStringAsFixed(2)}'),
                        onTap: () => _removeFromCart(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Right side - Payment Summary
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Invoice Summary', style: Theme.of(context).textTheme.headline6),
                  Divider(),
                  _buildSummaryRow('Subtotal:', _subtotal),
                  _buildSummaryRow('Tax (10%):', _tax),
                  _buildSummaryRow('Total:', _total, isBold: true),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    items: ['Cash', 'Card', 'Mobile Payment']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.secondaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Complete Sale'),
                  ),
                  ElevatedButton(
                    onPressed: _printReceipt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Print Receipt'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScan(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _addProductByBarcode(barcode.rawValue!);
      }
    }
  }
}
