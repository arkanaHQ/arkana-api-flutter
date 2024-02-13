// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delegate_action.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$DelegateAction {
  List<FunctionCallAction> get actions => throw UnimplementedError();
  BigInt get maxBlockHeight => throw UnimplementedError();
  BigInt get nonce => throw UnimplementedError();
  String get publicKey => throw UnimplementedError();
  String get receiverId => throw UnimplementedError();
  String get senderId => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BArray(BFunctionCallAction()).write(writer, actions);
    const BU64().write(writer, maxBlockHeight);
    const BU64().write(writer, nonce);
    const BString().write(writer, publicKey);
    const BString().write(writer, receiverId);
    const BString().write(writer, senderId);

    return writer.toArray();
  }
}

class _DelegateAction extends DelegateAction {
  _DelegateAction({
    required this.actions,
    required this.maxBlockHeight,
    required this.nonce,
    required this.publicKey,
    required this.receiverId,
    required this.senderId,
  }) : super._();

  final List<FunctionCallAction> actions;
  final BigInt maxBlockHeight;
  final BigInt nonce;
  final String publicKey;
  final String receiverId;
  final String senderId;
}

class BDelegateAction implements BType<DelegateAction> {
  const BDelegateAction();

  @override
  void write(BinaryWriter writer, DelegateAction value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  DelegateAction read(BinaryReader reader) {
    return DelegateAction(
      actions: const BArray(BFunctionCallAction()).read(reader),
      maxBlockHeight: const BU64().read(reader),
      nonce: const BU64().read(reader),
      publicKey: const BString().read(reader),
      receiverId: const BString().read(reader),
      senderId: const BString().read(reader),
    );
  }
}

DelegateAction _$DelegateActionFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BDelegateAction().read(reader);
}
