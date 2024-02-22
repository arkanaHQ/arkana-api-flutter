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
import 'dart:math';

void main() {
  test('test signin', () async {
    String baseArkanaURL =
        "http://localhost:9092"; // "https://dev-infra.arkana.gg"; https://api.eastblue.io
    String arkanaVerifyURL = baseArkanaURL + "/auth/verify/akoma";
    String arkanaSaveKeysURL = baseArkanaURL + "/auth/save-keys";

    String kmsUrl =
        "https://1hxlogyd63.execute-api.ap-southeast-1.amazonaws.com";

    String kmsEncryptUrl = kmsUrl + "/encrypt";
    String kmsDecryptUrl = kmsUrl + "/decrypt";

    String akomaAuthorization =
        "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFlYzU4NjcwNGNhOTZiZDcwMzZiMmYwZDI4MGY5NDlmM2E5NzZkMzgiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiSXJmaSBBbnRvIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hLS9BQ05QRXVfbnZwRmtrY0lBbURKMFM0eDZsaWJ1R2s5TEpSY2FqQmp1cXdjYU1RPXM5Ni1jIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL3BhcmFzLWNvbWljLW1vYmlsZSIsImF1ZCI6InBhcmFzLWNvbWljLW1vYmlsZSIsImF1dGhfdGltZSI6MTcwODU4NTEzNiwidXNlcl9pZCI6IllvQmpsOGdWVG9meExuT1pXRFVJbU9saXdHQjMiLCJzdWIiOiJZb0JqbDhnVlRvZnhMbk9aV0RVSW1PbGl3R0IzIiwiaWF0IjoxNzA4NTg1MTM3LCJleHAiOjE3MDg1ODg3MzcsImVtYWlsIjoiaXJmaTE0N0BnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjEwMzI0MTgxMjkxMzg1MjIzMDYxMiJdLCJlbWFpbCI6WyJpcmZpMTQ3QGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6Imdvb2dsZS5jb20ifX0.RBHXJ8gI8qvnpv1X1O0gjSmdC3Zo0EIE5ThqcH4hvqoGhwx2KHTksrPx2_NrHRVy3RHnEVxc-sNqEFfe9BA8Trq5cGUNmuADKZ4GagPrlr3AJCxJ_Ty6dfdD0tLXQsLh2oLO30PHkE7zU5HdPfA7hXihH3f7Ym5T_GQAhW_BOzzGK79D706UdIsIPaW5_8HFekrNy3mpJrcFPvaBqq75LEMAUprleqRZ8HJxS2yv6wvdoGVTpaeenNNi5O_IhfXz3Hr6pbkBC-BONkNl_9eDoC9CpYHsDhXhw1K3GdDeNdfbxegcrSUQlO64-gNbOHSCdP1KC6yu9fWZPgFHXwdtqw";

    Map<String, String> headers = {};
    headers[Constants.contentType] = Constants.applicationJson;
    headers["x-client-id"] =
        "670fd4bd0518972b8353b61d002602aa7a14250aa60f1cdb934ddd364aa188fcc93240e5f9804aca474deb446e7770c9";

    Map<String, String> headersKMS = {};
    headersKMS[Constants.contentType] = Constants.applicationJson;

    var body = json.encode({"id_token": akomaAuthorization});

    http.Response responseDataTransaction = await http
        .post(Uri.parse(arkanaVerifyURL), headers: headers, body: body);

    // 1. If already registered

    dynamic response = jsonDecode(responseDataTransaction.body);
    if (response['message']['is_registered'] == true) {
      // save jwtAuth, accountId for delegate action
      String jwtAuth = response['message']['token'];
      String accountId = response['message']['account_id'];

      // recover keypair
      Uint8List encryptedKeyPair =
          base64Decode(response['message']['encrypted_key_pair']);
      String decryptionToken = response['message']['decryption_token'];

      // decode KEK

      var bodyDecryptKMS = json.encode({"input": decryptionToken});

      http.Response responseDecrypt = await http.post(Uri.parse(kmsDecryptUrl),
          headers: headersKMS, body: bodyDecryptKMS);

      dynamic responseDecryptResult = jsonDecode(responseDecrypt.body);

      Uint8List symmetricKey =
          Uint8List.fromList(responseDecryptResult['data'].cast<int>());

      // XOR symmetricKey ^ encryptedKeypair to recover keypair

      Uint8List decryptedKeyPairList = Uint8List(symmetricKey.length);

      for (var i = 0; i < symmetricKey.length; i++) {
        decryptedKeyPairList[i] = symmetricKey[i] ^ encryptedKeyPair[i];
      }

      String decryptedKeypair = new String.fromCharCodes(decryptedKeyPairList);

      KeyPair keyPair = KeyStore.fromSecret(decryptedKeypair.split(":")[1]);
      String publicKey = KeyStore.publicKeyToString(keyPair.publicKey);
      print(publicKey);
    } else {
      // 2. not registered
      print(response);
      String jwtAuth = response['message']['token'];

      // generate new keypair
      KeyPair newKeypair = KeyStore.newKeyPair();
      var secretKey =
          "ed25519:" + KeyStore.privateKeyToString(newKeypair.privateKey);
      var publicKey = KeyStore.publicKeyToString(newKeypair.publicKey);
      print(secretKey);

      // generate randombytes
      // https://stackoverflow.com/questions/61919395/how-to-generate-random-string-in-dart
      Random _random = Random();
      Uint8List symmetricKey = Uint8List(secretKey.length);

      const _chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

      for (var i = 0; i < symmetricKey.length; i++) {
        symmetricKey[i] = _chars.codeUnitAt(_random.nextInt(_chars.length));
      }

      // encrypt secretkey with xor
      Uint8List secretKeyList = Uint8List.fromList(secretKey.codeUnits);
      Uint8List encryptedKeypair = Uint8List(secretKey.length);

      for (var i = 0; i < symmetricKey.length; i++) {
        encryptedKeypair[i] = symmetricKey[i] ^ secretKeyList[i];
      }

      String encryptedKeypairB64 = base64.encode(encryptedKeypair);

      // encrypt symmetricKey
      var bodyEncryptKMS =
          json.encode({"input": new String.fromCharCodes(symmetricKey)});

      http.Response responseEncrypt = await http.post(Uri.parse(kmsEncryptUrl),
          headers: headersKMS, body: bodyEncryptKMS);
      dynamic responseEncryptResult = jsonDecode(responseEncrypt.body);

      Uint8List encryptedSymmetricKey =
          Uint8List.fromList(responseEncryptResult['data'].cast<int>());
      String encryptedSymmetricKeyB64 = base64.encode(encryptedSymmetricKey);

      Map<String, String> headers = {};
      headers[Constants.contentType] = Constants.applicationJson;
      headers["x-client-id"] =
          "670fd4bd0518972b8353b61d002602aa7a14250aa60f1cdb934ddd364aa188fcc93240e5f9804aca474deb446e7770c9";
      headers["authorization"] = jwtAuth;

      var bodySaveKeys = json.encode({
        "new_public_key": publicKey,
        "encrypted_key_pair": encryptedKeypairB64,
        "encrypted_symmetric_key": encryptedSymmetricKeyB64
      });

      http.Response responseSaveKeysJson = await http.post(
          Uri.parse(arkanaSaveKeysURL),
          headers: headers,
          body: bodySaveKeys);

      dynamic responseSaveKeys = jsonDecode(responseSaveKeysJson.body);
      String token = responseSaveKeys.token; // new jwt for auth
      String accountId = responseSaveKeys.account_id; // new near account_id
    }
  });
}
