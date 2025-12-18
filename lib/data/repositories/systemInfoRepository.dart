import 'package:eschool/data/models/holiday.dart';
import 'package:eschool/utils/api.dart';

class SystemRepository {     
  Future<dynamic> fetchSettings({required String type}) async {
    try {
      final result = await Api.get(
        queryParameters: {"type": type},
        url: Api.settings,
        useAuthToken: false,
      );

      return result['data'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Future<List<Holiday>> fetchHolidays({int? childId}) async {
  //   try {
  //     final result = await Api.get(
  //         queryParameters: {"child_id": childId},
  //         url: Api.holidays,
  //         useAuthToken: true);

  //     print(result);

  //     return ((result['data'] ?? []) as List)
  //         .map((holiday) => Holiday.fromJson(Map.from(holiday)))
  //         .toList();
  //   } catch (e) {
  //     throw ApiException(e.toString());
  //   }
  // }
  Future<List<Holiday>> fetchHolidays({int? childId}) async {
  try {
    final result = await Api.get(
        queryParameters: {"child_id": childId},
        url: Api.holidays,
        useAuthToken: true);
    
    print('Holidays API Response: $result'); // Consider using a proper logger
    
    if (result['error'] == true) {
      throw ApiException(result['message'] ?? 'Failed to fetch holidays');
    }
    
    final holidays = ((result['data'] ?? []) as List)
        .map((holiday) => Holiday.fromJson(holiday as Map<String, dynamic>))
        .toList();
    
    print('Parsed ${holidays.length} holidays');
    return holidays;
    
  } catch (e) {
    print('Error fetching holidays: $e'); // Consider using a proper logger
    throw ApiException(e.toString());
  }
}
}
