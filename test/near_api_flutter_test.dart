import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:near_api_flutter/src/transaction_api/transaction_manager.dart';
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

    // const String arkanaInfraUrl = 'https://dev-api.arkana.gg/v2/transaction';
    const String arkanaInfraUrl = 'http://localhost:9092/transaction/build-delegate-action';
    const String arkanaInfraUrlSign = 'http://localhost:9092/transaction/signed-delegate-action';
    const String arkanaInfraUrlTransaction = 'http://localhost:9092/transaction';

    const String accountId = 'displacedbookstore35022.unittest1.testnet';
    const String secretKey =
        '4swPvdq3wBY6KaFcAvhuyByL4E8orQzN21knhx52wUF2YoKJf4v9KSiP7HiHPvZLS7462ztQ5kKU8tQNTt234RQi';

    KeyPair keyPair = KeyStore.fromSecret(secretKey);

    String publicKey = KeyStore.publicKeyToString(keyPair.publicKey);

    var body = json.encode({"account_id": accountId, "public_key": publicKey, "method_name": "call_aikoma_on"});

    Map<String, String> headers = {};
    headers[Constants.contentType] = Constants.applicationJson;
    headers["Authorization"] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoianVtYm9lZmZpY2FjeTY2NzAxODQuYXJrYW5hLWJ1aWRsLWFzaWEudGVzdG5ldCIsImVtYWlsIjoiaXJmaTE0N0BnbWFpbC5jb20iLCJpYXQiOjE3MDc4MTY0OTgsImV4cCI6MTcwODQyMTI5OH0.VBvG2TcXYzsO1HsMAmpx5UABFHbqUf2PGZ2cZjV4Uvk";
    headers["x-client-id"] = "670fd4bd0518972b8353b61d002602aa7a14250aa60f1cdb934ddd364aa188fcc93240e5f9804aca474deb446e7770c9";

    try {
      http.Response responseData =
          await http.post(Uri.parse(arkanaInfraUrl), headers: headers, body: body);
      dynamic jsonBody = jsonDecode(responseData.body);
      dynamic jsonBodyData = jsonBody['result'];
      dynamic jsonBodyDelegateAction = jsonBodyData['delegate_action'];
      dynamic jsonBodyMessage = jsonDecode(jsonBodyData['message_string']);
      dynamic jsonBodyMessageHash = jsonBodyData['message_hash'];
      dynamic jsonBodyMessageData = jsonBodyMessage['data'];

      // Klo pake ini muncul pas diprint
      List<int> array = [110, 1, 0, 64, 41, 0, 0, 0, 100, 105, 115, 112, 108, 97, 99, 101, 100, 98, 111, 111, 107, 115, 116, 111, 114, 101, 51, 53, 48, 50, 50, 46, 117, 110, 105, 116, 116, 101, 115, 116, 49, 46, 116, 101, 115, 116, 110, 101, 116, 32, 0, 0, 0, 100, 101, 118, 45, 49, 54, 56, 55, 51, 54, 48, 56, 52, 51, 52, 48, 53, 45, 50, 53, 51, 55, 56, 49, 49, 48, 53, 54, 55, 51, 50, 54, 1, 0, 0, 0, 2, 11, 0, 0, 0, 97, 99, 116, 105, 111, 110, 95, 108, 111, 103, 115, 89, 1, 0, 0, 123, 34, 97, 99, 116, 105, 111, 110, 95, 108, 111, 103, 115, 34, 58, 91, 123, 34, 97, 99, 116, 105, 111, 110, 34, 58, 34, 123, 92, 34, 102, 117, 110, 99, 116, 105, 111, 110, 67, 97, 108, 108, 92, 34, 58, 123, 92, 34, 109, 101, 116, 104, 111, 100, 78, 97, 109, 101, 92, 34, 58, 92, 34, 99, 97, 108, 108, 95, 97, 105, 107, 111, 109, 97, 95, 111, 110, 92, 34, 44, 92, 34, 97, 114, 103, 115, 92, 34, 58, 92, 34, 101, 51, 48, 61, 92, 34, 44, 92, 34, 103, 97, 115, 92, 34, 58, 92, 34, 49, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 92, 34, 44, 92, 34, 100, 101, 112, 111, 115, 105, 116, 92, 34, 58, 48, 125, 44, 92, 34, 101, 110, 117, 109, 92, 34, 58, 92, 34, 102, 117, 110, 99, 116, 105, 111, 110, 67, 97, 108, 108, 92, 34, 125, 34, 44, 34, 115, 105, 103, 110, 97, 116, 117, 114, 101, 34, 58, 34, 101, 121, 74, 109, 100, 87, 53, 106, 100, 71, 108, 118, 98, 107, 78, 104, 98, 71, 119, 105, 79, 110, 115, 105, 98, 87, 86, 48, 97, 71, 57, 107, 84, 109, 70, 116, 90, 83, 73, 54, 73, 109, 78, 104, 98, 71, 120, 102, 89, 87, 108, 114, 98, 50, 49, 104, 88, 50, 57, 117, 73, 105, 119, 105, 89, 88, 74, 110, 99, 121, 73, 54, 73, 109, 85, 122, 77, 68, 48, 105, 76, 67, 74, 110, 89, 88, 77, 105, 79, 105, 73, 120, 77, 68, 65, 119, 77, 68, 65, 119, 77, 68, 65, 119, 77, 68, 65, 119, 77, 67, 73, 115, 73, 109, 82, 108, 99, 71, 57, 122, 97, 88, 81, 105, 79, 106, 66, 57, 76, 67, 74, 108, 98, 110, 86, 116, 73, 106, 111, 105, 90, 110, 86, 117, 89, 51, 82, 112, 98, 50, 53, 68, 89, 87, 120, 115, 73, 110, 48, 61, 34, 125, 93, 125, 0, 160, 114, 78, 24, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 206, 183, 156, 131, 5, 118, 0, 0, 145, 11, 103, 9, 0, 0, 0, 0, 0, 181, 229, 255, 112, 254, 236, 252, 39, 117, 74, 211, 249, 120, 29, 31, 75, 179, 72, 199, 238, 85, 98, 98, 87, 179, 41, 209, 74, 23, 107, 77, 183];

      // Kalo pake ini gamuncul pas diprint
      // List<int> array = jsonBodyDataArr;

      Uint8List hashMessage = Uint8List.fromList(jsonBodyMessageHash.cast<int>());
      print(hashMessage);

      Uint8List uint8List = Uint8List.fromList(array);
      Uint8List hashedSerializedTx = TransactionManager.toSHA256(uint8List);
      Uint8List signature = TransactionManager.signTransaction(keyPair.privateKey, hashMessage);

      var bodySign = json.encode({"delegate_action": jsonBodyDelegateAction, "signature": signature});
      http.Response responseDataSign =
          await http.post(Uri.parse(arkanaInfraUrlSign), headers: headers, body: bodySign);

      dynamic jsonBodySign = jsonDecode(responseDataSign.body);
      dynamic jsonBodySignResult = jsonBodySign['result'];
      dynamic jsonBodySignData = jsonDecode(jsonBodySignResult['encoded_signed_delegate']);

      var bodyTransaction = json.encode({"delegate": jsonBodySignData});
      http.Response responseDataTransaction =
          await http.post(Uri.parse(arkanaInfraUrlTransaction), headers: headers, body: bodyTransaction);


    } catch (exp) {
      print(exp);
    }
  });
}
