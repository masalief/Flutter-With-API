import 'dart:convert';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

TextEditingController inputNama = TextEditingController();
TextEditingController inputEmail = TextEditingController();
TextEditingController inputGender = TextEditingController();

String localAddres = "192.168.43.49:8082";

final editNama = TextEditingController();
final edittEmail = TextEditingController();
final editGender = TextEditingController();
Future<http.Response> getData() async {
  var result = await http.get(Uri.parse("http://$localAddres/api/user/getAll"));
  print(result.body);
  return result;
}

Future<http.Response> postData() async {
  Map<String, dynamic> data = {
    "nama": inputNama.text,
    "email": inputEmail.text,
    "gender": inputGender.text
  };
  var result = await http.post(
    Uri.parse("http://$localAddres/api/user/insert"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: jsonEncode(data),
  );
  return result;
}

Future<http.Response> updateData(id) async {
  Map<String, dynamic> data = {
    "nama": editNama.text,
    "email": edittEmail.text,
    "gender": editGender.text,
  };
  var result = await http.put(
    Uri.parse("http://$localAddres/api/user/update/${id}"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: jsonEncode(data),
  );

  return result;
}

Future<http.Response> deleteData(id) async {
  var result = await http.delete(
    Uri.parse("http://$localAddres/api/user/delete/${id}"),
    headers: <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
    },
  );
  return result;
}

class NetworkApi extends StatefulWidget {
  NetworkApi({super.key});

  @override
  State<NetworkApi> createState() => _NetworkApiState();
}

class _NetworkApiState extends State<NetworkApi> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // print(postData());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "INI PAKAI API",
        ),
        centerTitle: true,
      ),
      body: Container(
        child: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<dynamic> json = jsonDecode(snapshot.data!.body);
              return ListView.builder(
                itemCount: json.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.all(15.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(json[index]['nama'][0],
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.pink,
                      ),
                      title: Text(
                          "${json[index]['nama']} | ${json[index]['gender']}"),
                      subtitle: Text("${json[index]['email']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: (() {
                              editNama.text = json[index]["nama"];
                              edittEmail.text = json[index]["email"];
                              editGender.text = json[index]["gender"];
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: const Text(
                                          'Update User',
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Name cannot be empty";
                                                  }
                                                  return null;
                                                },
                                                controller: editNama,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Nama',
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Email cannot be empty";
                                                  }
                                                  if (!EmailValidator.validate(
                                                      value)) {
                                                    return "Please insert correct email";
                                                  }
                                                  return null;
                                                },
                                                controller: edittEmail,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Email',
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              TextFormField(
                                                controller: editGender,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Gender',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  editNama.clear();
                                                  edittEmail.clear();
                                                  editGender.clear();
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Cancel',
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await updateData(
                                                    json[index]['id'],
                                                  );
                                                  editNama.clear();
                                                  edittEmail.clear();
                                                  editGender.clear();
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                            }),
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await deleteData(json[index]['id']);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'TAMBAH PENGGUNA',
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Mohon isi nama";
                        }
                        return null;
                      },
                      controller: inputNama,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'NAMA',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Mohon isi email";
                        }
                        if (!EmailValidator.validate(value)) {
                          return "Please insert correct email";
                        }
                        return null;
                      },
                      controller: inputEmail,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'EMAIL',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: inputGender,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'GENDER',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text(
                        'CANCEL',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await postData();
                          inputNama.clear();
                          inputEmail.clear();
                          inputGender.clear();
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      child: const Text('OKAY'),
                    ),
                  ],
                )
              ],
            ),
          );
          //
        },
      ),
    );
  }
}
