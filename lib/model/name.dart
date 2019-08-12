import 'package:json_annotation/json_annotation.dart';

part 'name.g.dart';

List<Name> getNamesList(List<dynamic> list) {
  List<Name> result = [];
  list.forEach((item) {
    result.add(Name.fromJson(item));
  });
  return result;
}

@JsonSerializable()
class Name extends Object {
  @JsonKey(name: 'first_name')
  String firstName;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'weight')
  int weight;

  Name(
    this.firstName,
    this.name, {
    this.weight = 1,
  });

  factory Name.fromJson(Map<String, dynamic> srcJson) =>
      _$NameFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NameToJson(this);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['first_name'] = firstName;
    map['name'] = name;
    map['weight'] = weight;
    return map;
  }

  bool isEmpty() {
    return (firstName == null && name == null) ||
        (firstName.isEmpty && name.isEmpty) ||
        (firstName == null && name.isEmpty) ||
        (firstName.isEmpty && name == null);
  }

  @override
  String toString() {
    return '($firstName,$name)';
  }

  @override
  bool operator ==(other) {
    return firstName == other.firstName && name == other.name;
  }

  @override
  int get hashCode => super.hashCode;
}
