import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_model.dart';
import '../models/company_settings_model.dart';

class PdfService {
  static Future<void> generateAndShareInvoice(OrderModel order, CompanySettingsModel company) async {
    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    if (company.logoUrl.isNotEmpty) {
      try {
        logoImage = await networkImage(company.logoUrl);
      } catch (e) {
        // Fallback if logo fails to load
      }
    }

    // Calculate totals
    final double subtotal = order.serviceCost + order.partsUsed.fold(0.0, (sum, item) => sum + item.totalPrice);
    final double grandTotal = subtotal;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Company Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(company.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.SizedBox(
                      width: 250,
                      child: pw.Text(company.address, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Text('Phone: ${company.phone} | Email: ${company.email}'),

                  ],
                ),
                if (logoImage != null)
                  pw.Container(
                    height: 60,
                    width: 60,
                    child: pw.Image(logoImage),
                  )
                else
                  pw.Container(
                    height: 60,
                    width: 60,
                    decoration: pw.BoxDecoration(border: pw.Border.all(), color: PdfColors.grey200),
                    child: pw.Center(child: pw.Text('LOGO', style: const pw.TextStyle(color: PdfColors.grey500))),
                  ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            
            // Invoice Info & Customer Details
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('Invoice No: ${company.invoicePrefix}-${order.id}'),
                    pw.Text('Date: ${order.serviceDate.toString().split(' ')[0]}'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(order.customerName),
                    pw.SizedBox(
                      width: 180,
                      child: pw.Text(
                        order.address,
                        textAlign: pw.TextAlign.right,
                        maxLines: 4,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Text('Phone: ${order.phone}'),
                    // Placeholder for Customer GSTIN if added later
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            
            // Order Details Table
            pw.TableHelper.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerRight,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
              },
              data: <List<String>>[
                ['Sl.No', 'Description', 'HSN Code', 'Qty', 'Rate', 'Taxable Amount'],
                [
                  '1', 
                  'Service: ${order.serviceType} - ${order.upsBrand} ${order.upsModel}', 
                  company.defaultHsnCode, 
                  '1', 
                  order.serviceCost.toStringAsFixed(2), 
                  order.serviceCost.toStringAsFixed(2)
                ],
                ...order.partsUsed.asMap().entries.map((e) => [
                  (e.key + 2).toString(),
                  e.value.name,
                  e.value.hsnCode.isNotEmpty ? e.value.hsnCode : company.defaultHsnCode,
                  e.value.quantity.toString(),
                  e.value.unitPrice.toStringAsFixed(2),
                  e.value.totalPrice.toStringAsFixed(2),
                ]),
              ],
            ),
            pw.SizedBox(height: 20),



            // Total Section & Payment
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Payment Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Payment Mode: ${order.paymentMode}'),
                      pw.Text('Advance Paid: Rs. ${order.advancePayment.toStringAsFixed(2)}'),
                      pw.Text('Balance Due: Rs. ${order.balanceAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildTotalRow('Subtotal:', subtotal),

                      pw.Divider(),
                      _buildTotalRow('Grand Total:', grandTotal, isBold: true),
                      pw.SizedBox(height: 5),
                      pw.Text('Amount in words: Rupees ${_convertToWords(grandTotal.round())} Only', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 40),

            // Terms and Conditions (No Signature Required)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(company.termsText, style: const pw.TextStyle(fontSize: 8)),
                if (order.hasWarranty && order.warrantyEnd != null)
                  pw.Text('Warranty valid until: ${order.warrantyEnd.toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey800)),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text('This is a computer generated invoice and does not require a physical signature.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ),
            ],
          );
        },
      ),
    );

    // Save logic
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory();
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    
    final file = File('${dir!.path}/Invoice_${order.id}.pdf');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    // Share or open
    await Printing.sharePdf(bytes: bytes, filename: 'Invoice_${order.id}.pdf');
  }

  static pw.Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text('Rs. ${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }

  // Simple number to words converter for invoice (basic implementation up to 99999)
  static String _convertToWords(int number) {
    if (number == 0) return 'Zero';
    
    final List<String> units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    final List<String> tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    
    String convertLessThanOneThousand(int n) {
      if (n == 0) return '';
      if (n < 20) return units[n];
      if (n < 100) return '${tens[n ~/ 10]} ${units[n % 10]}'.trim();
      return '${units[n ~/ 100]} Hundred ${convertLessThanOneThousand(n % 100)}'.trim();
    }
    
    if (number < 1000) return convertLessThanOneThousand(number);
    if (number < 100000) return '${convertLessThanOneThousand(number ~/ 1000)} Thousand ${convertLessThanOneThousand(number % 1000)}'.trim();
    if (number < 10000000) return '${convertLessThanOneThousand(number ~/ 100000)} Lakh ${convertLessThanOneThousand(number % 100000)}'.trim();
    
    return number.toString(); // Fallback for very large numbers
  }
}
