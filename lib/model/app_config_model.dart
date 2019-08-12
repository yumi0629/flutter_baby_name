import 'package:json_annotation/json_annotation.dart'; 
  
part 'app_config_model.g.dart';


@JsonSerializable()
  class AppConfigModel extends Object {

  @JsonKey(name: 'LoopMode')
  int loopMode;

  @JsonKey(name: 'showFirstName')
  bool showFirstName;

  @JsonKey(name: 'playMusic')
  bool playMusic;

  @JsonKey(name: 'defaultMusic')
  bool defaultMusic;

  @JsonKey(name: 'musicUrl')
  String musicUrl;

  AppConfigModel(this.loopMode,this.showFirstName,this.playMusic,this.defaultMusic,this.musicUrl,);

  factory AppConfigModel.fromJson(Map<String, dynamic> srcJson) => _$AppConfigModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AppConfigModelToJson(this);

}

  
