// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Name _$NameFromJson(Map<String, dynamic> json) {
  return Name(json['first_name'] as String, json['name'] as String,
      weight: json['weight'] as int);
}

Map<String, dynamic> _$NameToJson(Name instance) => <String, dynamic>{
      'first_name': instance.firstName,
      'name': instance.name,
      'weight': instance.weight
    };
