import 'dart:convert';
 import 'package:http/http.dart' as http;

class Api {
  static const String apiUrl = "API_URL/LOCALHOST";

  static sendNotificationRequestToFriendToAcceptCall( String roomId,String name,String token  ) async {
    print("000K /"+token);
     var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=AAAA299MT_w:APA91bGci5tf-gBs2UI4OKADg7rfwdh3DNg34neJnlzei6PwgOhVqcPZWWe14bpUWDQFGLkdhc7dAJa7uUu1VJeY6cevW2hJ5Mbu9kB2W2dW3Tu9Z3y32gig2n8DZCB0Q637nGIxRGS0'
    };
    var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "registration_ids": [
        token
        ],
      "notification": {

        "title": "webrtc",
        "android_channel_id": "pushnotification",
        "sound": true
      }
      ,"data":{
        "uuid": 1234,
        "caller_id":  name+"23",
        "caller_name": name,
        "caller_id_type": "number",
        "has_video": "false",
        "room_id": roomId,
        "fcm_token":  token
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print( response.stream.toString()+"000 ok");
      print(await response.stream.bytesToString());
    }
    else {
      print( response.stream.toString()+"111 ok");

      print(response.reasonPhrase);
    }
  }

}
const SHOW = 'SHOW';
const TOKEN = 'TOKEN';
const USER_NAME = 'USER_NAME';

class User {
  static const String nameKey = "name";
  static const String emailKey = "email";
  static const String genderKey = "gender";
  static const String phoneNumberKey = "phone_number";
  static const String birthDateKey = "birthdate";
  static const String locationKey = "location";
  static const String usernameKey = "username";
  static const String passwordKey = "password";
  static const String firstNameKey = "first_name";
  static const String lastNameKey = "last_name";
  static const String titleKey = "title";
  static const String pictureKey = "picture";
  static const String uuidKey = "uuid";
  static const String firebaseTokenKey = "firebase_token";

  final String name;
  final String email;
  final String gender;
  final String phoneNumber;
  final int birthDate;
   final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String title;
  final String picture;
  final String uuid;
  final String firebaseToken;

  User(
      {required this.name,
        required this.email,
        required this.gender,
        required this.phoneNumber,
        required this.birthDate,
         required this.username,
        required this.password,
        required this.firstName,
        required this.lastName,
        required this.title,
        required this.uuid,
        required this.firebaseToken,
        required this.picture});

  factory User.fromJson(Map json) => User(
    name: "${json[firstNameKey]} ${json[lastNameKey]}",
    email: json[emailKey],
    gender: json[genderKey],
    phoneNumber: json[phoneNumberKey],
    birthDate: json[birthDateKey],
     username: json[usernameKey],
    password: json[passwordKey],
    firstName: json[firstNameKey],
    lastName: json[lastNameKey],
    title: json[titleKey],
    firebaseToken: json[firebaseTokenKey]??"",
    uuid: json[uuidKey]??"",
    picture: json[pictureKey],
  );

  toJson() => {
    nameKey: name,
    emailKey: email,
    genderKey: gender,
    phoneNumberKey: phoneNumber,
    birthDateKey: birthDate,
     usernameKey: username,
    passwordKey: password,
    firstNameKey: firstName,
    lastNameKey: lastName,
    titleKey: title,
    uuidKey: uuid,
    firebaseTokenKey: firebaseToken,
    pictureKey: picture,
  };
}

