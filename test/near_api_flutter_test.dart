import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:near_api_flutter/near_api_flutter.dart';
import 'package:near_api_flutter/src/constants.dart';
import 'package:near_api_flutter/src/models/actions/action_function_call.dart';
import 'package:near_api_flutter/src/models/action_types.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

void main() {
  test('signed delegate works', () async {
    // network and wallet config data
    const String networkId = "testnet";
    const String walletURL = 'https://wallet.testnet.near.org/login/?';
    const String walletApproveTransactionUrl =
        'https://wallet.testnet.near.org/sign?';
    const String helperUrl = 'https://helper.testnet.near.org"';
    const String explorerUrl = 'https://explorer.testnet.near.org';
    const String rpcUrl = 'https://archival-rpc.testnet.near.org';
    const String globalServer =
        'https://near-transaction-serializer.herokuapp.com';
    const String nearSignInSuccessUrl = '$globalServer/success';
    const String nearSignInFailUrl = '$globalServer/failure';

    const String arkanaInfraUrl = 'https://dev-api.arkana.gg/v2/transaction';

    const String accountId = 'displacedbookstore35022.unittest1.testnet';
    const String secretKey =
        '4swPvdq3wBY6KaFcAvhuyByL4E8orQzN21knhx52wUF2YoKJf4v9KSiP7HiHPvZLS7462ztQ5kKU8tQNTt234RQi';

    KeyPair keyPair = KeyStore.fromSecret(secretKey);

    String publicKey = KeyStore.publicKeyToString(keyPair.publicKey);

    var block = await NEARTestNetRPCProvider().getBlockHeight();
    AccessKey keys =
        await NEARTestNetRPCProvider().findAccessKey(accountId, publicKey);
    var delegate = await NEARTestNetRPCProvider().buildDelegateAction([
      FunctionCallAction(
          actionNumber: ActionType.functionCall.value,
          functionCallActionArgs: FunctionCallActionArgs(
              methodName: 'nft_buy',
              args:
                  '{"token_series_id":"1200","receiver_id":"unittest1.testnet"}',
              gas: BigInt.from(1000000),
              deposit: Utils.decodeNearDeposit('1')))
    ], BigInt.from(block) + BigInt.from(60), BigInt.from(keys.nonce), publicKey,
        accountId, accountId);

    var body = json.encode({"delegate": '$delegate', "account_id": accountId});
    print(body);

    Map<String, String> headers = {};
    headers[Constants.contentType] = Constants.applicationJson;
    headers["Authorization"] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoianVtYm9lZmZpY2FjeTY2NzAxODQuYXJrYW5hLWJ1aWRsLWFzaWEudGVzdG5ldCIsImVtYWlsIjoiaXJmaTE0N0BnbWFpbC5jb20iLCJpYXQiOjE3MDc4MTY0OTgsImV4cCI6MTcwODQyMTI5OH0.VBvG2TcXYzsO1HsMAmpx5UABFHbqUf2PGZ2cZjV4Uvk";

    try {
      http.Response responseData =
          await http.post(Uri.parse(arkanaInfraUrl), headers: headers, body: body);
      Map jsonBody = jsonDecode(responseData.body);
      print(jsonBody);
    } catch (exp) {
      return {"EXCEPTION": exp};
    }
  });
}
