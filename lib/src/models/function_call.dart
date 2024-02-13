import 'dart:typed_data';

class FunctionCallActionDelegate {
  String methodName;
  Uint8List args;
  BigInt gas;
  BigInt deposit;

  FunctionCallActionDelegate(this.methodName, this.args, this.gas, this.deposit);
}