import 'package:loggy/loggy.dart';

class TypeGenerator with UiLoggy{
  static TypeGenerator instance = TypeGenerator();

  Map<Type, Function(Map<String, dynamic>)> map = {};

  void add(Type t, Function(Map<String, dynamic>) create) {
    map.putIfAbsent(t, () => create);
  }

  T? create<T>(Map<String, dynamic> params) {
    try {
      return map[T]!(params);
    } catch (e) {
       loggy.warning("error creating an object");
    }

    return null;
  }
}
