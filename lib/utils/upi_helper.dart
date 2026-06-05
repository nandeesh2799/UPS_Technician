class UpiHelper {
  static String generateUpiLink({
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
  }) {
    // Format: upi://pay?pa=VPA&pn=NAME&am=AMOUNT&cu=CURRENCY&tn=TRANSACTION_NOTE
    final String encodedName = Uri.encodeComponent(payeeName);
    final String encodedNote = transactionNote != null ? Uri.encodeComponent(transactionNote) : '';
    
    return 'upi://pay?pa=$upiId&pn=$encodedName&am=${amount.toStringAsFixed(2)}&cu=INR&tn=$encodedNote';
  }
}
