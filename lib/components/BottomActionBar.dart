import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BottomActionBar extends StatelessWidget {
  final String? phoneNumber;
  final String orderId;
  final VoidCallback? onPrint;
  final Map<String, dynamic>? orderDetails; // Additional order details for printing

  const BottomActionBar({
    super.key,
    this.phoneNumber,
    required this.orderId,
    this.onPrint,
    this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.phone,
            label: "Call",
            color: Colors.green,
            onTap: () => _makeCall(context, phoneNumber),
          ),
          _ActionButton(
            icon: Icons.chat,
            label: "WhatsApp",
            color: const Color(0xFF25D366),
            onTap: () => _openWhatsApp(context, phoneNumber),
          ),
          _ActionButton(
            icon: Icons.message,
            label: "Message",
            color: Colors.blue,
            onTap: () => _sendMessage(context, phoneNumber),
          ),
          _ActionButton(
            icon: Icons.print,
            label: "Print",
            color: Colors.orange,
            onTap: onPrint ?? () => _printOrder(context, orderId),
          ),
        ],
      ),
    );
  }

  void _makeCall(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showSnackBar(context, "Phone number not available", Colors.red);
      return;
    }

    try {
      // Clean phone number (remove spaces, dashes, etc.)
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
      
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showSnackBar(context, "Cannot make phone calls on this device", Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, "Error making call: ${e.toString()}", Colors.red);
    }
  }

  void _openWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showSnackBar(context, "Phone number not available", Colors.red);
      return;
    }

    try {
      // Clean phone number and ensure it starts with country code
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      if (!cleanNumber.startsWith('+')) {
        // Add default country code if needed (you can modify this)
        cleanNumber = '+1$cleanNumber';
      }
      
      // Create WhatsApp message with order details
      String message = "Hello! I'm contacting you regarding Order #$orderId.";
      String encodedMessage = Uri.encodeComponent(message);
      
      // Try WhatsApp app first, then web version
      final Uri whatsappUri = Uri.parse("whatsapp://send?phone=$cleanNumber&text=$encodedMessage");
      final Uri whatsappWebUri = Uri.parse("https://wa.me/$cleanNumber?text=$encodedMessage");
      
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else if (await canLaunchUrl(whatsappWebUri)) {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context, "WhatsApp is not installed", Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, "Error opening WhatsApp: ${e.toString()}", Colors.red);
    }
  }

  void _sendMessage(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showSnackBar(context, "Phone number not available", Colors.red);
      return;
    }

    try {
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      String message = "Hello! This is regarding your Order #$orderId.";
      
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: {'body': message},
      );
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        _showSnackBar(context, "Cannot send SMS on this device", Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, "Error sending message: ${e.toString()}", Colors.red);
    }
  }

  void _printOrder(BuildContext context, String orderId) async {
    try {
      _showSnackBar(context, "Preparing document for printing...", Colors.blue);
      
      // Generate PDF
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ORDER RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Order ID: $orderId',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                      pw.Text(
                        'Date: ${DateTime.now().toString().split(' ')[0]}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 30),
                
                // Customer Information
                if (phoneNumber != null && phoneNumber!.isNotEmpty) ...[
                  pw.Text(
                    'Customer Information',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Phone: $phoneNumber'),
                  pw.SizedBox(height: 20),
                ],
                
                // Order Details
                pw.Text(
                  'Order Details',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                
                // Add order details if provided
                if (orderDetails != null) ...[
                  ...orderDetails!.entries.map((entry) => 
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${entry.key}:'),
                          pw.Text('${entry.value}'),
                        ],
                      ),
                    ),
                  ).toList(),
                ] else ...[
                  pw.Text('Order ID: $orderId'),
                  pw.Text('Status: Confirmed'),
                  pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                ],
                
                pw.SizedBox(height: 30),
                
                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Thank you for your business!',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      // Print the document
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Order_$orderId.pdf',
      );
      
      _showSnackBar(context, "Print dialog opened successfully", Colors.green);
      
    } catch (e) {
      _showSnackBar(context, "Error printing: ${e.toString()}", Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add haptic feedback
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}