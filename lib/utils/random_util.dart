import 'dart:math';
import 'package:baby_name/model/name.dart';

class WeightRandom {
  final List<Name> _names;

  int _sum = 0;
  List<int> _weightTmp = [];

  WeightRandom(this._names) {
    _weightTmp.add(0);
    _names.forEach((name) {
      _sum += name.weight;
      _weightTmp.add(_sum);
    });
  }

  Name getRandomName() {
    int rand = Random.secure().nextInt(_sum);
    int index = 0;
    for (int i = _weightTmp.length - 1; i > 0; i--) {
      if (rand >= _weightTmp[i]) {
        index = i;
        break;
      }
    }
    return _names[index];
  }
}
