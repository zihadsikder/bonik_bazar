import 'package:eClassify/Utils/Extensions/lib/list.dart';

class PersonalizedInterestSettings {
  final int userId;
  final List<int> categoryIds;
  final List<double> priceRange;
  final List<int> itemType;
  final List<int> outdoorFacilityIds;
  final String city;

  PersonalizedInterestSettings({
    required this.userId,
    required this.categoryIds,
    required this.priceRange,
    required this.itemType,
    required this.outdoorFacilityIds,
    required this.city,
  });

  factory PersonalizedInterestSettings.fromMap(Map<String, dynamic> map) {
    return PersonalizedInterestSettings(
      userId: map['user_id'] ?? 0,
      categoryIds: (map['category_ids'] is String)
          ? []
          : ((map['category_ids']) as List).forceInt(),
      priceRange: (map['price_range'] is String)
          ? [0, 50]
          : (map['price_range'] as List).forceDouble(),
      itemType: (map['item_type'] is String)
          ? []
          : (map['item_type'] as List).forceInt(),
      outdoorFacilityIds: (map['outdoor_facilitiy_ids'] is String)
          ? []
          : ((map['outdoor_facilitiy_ids'] ?? []) as List).forceInt(),
      city: map['city'] ?? '',
    );
  }

  factory PersonalizedInterestSettings.empty() {
    return PersonalizedInterestSettings(
      userId: 0,
      categoryIds: [],
      priceRange: [0, 1],
      itemType: [],
      outdoorFacilityIds: [],
      city: '',
    );
  }

  @override
  String toString() {
    return 'PersonalizedInterestSettings{userId: $userId, categoryIds: $categoryIds, priceRange: $priceRange, itemType: $itemType, outdoorFacilityIds: $outdoorFacilityIds, city: $city}';
  }
}
