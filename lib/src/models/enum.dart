abstract class Enum<T> {
  final T value;

  Enum(this.value);

  static T fromMap<T>(Map<String, T> properties) {
    if (properties.length != 1) {
      throw ArgumentError('Enum can only take single value');
    }
    return properties.values.first;
  }
}