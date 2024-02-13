import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:near_api_flutter/src/models/access_key.dart';
import 'package:near_api_flutter/src/models/action.dart';
import 'package:near_api_flutter/src/models/actions/delegate_action.dart';
import '../constants.dart';
import 'dart:developer';
import '../models/actions/action_function_call.dart';

/// Stores near testnet rpc configuration
class NEARTestNetRPCProvider extends RPCProvider {
  static final NEARTestNetRPCProvider _nearTestNetRPCProvider =
      NEARTestNetRPCProvider._internal();

  factory NEARTestNetRPCProvider() {
    return _nearTestNetRPCProvider;
  }

  NEARTestNetRPCProvider._internal()
      : super('https://archival-rpc.testnet.near.org');
}

/// Manages RPC calls
abstract class RPCProvider {
  String providerURL;

  RPCProvider(this.providerURL);

  Future<int> getBlockHeight() async {
    var body = json.encode({
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "block",
      "params": {
        "finality": "final"
      }
    });

    Map<String, String> headers = {};
    headers[Constants.contentType] = Constants.applicationJson;

    http.Response responseData =
        await http.post(Uri.parse(providerURL), headers: headers, body: body);

    Map<String, dynamic> jsonBody = jsonDecode(responseData.body);
    return jsonBody['result']['header']['height'];
  }

  /// Calls near RPC API's getAccessKeys for nonce and block hash
  Future<AccessKey> findAccessKey(accountId, publicKey) async {
    var body = json.encode({
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "query",
      "params": {
        "request_type": "view_access_key",
        "finality": "final",
        "account_id": accountId,
        "public_key": "ed25519:$publicKey"
      }
    });
    Map<String, String> headers = {};
    headers[Constants.contentType] = Constants.applicationJson;

    http.Response responseData =
        await http.post(Uri.parse(providerURL), headers: headers, body: body);

    dynamic jsonBody = jsonDecode(responseData.body);
    return AccessKey.fromJson(jsonBody['result']);
  }

  /// Calls near RPC API's broadcast_tx_commit to broadcast the transaction and waits until transaction is fully complete.
  Future<Map<dynamic, dynamic>> broadcastTransaction(
      String encodedTransaction) async {
    var body = json.encode({
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "broadcast_tx_commit",
      "params": [encodedTransaction]
    });
    Map<String, String> headers = {};
    headers[Constants.contentType] = Constants.applicationJson;

    try {
      http.Response responseData =
          await http.post(Uri.parse(providerURL), headers: headers, body: body);
      Map jsonBody = jsonDecode(responseData.body);
      return jsonBody;
    } catch (exp) {
      return {"EXCEPTION": exp};
    }
  }

  Future<Uint8List> buildDelegateAction(List<FunctionCallAction> actions, BigInt maxBlockHeight, BigInt nonce, String publicKey, String receiverId, String senderId) async {
    // TODO: support other action type
    return DelegateAction(
        actions: actions,
        maxBlockHeight: maxBlockHeight,
        nonce: nonce,
        publicKey: publicKey,
        receiverId: receiverId,
        senderId: senderId
    ).toBorsh();
  }

  /// Allows you to call a contract method as a view function.
  Future<Map<dynamic, dynamic>> callViewFunction(
      String contractId, String methodName, String methodArgs) async {
    var body = json.encode({
      "jsonrpc": "2.0",
      "id": "dontcare",
      "method": "query",
      "params": {
        "request_type": "call_function",
        "finality": "final",
        "account_id": contractId,
        "method_name": methodName,
        "args_base64": methodArgs
      }
    });

    Map<String, String> headers = {};
    headers[Constants.contentType] = Constants.applicationJson;

    try {
      http.Response responseData =
          await http.post(Uri.parse(providerURL), headers: headers, body: body);
      Map jsonBody = jsonDecode(responseData.body);
      return jsonBody;
    } catch (exp) {
      return {"EXCEPTION": exp};
    }
  }
}
