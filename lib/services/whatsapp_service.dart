import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<void> sendMessage({
    required String phone,
    required String message,
    required String countryCode,
  }) async {
    String formattedPhone = _formatPhone(phone, countryCode);
    
    final Uri url = Uri.parse('https://wa.me/${formattedPhone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to SMS if WhatsApp is not installed
      final Uri smsUrl = Uri.parse('sms:$formattedPhone?body=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl);
      }
    }
  }

  static String _formatPhone(String phone, String countryCode) {
    phone = phone.replaceAll(RegExp(r'\s+|-|\(|\)'), '');
    if (phone.startsWith('+')) return phone;
    if (phone.startsWith('0')) phone = phone.substring(1);
    return '$countryCode$phone';
  }

  static String formatTemplate(String template, Map<String, String> variables) {
    String result = template;
    variables.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
