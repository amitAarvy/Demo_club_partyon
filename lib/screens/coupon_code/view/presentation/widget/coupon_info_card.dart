// import 'package:club/screens/refer/presentation/views/widgets/refer_info_row.dart';
// import 'package:flutter/material.dart';
//
// class CouponInfoCard extends StatefulWidget {
//   final String couponCode;
//   final String validFrom;
//   final String validUntil;
//   final String couponCategory;
//   final String editedCouponCode;
//   final String name;
//
//   const CouponInfoCard({super.key,
//     required this.couponCode,
//     required this.validFrom,
//     required this.validUntil,
//     required this.couponCategory,
//     required this.editedCouponCode, required this.name});
//
//   @override
//   State<CouponInfoCard> createState() => _CouponInfoCardState();
// }
//
// class _CouponInfoCardState extends State<CouponInfoCard> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.black,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             ReferInfoRow(text: widget.name),
//             ReferInfoRow(text: widget.couponCode),
//             ReferInfoRow(text: '${widget.validFrom} - ${widget.validUntil}'),
//             Expanded(
//               child: Center(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         '${widget.editedCouponCode} shared',
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () async {},
//                         // => onTapView(widget.uid),
//                       child: const Text(
//                         'Edit Coupon Code',
//                         style: TextStyle(color: Colors.amber),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
