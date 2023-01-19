import 'dart:convert';

import 'package:http/http.dart' as http;

class UserModel {
  int id;
  String nama;
  String email;
  String gender;

  UserModel(
      {required this.id,
      required this.nama,
      required this.email,
      required this.gender});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      nama: json["nama"],
      email: json["email"],
      gender: json["gender"],
    );
  }
}

String myIp = "192.168.43.49";

Future<List<UserModel>> getAll() async {
  final result =
      await http.get(Uri.parse('http://${myIp}:8082/api/user/getAll'));

  Iterable i = jsonDecode(result.body);
  List<UserModel> usersData =
      List<UserModel>.from(i.map((e) => UserModel.fromJson(e)));
  if (result.statusCode == 200) {
    return usersData;
  } else {
    throw Exception('Failed to load album');
  }
}

Future<http.Response> createUser(UserModel data) {
  return http.post(Uri.parse("http://${myIp}:8082/api/user/insert"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nama': data.nama,
        'email': data.email,
        'gender': data.gender,
      }));
}

Future<http.Response> updateUser(int id, UserModel data) async {
  var result =
      await http.put(Uri.parse("http://${myIp}:8082/api/user/update/${id}"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'nama': data.nama,
            'email': data.email,
            'gender': data.gender,
          }));
  return result;
}

Future<http.Response> deleteUser(int id) {
  return http.delete(Uri.parse("http://${myIp}:8082/api/user/delete/${id}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });
}
