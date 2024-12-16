// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
part 'support_category.g.dart';

@JsonSerializable()
class SupportCategory {
  @JsonKey(name: 'category_id')
  final int categoryId;
  @JsonKey(name: 'category_name')
  final String categoryName;
  @JsonKey(name: 'parent_category')
  final int? parentCategory;

  SupportCategory(
      {required this.categoryId,
      required this.categoryName,
      required this.parentCategory});

  factory SupportCategory.fromJson(Map<String, dynamic> json) =>
      _$SupportCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$SupportCategoryToJson(this);
}
