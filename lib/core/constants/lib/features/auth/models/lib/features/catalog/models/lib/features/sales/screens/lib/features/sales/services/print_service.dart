// lib/features/sales/services/print_service.dart
import 'package:pos_universal_printer/pos_universal_printer.dart';

class PrintService {
  final PosUniversalPrinter _printer = PosUniversalPrinter.instance;
  
  Future<void> printReceipt(Transaction transaction) async {
    try {
      // Register printer device (configure based on your hardware)[citation:7]
      await _printer.registerDevice(
        PosPrinterRole.cashier,
        PrinterDevice(
          id: 'printer_1',
          name: 'Thermal Printer',
          type: PrinterType.tcp, // or bluetooth
          address: '192.168.1.100', // Printer IP
          port: 9100,
        ),
      );

      // Build receipt content
      final receipt = _buildReceiptContent(transaction);
      
      // Print receipt
      await _printer.printEscPos(
        PosPrinterRole.cashier,
        receipt,
      );
      
      // Cut paper
      await _printer.cutPaper(PosPrinterRole.cashier);
      
    } catch (e) {
      throw Exception('Printing failed: $e');
    }
  }

  String _buildReceiptContent(Transaction transaction) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('${AppConstants.companyName}');
    buffer.writeln('${AppConstants.companyAddress}');
    buffer.writeln('Tel: ${AppConstants.companyPhone}');
    buffer.writeln('${'-' * 32}');
    
    // Invoice details
    buffer.writeln('Invoice: ${transaction.invoiceNumber}');
    buffer.writeln('Date: ${_formatDate(transaction.date)}');
    buffer.writeln('Cashier: ${transaction.cashierName}');
    buffer.writeln('${'-' * 32}');
    
    // Items
    buffer.writeln('Item                 Qty   Price');
    for (var item in transaction.items) {
      buffer.writeln('${item.name.substring(0, 15).padRight(20)} '
          '${item.quantity.toString().padLeft(3)}  '
          '${item.total.toStringAsFixed(2)}');
    }
    
    // Totals
    buffer.writeln('${'-' * 32}');
    buffer.writeln('Subtotal:     ${transaction.subtotal.toStringAsFixed(2)}');
    buffer.writeln('Tax (10%):    ${transaction.tax.toStringAsFixed(2)}');
    buffer.writeln('TOTAL:        ${transaction.total.toStringAsFixed(2)}');
    buffer.writeln('Payment:      ${transaction.paymentMethod}');
    if (transaction.paymentMethod == 'Cash') {
      buffer.writeln('Change:       ${transaction.change.toStringAsFixed(2)}');
    }
    
    // Footer
    buffer.writeln('${'-' * 32}');
    buffer.writeln('Thank you for shopping with us!');
    buffer.writeln('Please come again');
    buffer.writeln('Ambrose Milean Enterprise © 2026');
    
    return buffer.toString();
  }
}
