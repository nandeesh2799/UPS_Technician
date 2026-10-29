import 'package:flutter_test/flutter_test.dart';
import 'package:ups_service_manager/utils/validators.dart';
import 'package:ups_service_manager/utils/formatters.dart';
import 'package:ups_service_manager/models/customer_model.dart';
import 'package:ups_service_manager/models/order_model.dart';
import 'package:ups_service_manager/models/company_settings_model.dart';

void main() {
  group('Validators Test Suite', () {
    test('required validator correctly flags null and whitespace', () {
      expect(Validators.required(null), 'This field is required');
      expect(Validators.required(''), 'This field is required');
      expect(Validators.required('   '), 'This field is required');
      expect(Validators.required('Valid text'), isNull);
    });

    test('phone validator handles clean and formatted numbers', () {
      expect(Validators.phone(null), 'Phone number is required');
      expect(Validators.phone(''), 'Phone number is required');
      expect(Validators.phone('12345'), 'Enter a valid phone number');
      expect(Validators.phone('+91 98765-43210'), isNull);
      expect(Validators.phone('9876543210'), isNull);
      expect(Validators.phone('987654321a'), 'Numbers only');
    });

    test('email validator allows optional null/empty and validates format', () {
      expect(Validators.email(null), isNull);
      expect(Validators.email(''), isNull);
      expect(Validators.email('invalid-email'), 'Enter a valid email address');
      expect(Validators.email('test@domain'), 'Enter a valid email address');
      expect(Validators.email('technician@ups-service.com'), isNull);
    });

    test('amount validator validates numerical non-negative constraints', () {
      expect(Validators.amount(null), 'Amount is required');
      expect(Validators.amount(''), 'Amount is required');
      expect(Validators.amount('abc'), 'Enter a valid number');
      expect(Validators.amount('-50'), 'Amount cannot be negative');
      expect(Validators.amount('0'), isNull);
      expect(Validators.amount('1500.50'), isNull);
    });

    test('gstin validator verifies standard 15-character GST format', () {
      expect(Validators.gstin(null), isNull);
      expect(Validators.gstin(''), isNull);
      expect(Validators.gstin('INVALIDGST'), 'Enter a valid GSTIN');
      // Standard format: 29ABCDE1234F1Z5
      expect(Validators.gstin('29ABCDE1234F1Z5'), isNull);
    });
  });

  group('Formatters Test Suite', () {
    test('currency formats amounts with Indian Rupee symbol', () {
      final formatted = Formatters.currency(1250);
      expect(formatted.contains('1,250'), isTrue);
      expect(formatted.contains('₹'), isTrue);
    });

    test('date and dateTime format dates according to standard format', () {
      final sampleDate = DateTime(2026, 10, 30, 14, 30);
      expect(Formatters.date(sampleDate), '30/10/2026');
      expect(Formatters.dateTime(sampleDate), contains('30/10/2026'));
      expect(Formatters.dateTime(sampleDate), contains('02:30'));
    });

    test('formatIndianNumber correctly formats large integers', () {
      expect(Formatters.formatIndianNumber(100000), '1,00,000');
    });
  });

  group('Domain Models Test Suite', () {
    test('OrderModel automatically zeros balanceAmount when paymentStatus is paid', () {
      final paidOrder = OrderModel(
        id: 'ord_101',
        customerId: 'cust_1',
        customerName: 'Acme Corp',
        phone: '9876543210',
        address: 'MG Road, Bengaluru',
        upsBrand: 'APC',
        upsModel: 'Smart-UPS 1500',
        problemDescription: 'Battery backup failure',
        serviceType: 'Repair',
        status: 'Completed',
        serviceCost: 2500.0,
        balanceAmount: 2500.0,
        paymentStatus: 'Paid',
        totalAmount: 2500.0,
        serviceDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(paidOrder.balanceAmount, 0.0);
    });

    test('CustomerModel identifies VIP status and segment correctly based on orders or spend', () {
      final now = DateTime.now();
      final normalCustomer = CustomerModel(
        id: 'c1',
        name: 'John Doe',
        phone: '9876543210',
        address: 'City Center',
        createdAt: now,
        lastOrderDate: now,
        totalOrders: 2,
        totalSpend: 3000.0,
      );
      expect(normalCustomer.segment, 'Regular');

      final vipByOrders = CustomerModel(
        id: 'c2',
        name: 'Tech Park',
        phone: '9876543211',
        address: 'Electronic City',
        createdAt: now,
        lastOrderDate: now,
        totalOrders: 6,
        totalSpend: 4000.0,
      );
      expect(vipByOrders.segment, 'VIP');

      final vipBySpend = CustomerModel(
        id: 'c3',
        name: 'Enterprise Logistics',
        phone: '9876543212',
        address: 'Whitefield',
        createdAt: now,
        lastOrderDate: now,
        totalOrders: 1,
        totalSpend: 15000.0,
      );
      expect(vipBySpend.segment, 'VIP');

      final newCustomer = CustomerModel(
        id: 'c4',
        name: 'New Starter',
        phone: '9876543213',
        address: 'Indiranagar',
        createdAt: now,
        lastOrderDate: now,
        totalOrders: 0,
        totalSpend: 0.0,
      );
      expect(newCustomer.segment, 'New');
    });

    test('CompanySettingsModel provides sound production defaults', () {
      final defaults = CompanySettingsModel.defaultSettings();
      expect(defaults.name.isNotEmpty, isTrue);
      expect(defaults.invoicePrefix, 'USM');
      expect(defaults.defaultHsnCode, '9987');
      expect(defaults.termsText.isNotEmpty, isTrue);
    });
  });
}
