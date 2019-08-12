// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfigModel _$AppConfigModelFromJson(Map<String, dynamic> json) {
  return AppConfigModel(
      json['LoopMode'] as int,
      json['showFirstName'] as bool,
      json['playMusic'] as bool,
      json['defaultMusic'] as bool,
      json['musicUrl'] as String);
}

Map<String, dynamic> _$AppConfigModelToJson(AppConfigModel instance) =>
    <String, dynamic>{
      'LoopMode': instance.loopMode,
      'showFirstName': instance.showFirstName,
      'playMusic': instance.playMusic,
      'defaultMusic': instance.defaultMusic,
      'musicUrl': instance.musicUrl
    };
