import 'package:eschool/data/models/announcement.dart';
import 'package:eschool/utils/api.dart';
import 'package:flutter/foundation.dart';

class AnnouncementRepository {
//   //fetch notice board details
//   // Future<Map<String, dynamic>> fetchAnnouncements({
//   //   int? page,
//   //   required bool useParentApi,
//   //   required int childId,
//   //   required bool isGeneralAnnouncement,
//   //   int? classSubjectId,
//   // }) async {
//   //   try {
//   //     Map<String, dynamic> queryParameters = {
//   //       "page": page ?? 0,
//   //       "type": isGeneralAnnouncement ? "class" : "subject",
//   //       "class_subject_id": classSubjectId ?? 0
//   //     };

//   //     //
//   //     if (queryParameters['page'] == 0) {
//   //       queryParameters.remove("page");
//   //     }

//   //     //
//   //     if (isGeneralAnnouncement) {
//   //       queryParameters.remove("class_subject_id");
//   //     }

//   //     //
//   //     if (useParentApi) {
//   //       queryParameters.addAll({
//   //         "child_id": childId,
//   //       });
//   //     }
//   //     if (kDebugMode) {
//   //       print(queryParameters);
//   //     }

//   //     final result = await Api.get(
//   //       url: useParentApi
//   //           ? Api.generalAnnouncementsParent
//   //           : Api.generalAnnouncements,
//   //       useAuthToken: true,
//   //       queryParameters: queryParameters,
//   //     );

//   //     return {
//   //       "announcements": (result['data']['data'] as List)
//   //           .map((e) => Announcement.fromJson(Map.from(e)))
//   //           .toList(),
//   //       "totalPage": result['data']['last_page'] as int,
//   //       "currentPage": result['data']['current_page'] as int,
//   //     };
//   //   } catch (e, st) {
//   //     print("This is the st : ${st}");
//   //     throw ApiException(e.toString());
//   //   }
//   // }
//  Future<Map<String, dynamic>> fetchAnnouncements({
//   int? page,
//   required bool useParentApi,
//   int? childId,
//   required bool isGeneralAnnouncement,
//   int? classSubjectId,
// }) async {
//   try {
//     // FIRST: Try with NO parameters - exactly like Postman
//     Map<String, dynamic> queryParameters = {};
    
//     if (kDebugMode) {
//       print("=== TESTING WITHOUT PARAMETERS FIRST ===");
//       print("This should match your Postman request");
//     }

//     final result = await Api.get(
//       url: useParentApi
//           ? Api.generalAnnouncementsParent
//           : Api.generalAnnouncements,
//       useAuthToken: true,
//       queryParameters: queryParameters, // Empty parameters first
//     );

//     if (kDebugMode) {
//       print("=== API RESPONSE WITH NO PARAMS ===");
//       print("Full Result: $result");
      
//       if (result['data'] != null && result['data']['data'] != null) {
//         final announcementsData = result['data']['data'] as List;
//         print("Announcements Count (No Params): ${announcementsData.length}");
        
//         if (announcementsData.isNotEmpty) {
//           print("SUCCESS! Announcements found without parameters");
//           print("First announcement: ${announcementsData[0]['title']}");
//         } else {
//           print("STILL EMPTY! Issue might be in authentication or API endpoint");
//         }
//       }
//       print("==================================");
//     }

//     // If still empty, there's an authentication or endpoint issue
//     // If data comes, then parameters are the problem

//     // Enhanced error checking
//     if (result == null) {
//       throw ApiException("API returned null response");
//     }

//     if (result['error'] == true) {
//       throw ApiException(result['message'] ?? "API returned an error");
//     }

//     if (result['data'] == null) {
//       throw ApiException("Invalid response structure: 'data' field is missing");
//     }

//     if (result['data']['data'] == null) {
//       throw ApiException("Invalid response structure: 'data.data' field is missing");
//     }

//     final announcementsData = result['data']['data'] as List;
    
//     if (kDebugMode) {
//       print("Processing ${announcementsData.length} announcements...");
//     }

//     // Enhanced announcement parsing
//     final announcements = <Announcement>[];
    
//     for (int i = 0; i < announcementsData.length; i++) {
//       try {
//         final announcementData = announcementsData[i];
        
//         if (kDebugMode) {
//           print("Processing announcement $i: ${announcementData['title']}");
//         }
        
//         final announcement = Announcement.fromJson(Map<String, dynamic>.from(announcementData));
//         announcements.add(announcement);
        
//       } catch (announcementError) {
//         if (kDebugMode) {
//           print("=== ANNOUNCEMENT PARSING ERROR ===");
//           print("Error processing announcement $i: $announcementError");
//           print("Announcement data: ${announcementsData[i]}");
//           print("================================");
//         }
//         continue;
//       }
//     }

//     final responseMap = {
//       "announcements": announcements,
//       "totalPage": result['data']['last_page'] as int? ?? 1,
//       "currentPage": result['data']['current_page'] as int? ?? 1,
//     };

//     if (kDebugMode) {
//       print("=== FINAL RESPONSE ===");
//       print("Successfully parsed announcements: ${announcements.length}");
//       print("====================");
//     }

//     return responseMap;

//   } catch (e, st) {
//     if (kDebugMode) {
//       print("=== ERROR ===");
//       print("Error: $e");
//       print("Stack Trace: $st");
//       print("=============");
//     }
//     throw ApiException(e.toString());
//   }
// }

// // ALTERNATIVE: Test with exact Postman parameters
// Future<Map<String, dynamic>> testExactPostmanCall() async {
//   try {
//     if (kDebugMode) {
//       print("=== TESTING EXACT POSTMAN CALL ===");
//     }

//     final result = await Api.get(
//       url: "https://vschool.online/api/student/announcements", // Exact URL
//       useAuthToken: true,
//       queryParameters: {"page": "1"}, // Only page parameter like Postman
//     );

//     if (kDebugMode) {
//       print("Postman Test Result: $result");
//       if (result['data'] != null && result['data']['data'] != null) {
//         print("Postman Test Count: ${(result['data']['data'] as List).length}");
//       }
//     }

//     return {
//       "announcements": [],
//       "totalPage": 1,
//       "currentPage": 1,
//     };
//   } catch (e) {
//     if (kDebugMode) {
//       print("Postman Test Error: $e");
//     }
//     throw ApiException(e.toString());
//   }
// }
Future<Map<String, dynamic>> fetchAnnouncements({
  int? page,
  required bool useParentApi,
  int? childId, // Keep it nullable but handle properly
  required bool isGeneralAnnouncement,
  int? classSubjectId,
}) async {
  try {
    // Start with basic parameters
    Map<String, dynamic> queryParameters = {};
    
    // Add page parameter (start from 1, not 0)
    if (page != null && page > 0) {
      queryParameters["page"] = page;
    }
    
    // Add type parameter
    queryParameters["type"] = isGeneralAnnouncement ? "class" : "subject";
    
    // Add class_subject_id for subject-specific announcements
    if (!isGeneralAnnouncement && classSubjectId != null && classSubjectId > 0) {
      queryParameters["class_subject_id"] = classSubjectId;
    }

    // IMPORTANT: Add child_id for parent API
    if (useParentApi && childId != null) {
      queryParameters["child_id"] = childId;
    }

    if (kDebugMode) {
      print("=== API REQUEST DEBUG ===");
      print("useParentApi: $useParentApi");
      print("childId: $childId");
      print("isGeneralAnnouncement: $isGeneralAnnouncement");
      print("classSubjectId: $classSubjectId");
      print("Query Parameters: $queryParameters");
      print("API URL: ${useParentApi ? Api.generalAnnouncementsParent : Api.generalAnnouncements}");
      print("========================");
    }

    final result = await Api.get(
      url: useParentApi
          ? Api.generalAnnouncementsParent
          : Api.generalAnnouncements,
      useAuthToken: true,
      queryParameters: queryParameters,
    );

    if (kDebugMode) {
      print("=== API RESPONSE DEBUG ===");
      print("Full Result: $result");
      print("Error: ${result['error']}");
      print("Code: ${result['code']}");
      print("Message: ${result['message']}");
      
      if (result['data'] != null && result['data']['data'] != null) {
        final announcementsData = result['data']['data'] as List;
        print("Announcements Count: ${announcementsData.length}");
        print("Total in DB: ${result['data']['total']}");
        
        if (announcementsData.isNotEmpty) {
          print("SUCCESS! Announcements found");
          for (int i = 0; i < announcementsData.length; i++) {
            print("Announcement $i: ${announcementsData[i]['title']}");
          }
        } else {
          print("No announcements returned - check parameters or database");
        }
      } else {
        print("No data field in response");
      }
      print("==================================");
    }

    // Enhanced error checking
    if (result == null) {
      throw ApiException("API returned null response");
    }

    if (result['error'] == true) {
      throw ApiException(result['message'] ?? "API returned an error");
    }

    if (result['data'] == null) {
      throw ApiException("Invalid response structure: 'data' field is missing");
    }

    if (result['data']['data'] == null) {
      throw ApiException("Invalid response structure: 'data.data' field is missing");
    }

    final announcementsData = result['data']['data'] as List;
    
    if (kDebugMode) {
      print("Processing ${announcementsData.length} announcements...");
    }

    // Parse announcements with error handling
    final announcements = <Announcement>[];
    
    for (int i = 0; i < announcementsData.length; i++) {
      try {
        final announcementData = announcementsData[i];
        
        if (kDebugMode) {
          print("Processing announcement $i: ${announcementData['title']}");
          // Print the structure for debugging
          print("Announcement structure: ${announcementData.keys.toList()}");
        }
        
        final announcement = Announcement.fromJson(Map<String, dynamic>.from(announcementData));
        announcements.add(announcement);
        
      } catch (announcementError) {
        if (kDebugMode) {
          print("=== ANNOUNCEMENT PARSING ERROR ===");
          print("Error processing announcement $i: $announcementError");
          print("Announcement data: ${announcementsData[i]}");
          print("================================");
        }
        // Continue processing other announcements
        continue;
      }
    }

    final responseMap = {
      "announcements": announcements,
      "totalPage": result['data']['last_page'] as int? ?? 1,
      "currentPage": result['data']['current_page'] as int? ?? 1,
    };

    if (kDebugMode) {
      print("=== FINAL RESPONSE ===");
      print("Successfully parsed announcements: ${announcements.length}");
      print("Total Pages: ${responseMap['totalPage']}");
      print("Current Page: ${responseMap['currentPage']}");
      print("====================");
    }

    return responseMap;

  } catch (e, st) {
    if (kDebugMode) {
      print("=== FETCH ANNOUNCEMENTS ERROR ===");
      print("Error Type: ${e.runtimeType}");
      print("Error Message: $e");
      print("Stack Trace: $st");
      print("================================");
    }
    throw ApiException(e.toString());
  }
}

// Test method to compare with Postman
Future<void> testAnnouncementAPI({
  required bool useParentApi,
  int? childId,
}) async {
  try {
    if (kDebugMode) {
      print("=== TESTING ANNOUNCEMENT API ===");
      print("Testing with useParentApi: $useParentApi, childId: $childId");
    }

    // Test 1: No parameters (like your working Postman request)
    Map<String, dynamic> testParams1 = {};
    
    // Test 2: With basic parameters
    Map<String, dynamic> testParams2 = {
      "type": "class",
    };
    
    // Test 3: With child_id for parent
    Map<String, dynamic> testParams3 = {
      "type": "class",
    };
    if (useParentApi && childId != null) {
      testParams3["child_id"] = childId;
    }

    // Test all three parameter sets
    for (int i = 1; i <= 3; i++) {
      Map<String, dynamic> testParams = i == 1 ? testParams1 : (i == 2 ? testParams2 : testParams3);
      
      if (kDebugMode) {
        print("=== TEST $i ===");
        print("Parameters: $testParams");
      }

      try {
        final result = await Api.get(
          url: useParentApi ? Api.generalAnnouncementsParent : Api.generalAnnouncements,
          useAuthToken: true,
          queryParameters: testParams,
        );

        if (result['data'] != null && result['data']['data'] != null) {
          final count = (result['data']['data'] as List).length;
          if (kDebugMode) {
            print("Test $i Result: $count announcements found");
          }
          if (count > 0) {
            if (kDebugMode) {
              print("SUCCESS with Test $i parameters!");
            }
            break;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Test $i failed: $e");
        }
      }
    }

  } catch (e) {
    if (kDebugMode) {
      print("Test API Error: $e");
    }
  }
}
}
