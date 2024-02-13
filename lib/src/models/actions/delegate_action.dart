import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:near_api_flutter/src/models/actions/action_function_call.dart';

part 'delegate_action.g.dart';

@BorshSerializable()
class DelegateAction with _$DelegateAction {
  factory DelegateAction({
    @BArray(BFunctionCallAction())
    required List<FunctionCallAction> actions,
    @BU64()
    required BigInt maxBlockHeight,
    @BU64()
    required BigInt nonce,
    @BString()
    required String publicKey,
    @BString()
    required String receiverId,
    @BString()
    required String senderId,
  }) = _DelegateAction;

  DelegateAction._();

  factory DelegateAction.fromBorsh(Uint8List data) => _$DelegateActionFromBorsh(data);
}