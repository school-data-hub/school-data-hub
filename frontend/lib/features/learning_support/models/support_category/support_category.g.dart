// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportCategory _$SupportCategoryFromJson(Map<String, dynamic> json) =>
    SupportCategory(
      categoryId: (json['category_id'] as num).toInt(),
      categoryName: json['category_name'] as String,
      parentCategory: (json['parent_category'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SupportCategoryToJson(SupportCategory instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'parent_category': instance.parentCategory,
    };
