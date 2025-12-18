import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({Key? key}) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  WebViewController? _controller; // Change to nullable
  final arguments = Get.arguments as Map<String, dynamic>;
  bool isLoading = true;
  bool isInitializing = true; // Track initial loading state

  // Variable to track if the user can pop the screen
  bool canPop = false;

  @override
  void initState() {
    super.initState();

    // Initialize controller immediately
    _initializeWebView();
  }

  void _initializeWebView() {
    // Set a timeout to ensure we don't stay in initializing state forever
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && isInitializing) {
        setState(() {
          isInitializing = false;
        });
      }
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      // Use desktop browser user agent to ensure full content rendering
      ..setUserAgent(
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              isLoading = true;
            });

            // Check for Flutterwave redirects
            _checkFlutterwavePaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            if (kDebugMode) {
              print("WebView Error: ${error.description}");
            }
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              isLoading = false;
              isInitializing = false;
            });

            // Check for Flutterwave redirects
            _checkFlutterwavePaymentStatus(url);

            // Apply fix for all payment pages, with special handling for Flutterwave
            _fixPaymentPageLayout(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (kDebugMode) {
              print("Navigation to: ${request.url}");
            }

            // Check for Flutterwave redirects first
            if (_checkFlutterwavePaymentStatus(request.url)) {
              return NavigationDecision.prevent;
            }

            // Generic success indicators across payment gateways
            if (request.url.contains("status=successful") ||
                request.url.contains("status=success") ||
                request.url.contains("status=completed") ||
                request.url.contains("transaction_id=") ||
                request.url.contains("trxref=") &&
                    request.url.contains("reference=")) {
              if (kDebugMode) {
                print("Payment successful detected: ${request.url}");
              }
              Get.back(result: true);
              return NavigationDecision.prevent;
            }

            // Generic failure indicators across payment gateways
            if (request.url.contains("status=cancelled") ||
                request.url.contains("status=failed") ||
                request.url.contains("cancelled=true")) {
              if (kDebugMode) {
                print("Payment failed/cancelled detected: ${request.url}");
              }
              Get.back(result: false);
              return NavigationDecision.prevent;
            }

            // Handle Flutterwave specific redirects
            if (request.url.contains("flutterwave") &&
                request.url.contains("tx_ref")) {
              // Check for successful payment
              if (request.url.contains("status=successful") ||
                  request.url.contains("status=success") ||
                  request.url.contains("status=completed") ||
                  request.url.contains("transaction_id=")) {
                if (kDebugMode) {
                  print("Flutterwave success detected: ${request.url}");
                }
                Get.back(result: true);
                return NavigationDecision.prevent;
              }

              // Check for cancelled or failed payment
              if (request.url.contains("status=cancelled") ||
                  request.url.contains("status=failed") ||
                  request.url.contains("cancelled=true")) {
                if (kDebugMode) {
                  print("Flutterwave failure detected: ${request.url}");
                }
                Get.back(result: false);
                return NavigationDecision.prevent;
              }
            }

            // Check for Paystack specific success URL patterns
            if (request.url.contains("paystack") &&
                (request.url.contains("/success") ||
                    request.url.contains("success=true"))) {
              if (kDebugMode) {
                print("Paystack success detected: ${request.url}");
              }
              Get.back(result: true);
              return NavigationDecision.prevent;
            }

            // Check for Paystack specific failure URL patterns
            if (request.url.contains("paystack") &&
                (request.url.contains("/failed") ||
                    request.url.contains("success=false") ||
                    request.url.contains("close"))) {
              if (kDebugMode) {
                print("Paystack failure detected: ${request.url}");
              }
              Get.back(result: false);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(arguments['paymentLink']),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

    // Update state to trigger rebuild
    if (mounted) {
      setState(() {});
    }
  }

  // Helper method to check Flutterwave payment status from URL
  bool _checkFlutterwavePaymentStatus(String url) {
    final lowercaseUrl = url.toLowerCase();

    // Check if it's a Flutterwave URL
    if (!lowercaseUrl.contains('flutterwave') &&
        !lowercaseUrl.contains('flw-') &&
        !lowercaseUrl.contains('tx_ref')) {
      return false;
    }

    if (kDebugMode) {
      print("Checking Flutterwave URL: $url");
    }

    // Success patterns for Flutterwave
    if ((lowercaseUrl.contains('status=successful') ||
            lowercaseUrl.contains('status=success') ||
            lowercaseUrl.contains('status=completed') ||
            lowercaseUrl.contains('transaction_id=') ||
            lowercaseUrl.contains('transaction_reference=')) &&
        (lowercaseUrl.contains('flutterwave') ||
            lowercaseUrl.contains('flw-') ||
            lowercaseUrl.contains('tx_ref='))) {
      if (kDebugMode) {
        print("Flutterwave success pattern detected in URL: $url");
      }
      Get.back(result: true);
      return true;
    }

    // Check for completed callback URLs with tx_ref in Flutterwave
    if (lowercaseUrl.contains('tx_ref=') &&
        (lowercaseUrl.contains('status=successful') ||
            lowercaseUrl.contains('status=success') ||
            lowercaseUrl.contains('status=completed'))) {
      if (kDebugMode) {
        print("Flutterwave tx_ref success detected: $url");
      }
      Get.back(result: true);
      return true;
    }

    // Failure patterns for Flutterwave
    if ((lowercaseUrl.contains('status=cancelled') ||
            lowercaseUrl.contains('status=failed') ||
            lowercaseUrl.contains('cancelled=true')) &&
        (lowercaseUrl.contains('flutterwave') ||
            lowercaseUrl.contains('flw-') ||
            lowercaseUrl.contains('tx_ref='))) {
      if (kDebugMode) {
        print("Flutterwave failure pattern detected in URL: $url");
      }
      Get.back(result: false);
      return true;
    }

    return false;
  }

  // Function to fix payment page layout issues
  void _fixPaymentPageLayout(String url) {
    // Skip if controller is null
    if (_controller == null) return;

    // Apply Flutterwave-specific fixes if needed
    if (url.toLowerCase().contains('flutterwave')) {
      _controller!.runJavaScript('''
        // Specific fixes for Flutterwave OTP screen
        setTimeout(function() {
          // Target the transaction reference text
          var elements = document.querySelectorAll('*');
          for (var i = 0; i < elements.length; i++) {
            var el = elements[i];
            var text = el.textContent || '';
            
            // Look for elements containing the reference code
            if (text.includes('FLW-') || text.includes('reference')) {
              // Fix the element styling
              el.style.cssText = `
                max-width: 100% !important;
                width: auto !important;
                text-align: left !important;
                white-space: normal !important;
                overflow-wrap: break-word !important;
                word-break: break-word !important;
                font-size: 13px !important;
                line-height: 1.4 !important;
                padding: 4px !important;
              `;
              
              // If it's inside a container, fix the container too
              if (el.parentElement) {
                el.parentElement.style.cssText = `
                  max-width: 100% !important;
                  width: auto !important;
                  overflow: visible !important;
                  padding: 4px !important;
                `;
              }
            }
          }
          
          // Ensure OTP input is properly sized
          var otpInputs = document.querySelectorAll('input[placeholder*="OTP"]');
          for (var i = 0; i < otpInputs.length; i++) {
            otpInputs[i].style.cssText = `
              width: 90% !important;
              max-width: 250px !important;
              margin: 8px auto !important;
              display: block !important;
            `;
          }
          
          // Fix submit button
          var submitButtons = document.querySelectorAll('button');
          for (var i = 0; i < submitButtons.length; i++) {
            var buttonText = submitButtons[i].textContent || '';
            if (buttonText.includes('Submit') || buttonText.includes('OTP')) {
              submitButtons[i].style.cssText = `
                width: 90% !important;
                max-width: 250px !important;
                margin: 8px auto !important;
                display: block !important;
              `;
            }
          }
          
          // Add success detection for Flutterwave transaction completion
          var checkForSuccess = function() {
            var content = document.body.textContent.toLowerCase();
            if (content.includes('successful') || 
                content.includes('completed') || 
                content.includes('approved') ||
                content.includes('verified')) {
              console.log('Payment appears to be successful');
              window.location.href = window.location.href + '&status=successful';
            }
          };
          
          // Run initial check
          checkForSuccess();
          
          // Set up a DOM observer to watch for changes
          var observer = new MutationObserver(function() {
            checkForSuccess();
          });
          
          observer.observe(document.body, {
            childList: true,
            subtree: true,
            characterData: true
          });
          
        }, 500); // Slight delay to ensure the DOM is fully loaded
      ''');
    }
  }

  // Handle back button press
  void _onWillPop() {
    if (!mounted) return;

    setState(() {
      canPop = true;
    });

    Utils.showCustomSnackBar(
      context: context,
      errorMessage: Utils.getTranslatedLabel(pressbackagaintoexitKey),
      backgroundColor: Theme.of(context).colorScheme.error,
    );

    // Reset canPop after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          canPop = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get safe area top padding
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = 56.0; // Estimated app bar height

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main content with padding to avoid overlap with app bar
            Padding(
              padding: EdgeInsets.only(top: topPadding + appBarHeight),
              child: Stack(
                children: [
                  if (isInitializing || _controller == null)
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading Payment...',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // WebView content
                  else
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                      child: WebViewWidget(controller: _controller!),
                    ),

                  // Loading indicator (shows on top of WebView when loading pages)
                  if (isLoading && !isInitializing && _controller != null)
                    Container(
                      color: Colors.white.withValues(alpha: 0.7),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),

            // Custom App Bar at the top with proper background
            Container(
              color: Color(0xFFF4F4F4),
              height: topPadding + appBarHeight,
              width: double.infinity,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomAppBar(
                  title: paymentKey,
                  onPressBackButton: () {
                    // Use the same back button behavior as PopScopea
                    if (canPop) {
                      Get.back(result: false);
                    } else {
                      _onWillPop();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
