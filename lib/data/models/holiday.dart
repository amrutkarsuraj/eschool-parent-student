// class Holiday {
//   Holiday({
//     required this.id,
//     required this.date,
//     required this.title,
//     required this.description,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//   late final int id;
//   late final DateTime date;
//   late final String title;
//   late final String description;
//   late final String createdAt;
//   late final String updatedAt;

//   Holiday.fromJson(Map<String, dynamic> json) {
//     id = json['id'] ?? 0;
//     date = json['date'] == null
//         ? DateTime.now()
//         : DateTime.parse(json['date'].toString());
//     title = json['title'] ?? "";
//     description = json['description'] ?? "";
//     createdAt = json['created_at'] ?? "";
//     updatedAt = json['updated_at'] ?? "";
//   }
// }
class Holiday {
  Holiday({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  late final int id;
  late final DateTime date;
  late final String title;
  late final String description;
  late final String createdAt;
  late final String updatedAt;

  Holiday.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    date = json['date'] == null
        ? DateTime.now()
        : _parseDate(json['date'].toString());
    title = json['title'] ?? "";
    description = json['description'] ?? "";
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
  }

  // Custom method to parse DD-MM-YYYY format
  static DateTime _parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) {
        throw FormatException('Invalid date format: $dateString');
      }
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    } catch (e) {
      print('Error parsing date: $dateString, Error: $e');
      return DateTime.now(); // Fallback to current date
    }
  }

  // Utility method to format date back to DD-MM-YYYY
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Convert to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': formattedDate,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}