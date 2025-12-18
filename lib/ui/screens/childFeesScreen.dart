// import 'package:eschool/app/routes.dart';
// import 'package:eschool/cubits/childFeeDetailsCubit.dart';
// import 'package:eschool/data/models/childFeeDetails.dart';
// import 'package:eschool/data/models/student.dart';
// import 'package:eschool/ui/widgets/customAppbar.dart';
// import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
// import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
// import 'package:eschool/ui/widgets/errorContainer.dart';
// import 'package:eschool/ui/widgets/noDataContainer.dart';
// import 'package:eschool/utils/labelKeys.dart';
// import 'package:eschool/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get/get.dart';
import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/childFeeDetailsCubit.dart';
import 'package:eschool/data/models/childFeeDetails.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/tabBarBackgroundContainer.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChildFeesScreen extends StatefulWidget {
  final Student child;
  ChildFeesScreen({Key? key, required this.child}) : super(key: key);

  static Widget routeInstance() {
    return ChildFeesScreen(
      child: Get.arguments as Student,
    );
  }

  @override
  State<ChildFeesScreen> createState() => _ChildFeesScreenState();
}

class _ChildFeesScreenState extends State<ChildFeesScreen>
    with WidgetsBindingObserver {
  // Tab keys
  static const String unpaidTabKey = 'Panding';
  static const String paidTabKey = 'paid';

  // Current selected tab
  String _currentlySelectedTabKey = unpaidTabKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () {
      fetchChildFeeDetails();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
  }

  void fetchChildFeeDetails() {
    if (mounted) {
      context
          .read<ChildFeeDetailsCubit>()
          .fetchChildFeeDetails(childId: widget.child.id ?? 0);
    }
  }

  // Filter fees based on payment status
  List<ChildFeeDetails> _getFilteredFees(List<ChildFeeDetails> allFees) {
    if (_currentlySelectedTabKey == paidTabKey) {
      // Return paid fees
      return allFees
          .where((fee) => fee.getFeePaymentStatus() == paidKey)
          .toList();
    } else {
      // Return unpaid fees (pending and partially paid)
      return allFees
          .where((fee) => fee.getFeePaymentStatus() != paidKey)
          .toList();
    }
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomBackButton(
                onTap: () {
                  Get.back();
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  width: boxConstraints.maxWidth * (0.5),
                  child: Text(
                    Utils.getTranslatedLabel(feesKey),
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: Utils.screenTitleFontSize,
                    ),
                  ),
                ),
              ),
              // Animated tab background
              AnimatedAlign(
                curve: Utils.tabBackgroundContainerAnimationCurve,
                duration: Utils.tabBackgroundContainerAnimationDuration,
                alignment: _currentlySelectedTabKey == unpaidTabKey
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child:
                    TabBarBackgroundContainer(boxConstraints: boxConstraints),
              ),
              // Unpaid tab
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerStart,
                isSelected: _currentlySelectedTabKey == unpaidTabKey,
                onTap: () {
                  setState(() {
                    _currentlySelectedTabKey = unpaidTabKey;
                  });
                },
                titleKey: Utils.getTranslatedLabel(
                    pendingKey), // You can add this to labelKeys.dart or use direct text
              ),
              // Paid tab
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.centerEnd,
                isSelected: _currentlySelectedTabKey == paidTabKey,
                onTap: () {
                  setState(() {
                    _currentlySelectedTabKey = paidTabKey;
                  });
                },
                titleKey: Utils.getTranslatedLabel(
                    paidKey), // You can add this to labelKeys.dart or use direct text
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeeCard(ChildFeeDetails feeDetails) {
    final valueTextStyle = TextStyle(
        fontSize: 13.0,
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9));

    final feePaymentStatusKey = feeDetails.getFeePaymentStatus();
    final feePaymentStatusColor = feePaymentStatusKey == pendingKey
        ? Theme.of(context).colorScheme.error
        : (feePaymentStatusKey == paidKey)
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(Routes.childFeeDetails, arguments: {
            "childFeeDetails": feeDetails,
            "child": widget.child
          })?.then((_) {
            fetchChildFeeDetails();
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                feeDetails.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "${Utils.getTranslatedLabel(classKey)} : ${feeDetails.classDetails?.name ?? '-'}",
                    style: valueTextStyle,
                  ),
                  const Spacer(),
                  Text(
                    feeDetails.sessionYear?.name ?? "",
                    style: valueTextStyle,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Text(
                          "${Utils.getTranslatedLabel(statusKey)} : ",
                          style: valueTextStyle,
                        ),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: feePaymentStatusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      feePaymentStatusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              Utils.getTranslatedLabel(feePaymentStatusKey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: valueTextStyle.copyWith(
                                  color: feePaymentStatusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (feePaymentStatusKey != paidKey &&
                      !feeDetails
                          .didUserPaidPreviousCompulsoryFeeInInstallment())
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${Utils.getTranslatedLabel(dueDateKey)} : ${feeDetails.dueDate ?? ''}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: valueTextStyle,
                        textAlign: TextAlign.end,
                      ),
                    ),
                ],
              ),
              // Add fee amount for better visibility
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    "${Utils.getTranslatedLabel('totalAmount')} : ",
                    style: valueTextStyle,
                  ),
                  Text(
                    "₹${(feeDetails.totalCompulsoryFees ?? 0).toStringAsFixed(2)}",
                    style: valueTextStyle.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  DateTime _parseDDMMYYYY(String? date) {
    if (date == null || date.isEmpty) return DateTime(1900);

    try {
      final parts = date.split("-");
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime(1900);
    }
  }


  Widget _buildFeesContainer({required List<ChildFeeDetails> fees}) {
    fees.sort((a, b) {
      DateTime dateA = _parseDDMMYYYY(a.dueDate);
      DateTime dateB = _parseDDMMYYYY(b.dueDate);
      return dateB.compareTo(dateA);
    });


    final filteredFees = _getFilteredFees(fees);
    return CustomRefreshIndicator(
      displacment: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarBiggerHeightPercentage),
      onRefreshCallback: () async {
        fetchChildFeeDetails();
      },
      child: filteredFees.isEmpty
          ? Center(
              child: NoDataContainer(
                titleKey: _currentlySelectedTabKey == paidTabKey
                    ? 'noPaidFeesFoundKey'
                    : 'noUnpaidFeesFoundKey',
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(
                bottom: 25,
                left: Utils.screenContentHorizontalPadding,
                right: Utils.screenContentHorizontalPadding,
                top: Utils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
                ),
              ),
              itemCount: filteredFees.length,
              itemBuilder: (context, index) {
                return _buildFeeCard(filteredFees[index]);
              }),
    );
  }

  Widget _buildTabContent() {
    return BlocBuilder<ChildFeeDetailsCubit, ChildFeeDetailsState>(
      builder: (context, state) {
        if (state is ChildFeeDetailsFetchSuccess) {
          if (state.fees.isEmpty) {
            return Center(
              child: NoDataContainer(titleKey: noFeesFoundKey),
            );
          }
          return _buildFeesContainer(fees: state.fees);
        }
        if (state is ChildFeeDetailsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageCode: state.errorMessage,
              onTapRetry: () {
                fetchChildFeeDetails();
              },
            ),
          );
        }
        return Center(
          child: CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildTabContent(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
        ],
      ),
    );
  }
