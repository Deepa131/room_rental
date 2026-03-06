/// Phone validation utility for Nepali phone numbers
class PhoneValidator {
  static String? validateNepalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove any non-digit characters
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // Check length
    if (digits.length != 10) {
      return 'Phone number must be 10 digits';
    }

    // Check if it's a valid Nepali phone number
    if (!isValidNepalPhoneFormat(digits)) {
      return 'Invalid phone number format.';
    }

    return null;
  }

  // Checks if phone number matches Nepali phone format
  static bool isValidNepalPhoneFormat(String digits) {
    if (digits.length != 10) return false;

    // Mobile numbers: 98, 97, 96
    if (digits.startsWith('98') || digits.startsWith('97') || digits.startsWith('96')) {
      return true;
    }

    // Landline numbers: 01 (Kathmandu), 02, 03, 04, 05
    final landlinePrefix = digits.substring(0, 2);
    if (['01', '02', '03', '04', '05'].contains(landlinePrefix)) {
      return true;
    }

    return false;
  }

  // Format phone number for display
  static String formatNepalPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return phone;

    if (digits.startsWith('0')) {
      return '${digits.substring(0, 4)}-${digits.substring(4)}';
    } else {
      return digits;
    }
  }
}
