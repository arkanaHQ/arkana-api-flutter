import 'package:near_api_flutter/src/models/enum.dart';

abstract class Action<T> extends Enum<T> {
  Action(T value): super(value);
}