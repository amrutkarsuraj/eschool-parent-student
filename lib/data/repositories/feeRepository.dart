import 'dart:convert';

import 'package:eschool/data/models/childFeeDetails.dart';
import 'package:eschool/data/models/paymentTransaction.dart';
import 'package:eschool/utils/api.dart';
import 'package:flutter/foundation.dart';

class FeeRepository {
  //
  Future<List<ChildFeeDetails>> fetchChildFeeDetails(
      {required int childId}) async {
    try {
      final result = await Api.get(
        url: Api.getStudentFeesDetailParent,
        useAuthToken: true,
        queryParameters: {
          "child_id": childId,
        },
      );
      return ((result['data'] ?? []) as List)
          .map((e) => ChildFeeDetails.fromJson(Map.from(e ?? {})))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw ApiException(e.toString());
    }
  }
Future<({PaymentTransaction paymentTransaction, Map<String, dynamic> data})>
    payCompulsoryFee(
        {required String paymentMethod,
        required int childId,
        required int feeId,
        List<int>? installmentIds,
        double? advanceAmount}) async {
  try {
    final result = await Api.post(
      body: {
        "payment_method": paymentMethod,
        "child_id": childId,
        "fees_id": feeId,
        "installment_ids": installmentIds ?? [],
        "advance": advanceAmount ?? 0
      },
      url: Api.payChildCompulsoryFees,
      useAuthToken: true
    );

    if (kDebugMode) {
      print("API Response for $paymentMethod: $result");
      print("Response type: ${result.runtimeType}");
      print("Data field: ${result['data']}");
    }

    // Validate API response structure
    if (result == null) {
      throw ApiException("API returned null response");
    }

    if (result['data'] == null) {
      throw ApiException("API response missing 'data' field");
    }

    final data = result['data'] as Map<String, dynamic>;

    // Validate payment_transaction field
    if (data['payment_transaction'] == null) {
      throw ApiException("API response missing 'payment_transaction' field");
    }

    // Extract payment transaction with better error handling
    PaymentTransaction paymentTransaction;
    try {
      final paymentTransactionData = data['payment_transaction'] as Map<String, dynamic>;
      paymentTransaction = PaymentTransaction.fromJson(paymentTransactionData);
      
      if (kDebugMode) {
        print("Payment transaction created successfully: ${paymentTransaction.id}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error parsing PaymentTransaction: $e");
        print("Payment transaction data: ${data['payment_transaction']}");
      }
      throw ApiException("Failed to parse payment transaction: $e");
    }

    // Extract payment data based on payment method
    Map<String, dynamic> paymentData;
    
    if (paymentMethod == "Flutterwave" || paymentMethod == "Paystack") {
      // For Flutterwave and Paystack, return the entire data object
      paymentData = Map<String, dynamic>.from(data);
      
      if (kDebugMode) {
        print("Extracted payment data for $paymentMethod: $paymentData");
      }
    } else {
      // For Stripe/Razorpay, extract payment_intent
      if (data['payment_intent'] == null) {
        throw ApiException("API response missing 'payment_intent' field for $paymentMethod");
      }
      
      paymentData = Map<String, dynamic>.from(data['payment_intent'] as Map<String, dynamic>);
      
      if (kDebugMode) {
        print("Extracted payment_intent for $paymentMethod: $paymentData");
      }
    }

    return (paymentTransaction: paymentTransaction, data: paymentData);
    
  } catch (e) {
    if (kDebugMode) {
      print("Error in payCompulsoryFee: $e");
      print("Error type: ${e.runtimeType}");
    }
    
    // Re-throw ApiException as is, wrap other exceptions
    if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException("Payment processing failed: ${e.toString()}");
    }
  }
}  // Future<({PaymentTransaction paymentTransaction, Map<String, dynamic> data})>
  //     payCompulsoryFee(
  //         {required String paymentMethod,
  //         required int childId,
  //         required int feeId,
  //         List<int>? installmentIds,
  //         double? advanceAmount}) async {
  //   try {
  //     final result = await Api.post(body: {
  //       "payment_method": paymentMethod,
  //       "child_id": childId,
  //       "fees_id": feeId,
  //       "installment_ids": installmentIds ?? [],
  //       "advance": advanceAmount ?? 0
  //     }, url: Api.payChildCompulsoryFees, useAuthToken: true);

  //     if (kDebugMode) {
  //       print("API Response for $paymentMethod: $result");
  //     }

  //     // Extract payment transaction
  //     final paymentTransaction = PaymentTransaction.fromJson(
  //         Map.from(result['data']['payment_transaction'] ?? {}));

  //     // Extract payment data based on payment method
  //     Map<String, dynamic> data;
  //     if (paymentMethod == "Flutterwave" || paymentMethod == "Paystack") {
  //       // For Flutterwave and Paystack, we need the entire data object as it contains the payment_link
  //       data = Map<String, dynamic>.from(result['data'] ?? {});

  //       if (kDebugMode) {
  //         print("Extracted payment data for $paymentMethod: $data");
  //       }
  //     } else {
  //       // For Stripe/Razorpay, extract payment_intent as before
  //       data =
  //           Map<String, dynamic>.from(result['data']['payment_intent'] ?? {});
  //     }

  //     return (paymentTransaction: paymentTransaction, data: data);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error in payCompulsoryFee: $e");
  //     }
  //     throw ApiException(e.toString());
  //   }
  // }

  Future<({PaymentTransaction paymentTransaction, Map<String, dynamic> data})>
      payOptionalFees(
          {required String paymentMethod,
          required int childId,
          required int feeId,
          required List<int> optionalFeeIds}) async {
    try {
      final result = await Api.post(body: {
        "payment_method": paymentMethod,
        "child_id": childId,
        "fees_id": feeId,
        "optional_id": optionalFeeIds
      }, url: Api.payChildOptionalFees, useAuthToken: true);

      if (kDebugMode) {
        print("API Response for optional fees with $paymentMethod: $result");
      }

      // Extract payment transaction
      final paymentTransaction = PaymentTransaction.fromJson(
          Map.from(result['data']['payment_transaction'] ?? {}));

      // Extract payment data based on payment method
      Map<String, dynamic> data;
      if (paymentMethod == "Flutterwave" || paymentMethod == "Paystack") {
        // For Flutterwave and Paystack, we need the entire data object as it contains the payment_link
        data = Map<String, dynamic>.from(result['data'] ?? {});

        if (kDebugMode) {
          print("Extracted payment data for $paymentMethod: $data");
        }
      } else {
        // For Stripe/Razorpay, extract payment_intent as before
        data =
            Map<String, dynamic>.from(result['data']['payment_intent'] ?? {});
      }

      return (paymentTransaction: paymentTransaction, data: data);
    } catch (e) {
      if (kDebugMode) {
        print("Error in payOptionalFees: $e");
      }
      throw ApiException(e.toString());
    }
  }

  Future<String> getFeeReceipt(
      {required int childId, required int feeId}) async {
    try {
      final result = await Api.get(queryParameters: {
        "child_id": childId,
        "fees_id": feeId,
      }, url: Api.downloadFeeReceipt, useAuthToken: true);

      return result['pdf'] ?? "";
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
