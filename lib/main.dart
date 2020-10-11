import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  Client client = Client();
  Account account = Account(client);
  Storage storage = Storage(client);
  Database database = Database(client);

  client
          .setEndpoint(
              'https://localhost/v1') // Make sure your endpoint is accessible from your emulator, use IP if needed
          .setProject('5e8cf4f46b5e8') // Your project ID
          .setSelfSigned() // Do not use this in production
      ;

  runApp(MaterialApp(
    home: Playground(client: client, account: account, storage: storage),
  ));
}

class Playground extends StatefulWidget {
  Playground({this.client, this.account, this.storage, this.database});
  final Client client;
  final Account account;
  final Storage storage;
  final Database database;

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  String username = "Loading...";

  @override
  void initState() {
    widget.account.get().then((response) {
      setState(() {
        username = response.data['name'];
      });
    }).catchError((error) {
      print(error);
      setState(() {
        username = 'Anonymous User';
      });
    });

    FilePicker.getFile(type: FileType.image).then((response) {
      MultipartFile.fromFile(response.path,
              filename: response.path.split('/').last)
          .then((response) {
        widget.storage.createFile(file: response, read: ['*'], write: []).then(
            (response) {
          print(response);
        }).catchError((error) {
          print(error.response);
        });
      }).catchError((error) {
        print(error);
      });
    }).catchError((error) {
      print(error);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget customButton(String name,Color btnColor){
      return ButtonTheme(
        minWidth: 280.0,
        height: 50.0,
        child: RaisedButton(
            child: Text(name,
                style: TextStyle(color: Colors.white, fontSize: 20.0)),
            color: btnColor,
            onPressed: () {
              widget.account
                  .deleteSession(sessionId: 'current')
                  .then((response) {
                setState(() {
                  username = 'Anonymous User';
                });
              }).catchError((error) {
                print('error');
                print(error.response);
              });
            }),
      );
    }

    return Scaffold(
        appBar: AppBar(
            title: Text("Appwrite + Flutter = ❤️"),
            backgroundColor: Colors.pinkAccent[200]),
        body: Container(
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
          Padding(padding: EdgeInsets.all(20.0)),
                InkWell(
                    child: customButton("Login with Email",Colors.grey),
                    onTap: (){
                      widget.account
                          .createSession(
                          email: 'test2@appwrite.io', password: 'eldad12')
                          .then((value) {
                        print(value);
                      }).catchError((error) {
                        print(error.message);
                      });
                    },
                ),
          Padding(padding: EdgeInsets.all(20.0)),
                InkWell(
                  child: customButton("Create Doc",Colors.blue),
                  onTap: (){
                    widget.database
                        .createDocument(
                        collectionId: '5f2e3c52f03c0',
                        data: {'username': 'hello2'},
                        read: ['*'],
                        write: ['*'])
                        .then((value) {})
                        .catchError((error) {
                      print(error.response);
                    });
                  },
                ),
          Padding(padding: EdgeInsets.all(20.0)),
                  InkWell(
                    child: customButton("Login with Facebook",Colors.blue),
                    onTap: (){
                      widget.account
                          .createOAuth2Session(provider: 'facebook')
                          .then((value) {
                        widget.account.get().then((response) {
                          setState(() {
                            username = response.data['name'];
                          });
                        }).catchError((error) {
                          setState(() {
                            username = 'Anonymous User';
                          });
                        });
                      });
                    },
                  ),
          Padding(padding: EdgeInsets.all(10.0)),
                  InkWell(
                    child: customButton("Login with GitHub",Colors.black87),
                    onTap: (){
                      widget.account
                          .createOAuth2Session(
                          provider: 'github', success: '', failure: '')
                          .then((value) {
                        widget.account.get().then((response) {
                          setState(() {
                            username = response.data['name'];
                          });
                        }).catchError((error) {
                          setState(() {
                            username = 'Anonymous User';
                          });
                        });
                      });
                    },
                  ),
          Padding(padding: EdgeInsets.all(10.0)),
                  InkWell(
                    child: customButton("Login with Google",Colors.red),
                    onTap: (){
                      widget.account
                          .createOAuth2Session(provider: 'google')
                          .then((value) {
                        widget.account.get().then((response) {
                          setState(() {
                            username = response.data['name'];
                          });
                        }).catchError((error) {
                          setState(() {
                            username = 'Anonymous User';
                          });
                        });
                      });
                    },
                  ),
          Padding(padding: EdgeInsets.all(20.0)),
          Divider(),
          Padding(padding: EdgeInsets.all(20.0)),
          Text(username, style: TextStyle(color: Colors.black, fontSize: 20.0)),
          Padding(padding: EdgeInsets.all(20.0)),
          Divider(),
          Padding(padding: EdgeInsets.all(20.0)),
                  InkWell(
                    child: customButton('Logout',Colors.red[700]),
                    onTap: (){
                      widget.account
                          .deleteSession(sessionId: 'current')
                          .then((response) {
                        setState(() {
                          username = 'Anonymous User';
                        });
                      }).catchError((error) {
                        print('error');
                        print(error.response);
                      });
                    },
                  ),
          Padding(padding: EdgeInsets.all(20.0)),
        ]))));
  }
}
