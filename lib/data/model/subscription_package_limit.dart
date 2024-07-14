// ignore_for_file: public_member_api_docs, sort_constructors_first
// To parse this JSON data, do
//
//     final subcriptionPackageLimit = subcriptionPackageLimitFromMap(jsonString);

import 'dart:convert';

class SubcriptionPackageLimit {
  SubcriptionPackageLimit({
    required this.totalLimitOfAdvertisement,
    required this.totalLimitOfItem,
    required this.usedLimitOfAdvertisement,
    required this.usedLimitOfItem,
  });

  final dynamic totalLimitOfAdvertisement;
  final dynamic totalLimitOfItem;
  final dynamic usedLimitOfAdvertisement;
  final dynamic usedLimitOfItem;

  SubcriptionPackageLimit copyWith({
    dynamic totalLimitOfAdvertisement,
    dynamic totalLimitOfItem,
    dynamic usedLimitOfAdvertisement,
    dynamic usedLimitOfItem,
  }) {
    return SubcriptionPackageLimit(
      totalLimitOfAdvertisement:
          totalLimitOfAdvertisement ?? this.totalLimitOfAdvertisement,
      totalLimitOfItem: totalLimitOfItem ?? this.totalLimitOfItem,
      usedLimitOfAdvertisement:
          usedLimitOfAdvertisement ?? this.usedLimitOfAdvertisement,
      usedLimitOfItem: usedLimitOfItem ?? this.usedLimitOfItem,
    );
  }

  factory SubcriptionPackageLimit.fromJson(String str) =>
      SubcriptionPackageLimit.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SubcriptionPackageLimit.fromMap(Map<String, dynamic> json) =>
      SubcriptionPackageLimit(
        totalLimitOfAdvertisement: json["total_limit_of_advertisement"],
        totalLimitOfItem: json["total_limit_of_item"],
        usedLimitOfAdvertisement: json["used_limit_of_advertisement"],
        usedLimitOfItem: json["used_limit_of_item"],
      );

  Map<String, dynamic> toMap() => {
        "total_limit_of_advertisement": totalLimitOfAdvertisement,
        "total_limit_of_item": totalLimitOfItem,
        "used_limit_of_advertisement": usedLimitOfAdvertisement,
        "used_limit_of_item": usedLimitOfItem,
      };

  @override
  String toString() {
    return 'SubcriptionPackageLimit(totalLimitOfAdvertisement: $totalLimitOfAdvertisement, totalLimitOfItem: $totalLimitOfItem, usedLimitOfAdvertisement: $usedLimitOfAdvertisement, usedLimitOfItem: $usedLimitOfItem)';
  }
}
