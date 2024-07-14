import 'dart:convert';

class ItemFilterModel {
  final String maxPrice;
  final String minPrice;
  final String categoryId;
  final String postedSince;
  final String city;
  final String state;
  final String country;
  final String? area;
  final int? areaId;
  final Map<String, dynamic>? customFields;

  ItemFilterModel({
    required this.maxPrice,
    required this.minPrice,
    required this.categoryId,
    required this.postedSince,
    required this.city,
    required this.state,
    required this.country,
    this.area,
    this.areaId,
    this.customFields = const {},
  });

  ItemFilterModel copyWith({
    String? maxPrice,
    String? minPrice,
    String? categoryId,
    String? postedSince,
    String? city,
    String? state,
    String? country,
    String? area,
    int? areaId,
    Map<String, dynamic>? customFields,
  }) {
    return ItemFilterModel(
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      categoryId: categoryId ?? this.categoryId,
      postedSince: postedSince ?? this.postedSince,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      area: area ?? this.area,
      areaId: areaId ?? this.areaId,
      customFields: customFields ?? this.customFields,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'max_price': maxPrice,
      'min_price': minPrice,
      'category_id': categoryId,
      'posted_since': postedSince,
      'city': city,
      'state': state,
      'country': country,
      'area': area,
      'area_id': areaId,
    };
  }

  factory ItemFilterModel.fromMap(Map<String, dynamic> map) {
    return ItemFilterModel(
      city: map['city'].toString(),
      state: map['state'].toString(),
      country: map['country'].toString(),
      maxPrice: map['max_price'].toString(),
      minPrice: map['min_price'].toString(),
      categoryId: map['category_id'].toString(),
      postedSince: map['posted_since'].toString(),
      area: map['area']?.toString(),
      areaId: map['area_id'] != null
          ? int.tryParse(map['area_id'].toString())
          : null,
      customFields: Map<String, dynamic>.from(map['custom_fields'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemFilterModel.fromJson(String source) =>
      ItemFilterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ItemFilterModel(maxPrice: $maxPrice, minPrice: $minPrice, categoryId: $categoryId, postedSince: $postedSince, city: $city, state: $state, country: $country, area: $area, areaId: $areaId, custom_fields: $customFields)';
  }

  factory ItemFilterModel.createEmpty() {
    return ItemFilterModel(
      maxPrice: "",
      minPrice: "",
      categoryId: "",
      postedSince: "",
      city: '',
      state: '',
      country: '',
      area: null,
      areaId: null,
      customFields: {},
    );
  }

  @override
  bool operator ==(covariant ItemFilterModel other) {
    if (identical(this, other)) return true;

    return other.maxPrice == maxPrice &&
        other.minPrice == minPrice &&
        other.categoryId == categoryId &&
        other.postedSince == postedSince &&
        other.city == city &&
        other.state == state &&
        other.country == country &&
        other.area == area &&
        other.areaId == areaId &&
        other.customFields == customFields;
  }

  @override
  int get hashCode {
    return maxPrice.hashCode ^
        minPrice.hashCode ^
        categoryId.hashCode ^
        postedSince.hashCode ^
        city.hashCode ^
        state.hashCode ^
        country.hashCode ^
        area.hashCode ^
        areaId.hashCode ^
        customFields.hashCode;
  }
}
