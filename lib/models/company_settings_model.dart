class CompanySettingsModel {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String gstNumber;
  final String defaultHsnCode;
  final String logoUrl;
  final String invoicePrefix;
  final int nextInvoiceNumber;
  final String upiQrUrl;
  final String upiId;
  final String googleReviewUrl;
  final String termsText;
  final String whatsappCountryCode;
  
  // Templates
  final String templateJobReceived;
  final String templateJobCompleted;
  final String templateWarrantyReminder;
  final String templatePaymentReminder;
  final String templateReviewPrompt;

  CompanySettingsModel({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.gstNumber,
    this.defaultHsnCode = '9987',
    this.logoUrl = '',
    this.invoicePrefix = 'USM',
    this.nextInvoiceNumber = 1000,
    this.upiQrUrl = '',
    this.upiId = '',
    this.googleReviewUrl = '',
    this.termsText = '1. Goods once sold will not be taken back.\n2. Warranty as per manufacturer terms.\n3. Subject to local jurisdiction.',
    this.whatsappCountryCode = '+91',
    this.templateJobReceived = "==========================\n*{center_name}*\nJOB INTAKE CONFIRMATION\n==========================\nOrder ID  : {id}\nBrand     : {brand}\nStatus    : Received\n--------------------------\nDear {name},\n\nYour {brand} UPS has been successfully received.\n\nWe will inspect the device and update you with diagnostic details shortly.\n\nThank you for choosing us!\n===========================",
    this.templateJobCompleted = "==========================\n*{center_name}*\nTAX INVOICE / WORK COMPLETED\n==========================\nOrder ID  : {id}\nBrand     : {brand}\n--------------------------\nDear {name},\n\nYour {brand} UPS repair is complete and ready for collection.\n\nSUMMARY:\n• Total Amount  : ₹{total}\n• Advance Paid  : ₹{advance}\n• BALANCE DUE   : ₹{balance}\n==========================\nPlease collect your device at your convenience.\n\nThank you for your business!\n===========================",
    this.templateWarrantyReminder = "==========================\n*{center_name}*\nWARRANTY EXPIRY STATEMENT\n==========================\nOrder ID  : {id}\nCustomer  : {name}\n--------------------------\nWARRANTY EXPIRES ON:\n*{date}*\n--------------------------\nDear {name},\n\nThis is a friendly reminder that the warranty for your UPS service expires on {date}.\n\nPlease contact us for renewal or extension.\n\nRegards,\n{center_name}\nPhone: {center_phone}\n===========================",
    this.templatePaymentReminder = "==========================\n*{center_name}*\nOUTSTANDING DUE STATEMENT\n==========================\nOrder ID  : {id}\nCustomer  : {name}\n--------------------------\nCURRENT OUTSTANDING DUE:\n*₹{balance}*\n--------------------------\nDear {name},\n\nThis is a formal notification regarding the outstanding balance for your service order.\n\nKindly facilitate payment at your earliest convenience.\n\nThank you for your cooperation.\n===========================",
    this.templateReviewPrompt = "==========================\n*{center_name}*\nFEEDBACK & REVIEW\n==========================\nDear {name},\n\nThank you for choosing {center_name}. We hope you are satisfied with our service.\n\nPlease take a moment to leave us a review here:\n{link}\n\nYour feedback helps us improve and serve you better!\n===========================",
  });

  static String _migrateTemplate(String? val, String defaultVal) {
    if (val == null || val.trim().isEmpty || !val.contains('\n') || val.contains('Job ID') || val.contains('POWERED BY')) {
      return defaultVal;
    }
    return val;
  }

  factory CompanySettingsModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) return CompanySettingsModel.defaultSettings();
    final defaults = CompanySettingsModel.defaultSettings();
    return CompanySettingsModel(
      name: data['name'] ?? 'My Service Center',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      gstNumber: data['gstNumber'] ?? '',
      defaultHsnCode: data['defaultHsnCode'] ?? '9987',
      logoUrl: data['logoUrl'] ?? '',
      invoicePrefix: data['invoicePrefix'] ?? 'USM',
      nextInvoiceNumber: data['nextInvoiceNumber'] ?? 1000,
      upiQrUrl: data['upiQrUrl'] ?? '',
      upiId: data['upiId'] ?? '',
      googleReviewUrl: data['googleReviewUrl'] ?? '',
      termsText: data['termsText'] ?? '1. Goods once sold will not be taken back.\n2. Warranty as per manufacturer terms.',
      whatsappCountryCode: '+91',
      templateJobReceived: _migrateTemplate(data['templateJobReceived']?.toString(), defaults.templateJobReceived),
      templateJobCompleted: _migrateTemplate(data['templateJobCompleted']?.toString(), defaults.templateJobCompleted),
      templateWarrantyReminder: _migrateTemplate(data['templateWarrantyReminder']?.toString(), defaults.templateWarrantyReminder),
      templatePaymentReminder: _migrateTemplate(data['templatePaymentReminder']?.toString(), defaults.templatePaymentReminder),
      templateReviewPrompt: _migrateTemplate(data['templateReviewPrompt']?.toString(), defaults.templateReviewPrompt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'gstNumber': gstNumber,
      'defaultHsnCode': defaultHsnCode,
      'logoUrl': logoUrl,
      'invoicePrefix': invoicePrefix,
      'nextInvoiceNumber': nextInvoiceNumber,
      'upiQrUrl': upiQrUrl,
      'upiId': upiId,
      'googleReviewUrl': googleReviewUrl,
      'termsText': termsText,
      'whatsappCountryCode': '+91',
      'templateJobReceived': templateJobReceived,
      'templateJobCompleted': templateJobCompleted,
      'templateWarrantyReminder': templateWarrantyReminder,
      'templatePaymentReminder': templatePaymentReminder,
      'templateReviewPrompt': templateReviewPrompt,
    };
  }

  static CompanySettingsModel defaultSettings() {
    return CompanySettingsModel(
      name: 'UPS Service Center',
      address: '123 Tech Park, Bangalore',
      phone: '+919876543210',
      email: 'contact@upsservice.com',
      gstNumber: '29ABCDE1234F1Z5',
      defaultHsnCode: '9987',
      whatsappCountryCode: '+91',
    );
  }
}
