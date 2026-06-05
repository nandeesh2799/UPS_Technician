import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/order_model.dart';
import '../utils/formatters.dart';

class ExportService {
  static Future<void> exportOrdersToExcel(List<OrderModel> orders) async {
    final excel = Excel.createExcel();
    final sheet = excel['Orders'];
    
    // Add Header
    sheet.appendRow([
      TextCellValue('Order ID'),
      TextCellValue('Customer Name'),
      TextCellValue('Phone'),
      TextCellValue('UPS Brand'),
      TextCellValue('UPS Model'),
      TextCellValue('Status'),
      TextCellValue('Total Amount'),
      TextCellValue('Balance'),
      TextCellValue('Service Date'),
    ]);

    // Add Data
    for (var order in orders) {
      sheet.appendRow([
        TextCellValue(order.id),
        TextCellValue(order.customerName),
        TextCellValue(order.phone),
        TextCellValue(order.upsBrand),
        TextCellValue(order.upsModel),
        TextCellValue(order.status),
        DoubleCellValue(order.totalAmount),
        DoubleCellValue(order.balanceAmount),
        TextCellValue(Formatters.date(order.serviceDate)),
      ]);
    }

    // Save and Share
    final bytes = excel.save();
    if (bytes == null) return;

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Orders_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: 'UPS Service Orders Export');
  }

  static Future<void> exportOrdersToTallyXml(List<OrderModel> orders) async {
    final buffer = StringBuffer();
    buffer.writeln('<ENVELOPE>');
    buffer.writeln('  <HEADER>');
    buffer.writeln('    <TALLYREQUEST>Import Data</TALLYREQUEST>');
    buffer.writeln('  </HEADER>');
    buffer.writeln('  <BODY>');
    buffer.writeln('    <IMPORTDATA>');
    buffer.writeln('      <REQUESTDESC>');
    buffer.writeln('        <REPORTNAME>Vouchers</REPORTNAME>');
    buffer.writeln('      </REQUESTDESC>');
    buffer.writeln('      <REQUESTDATA>');

    for (var order in orders) {
      if (order.status != 'Completed' && order.status != 'Delivered') continue;

      final dateStr = DateFormat('yyyyMMdd').format(order.serviceDate);
      buffer.writeln('        <TALLYMESSAGE xmlns:UDF="TallyUDF">');
      buffer.writeln('          <VOUCHER VCHTYPE="Sales" ACTION="Create">');
      buffer.writeln('            <DATE>$dateStr</DATE>');
      buffer.writeln('            <VOUCHERNUMBER>${order.id}</VOUCHERNUMBER>');
      buffer.writeln('            <PARTYLEDGERNAME>${order.customerName}</PARTYLEDGERNAME>');
      buffer.writeln('            <ALLLEDGERENTRIES.LIST>');
      buffer.writeln('              <LEDGERNAME>Sales</LEDGERNAME>');
      buffer.writeln('              <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>');
      buffer.writeln('              <AMOUNT>-${order.totalAmount.toStringAsFixed(2)}</AMOUNT>');
      buffer.writeln('            </ALLLEDGERENTRIES.LIST>');
      buffer.writeln('            <ALLLEDGERENTRIES.LIST>');
      buffer.writeln('              <LEDGERNAME>${order.customerName}</LEDGERNAME>');
      buffer.writeln('              <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>');
      buffer.writeln('              <AMOUNT>${order.totalAmount.toStringAsFixed(2)}</AMOUNT>');
      buffer.writeln('            </ALLLEDGERENTRIES.LIST>');
      buffer.writeln('          </VOUCHER>');
      buffer.writeln('        </TALLYMESSAGE>');
    }

    buffer.writeln('      </REQUESTDATA>');
    buffer.writeln('    </IMPORTDATA>');
    buffer.writeln('  </BODY>');
    buffer.writeln('</ENVELOPE>');

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Tally_Export_${DateTime.now().millisecondsSinceEpoch}.xml');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: 'Tally XML Export');
  }
}
