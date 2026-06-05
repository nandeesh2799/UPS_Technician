class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.length < 10) return 'Enter a valid phone number';
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) return 'Numbers only';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // email optional
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final amount = double.tryParse(value);
    if (amount == null) return 'Enter a valid number';
    if (amount < 0) return 'Amount cannot be negative';
    return null;
  }

  static String? gstin(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (!RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(value)) {
      return 'Enter a valid GSTIN';
    }
    return null;
  }
}