// class ChildFeesScreen extends StatefulWidget {
//   final Student child;
//   ChildFeesScreen({Key? key, required this.child}) : super(key: key);

//   static Widget routeInstance() {
//     return ChildFeesScreen(
//       child: Get.arguments as Student,
//     );
//   }

//   @override
//   State<ChildFeesScreen> createState() => _ChildFeesScreenState();
// }

// class _ChildFeesScreenState extends State<ChildFeesScreen>
//     with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();

//     // Add the observer to listen for screen size/metrics changes
//     WidgetsBinding.instance.addObserver(this);

//     // Initial data fetch
//     Future.delayed(Duration.zero, () {
//       fetchChildFeeDetails();
//     });
//   }

//   @override
//   void dispose() {
//     // Remove the observer when the widget is disposed
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   // Implement didChangeMetrics method
//   @override
//   void didChangeMetrics() {
//     // Handle the metrics change, if needed
//     super.didChangeMetrics();
//     print("Screen metrics changed");
//   }

//   void fetchChildFeeDetails() {
//     if (mounted) {
//       context
//           .read<ChildFeeDetailsCubit>()
//           .fetchChildFeeDetails(childId: widget.child.id ?? 0);
//     }
//   }

//   Widget _buildFeesContainer({required List<ChildFeeDetails> fees}) {
//     return CustomRefreshIndicator(
//       displacment: Utils.getScrollViewTopPadding(
//           context: context,
//           appBarHeightPercentage: Utils.appBarSmallerHeightPercentage),
//       onRefreshCallback: () async {
//         fetchChildFeeDetails();
//       },
//       child: ListView.builder(
//           padding: EdgeInsets.only(
//             bottom: 25,
//             left: Utils.screenContentHorizontalPadding,
//             right: Utils.screenContentHorizontalPadding,
//             top: Utils.getScrollViewTopPadding(
//               context: context,
//               appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
//             ),
//           ),
//           itemCount: fees.length,
//           itemBuilder: (context, index) {
//             final feeDetails = fees[index];
//             final valueTextStyle = TextStyle(
//                 fontSize: 13.0,
//                 color: Theme.of(context)
//                     .colorScheme
//                     .secondary
//                     .withValues(alpha: 0.9));
//             final feePaymentStatusKey = feeDetails.getFeePaymentStatus();
//             final feePaymentStatusColor = feePaymentStatusKey == pendingKey
//                 ? Theme.of(context).colorScheme.error
//                 : (feePaymentStatusKey == paidKey)
//                     ? Theme.of(context).colorScheme.onPrimary
//                     : Theme.of(context).colorScheme.primary;
//             return Padding(
//               padding: EdgeInsets.only(bottom: 15),
//               child: GestureDetector(
//                 onTap: () {
//                   // Use GetX navigation with refresh callback
//                   Get.toNamed(Routes.childFeeDetails, arguments: {
//                     "childFeeDetails": feeDetails,
//                     "child": widget.child
//                   })?.then((_) {
//                     // Refresh data when returning from details/payment screen
//                     fetchChildFeeDetails();
//                   });
//                 },
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: 100,
//                   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
//                   decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.surface,
//                       borderRadius: BorderRadius.circular(10)),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         feeDetails.name ?? "",
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                             color: Theme.of(context).colorScheme.secondary),
//                       ),
//                       const Spacer(),
//                       Row(
//                         children: [
//                           Text(
//                             "${Utils.getTranslatedLabel(classKey)} : ${feeDetails.classDetails?.name ?? '-'}",
//                             style: valueTextStyle,
//                           ),
//                           const Spacer(),
//                           Text(
//                             feeDetails.sessionYear?.name ?? "",
//                             style: valueTextStyle,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 2.5),
//                       Row(
//                         children: [
//                           Expanded(
//                             flex: 2,
//                             child: Row(
//                               children: [
//                                 Text(
//                                   "${Utils.getTranslatedLabel(statusKey)} : ",
//                                   style: valueTextStyle,
//                                 ),
//                                 Flexible(
//                                   child: Text(
//                                     Utils.getTranslatedLabel(
//                                         feePaymentStatusKey),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: valueTextStyle.copyWith(
//                                         color: feePaymentStatusColor),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (feePaymentStatusKey != paidKey &&
//                               !feeDetails
//                                   .didUserPaidPreviousCompulsoryFeeInInstallment())
//                             Expanded(
//                               flex: 3,
//                               child: Text(
//                                 "${Utils.getTranslatedLabel(dueDateKey)} : ${feeDetails.dueDate ?? ''}",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: valueTextStyle,
//                                 textAlign: TextAlign.end,
//                               ),
//                             ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           BlocBuilder<ChildFeeDetailsCubit, ChildFeeDetailsState>(
//               builder: (context, state) {
//             if (state is ChildFeeDetailsFetchSuccess) {
//               if (state.fees.isEmpty) {
//                 return Center(
//                   child: NoDataContainer(titleKey: noFeesFoundKey),
//                 );
//               }
//               return _buildFeesContainer(fees: state.fees);
//             }
//             if (state is ChildFeeDetailsFetchFailure) {
//               return Center(
//                 child: ErrorContainer(
//                   errorMessageCode: state.errorMessage,
//                   onTapRetry: () {
//                     fetchChildFeeDetails();
//                   },
//                 ),
//               );
//             }
//             return Center(
//               child: CustomCircularProgressIndicator(
//                 indicatorColor: Theme.of(context).colorScheme.primary,
//               ),
//             );
//           }),
//           Align(
//             alignment: Alignment.topCenter,
//             child: CustomAppBar(
//               title: Utils.getTranslatedLabel(feesKey),
//               onPressBackButton: () {
//                 Get.back();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
}
