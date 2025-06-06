import 'dart:math';

/// Utility class for generating random promo codes
class CodeGenerator {
  /// Generates a random alphanumeric code with the specified format
  /// 
  /// Format example: "XXX-XXX-XXX" where X will be replaced with random characters
  /// The dash separators will be preserved in the output
  static String generatePromoCode({String format = "XXXX-XXXX-XXXX"}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789'; // Excluding similar looking characters
    final random = Random();
    
    return format.split('').map((char) {
      if (char == 'X') {
        return chars[random.nextInt(chars.length)];
      }
      return char; // Keep separators as is
    }).join('');
  }
  
  /// Generates a formatted code with partner prefix
  static String generatePartnerCode(String partner) {
    // Create a partner prefix from the first 2-3 letters of partner name
    final prefix = partner.substring(0, min(3, partner.length)).toUpperCase();
    return "$prefix-${generatePromoCode(format: "XXXX-XXXX")}";
  }
} 