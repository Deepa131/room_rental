class PhoneValidator {
  static String? validateNepalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (!isValidNepalPhoneFormat(digits)) {
      return 'Invalid phone number format.';
    }
    return null;
  }

  static bool isValidNepalPhoneFormat(String digits) {
    if (digits.length != 10) return false;

    if (digits.startsWith('98') || digits.startsWith('97') || digits.startsWith('96')) {
      return true;
    }

    final landlinePrefix = digits.substring(0, 2);
    if (['01', '02', '03', '04', '05'].contains(landlinePrefix)) {
      return true;
    }
    return false;
  }

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
