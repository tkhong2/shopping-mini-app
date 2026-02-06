import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Formatters {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      await initializeDateFormatting('vi_VN', null);
      _initialized = true;
    }
  }

  // Currency formatter
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  // Number formatter
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(number);
  }
  
  // Date formatter
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    return formatter.format(date);
  }
  
  // Date time formatter
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
    return formatter.format(dateTime);
  }
  
  // Time formatter
  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm', 'vi_VN');
    return formatter.format(time);
  }
  
  // Relative time formatter
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
  
  // Phone formatter
  static String formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
    } else if (phone.length == 11) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
    }
    return phone;
  }
  
  // Discount percentage formatter
  static String formatDiscountPercentage(double originalPrice, double discountPrice) {
    if (originalPrice <= discountPrice) return '';
    
    final discountPercentage = ((originalPrice - discountPrice) / originalPrice) * 100;
    return '-${discountPercentage.round()}%';
  }
  
  // Rating formatter
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
  
  // File size formatter
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

// Alias classes for backward compatibility
class PriceFormatter {
  static String format(double amount) => Formatters.formatCurrency(amount);
}

class DateFormatter {
  static String formatDate(DateTime date) => Formatters.formatDate(date);
  static String formatDateTime(DateTime dateTime) => Formatters.formatDateTime(dateTime);
  static String formatRelativeTime(DateTime dateTime) => Formatters.formatRelativeTime(dateTime);
}