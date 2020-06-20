import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:isolate';
import 'dart:io';
import 'dart:async';
import 'dart:ui';

void main() {
  runApp(MaterialApp(
//    home: MyApp(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => MyApp(),
        '/Chat': (context) => Chat(),
      }
  ));

}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: username,
              decoration: InputDecoration(
                  border:  OutlineInputBorder(),
                  hintText: 'Enter username'
              ),
              autofocus: true,
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(
                  border:  OutlineInputBorder(),
                  hintText: 'Enter password'
              ),
              autofocus: false,
              obscureText: true,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: () async{
                      login();
                    },
                    child: Text("Login"),
                    color: Colors.blue[100],
                  ),
                  FlatButton(
                    onPressed: () async{
                      signup();
                    },
                    child: Text("Sign Up"),
                    color: Colors.blue[100],
                  ),
                ],
              )
            )
          ],
        ),
      )
    );
  }
  void login() async {
    Response response = await get("http://165.22.14.77:8080/Anudeep/chat2/Login.jsp?UserName=" + username.text + "&Password=" + password.text);
    print(response);
    if (response.body.contains("success")) {
      Fluttertoast.showToast(
        msg: "Login Successful.",
        toastLength: Toast.LENGTH_LONG,
      );
      Navigator.pushNamed(context, '/Chat', arguments: {'username': username.text});
    }
    else {
      Fluttertoast.showToast(
        msg: "Invalid Username or password.",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void signup() async {
    Response response = await get("http://165.22.14.77:8080/Anudeep/chat2/Register.jsp?UserName="+username.text+"&Password="+password.text);
    print(response);
    if (response.body.contains("success")) {
      Fluttertoast.showToast(
        msg: response.body,
        toastLength: Toast.LENGTH_LONG,
      );
    }
    else {
      Fluttertoast.showToast(
        msg: "Try with another username.",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }
}

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Map data = {};
  String activeUsers = "";
  String messages = "";
  Timer timer1, timer2;
  TextEditingController sentMessage = new TextEditingController();


  void getActiveUsers() async
  {
    Response response = await get("http://165.22.14.77:8080/Anudeep/chat2/ActiveUsers.jsp?UserName="+ data['username']);
//    if(this.mounted)
//    {
      setState(() {
        activeUsers = response.body.replaceAll("<br>", "");
      });
//    }
  }

  void getMessages() async
  {
    Response response1 = await get("http://165.22.14.77:8080/Anudeep/chat2/PrintMessages.jsp?UserName=" + data['username']);
    if(this.mounted){
      setState(() {
        messages = messages + response1.body.trim();
      });
    }
  }

  void sendMessage() async
  {
    Response response = await get("http://165.22.14.77:8080/Anudeep/chat2/InsertMessage.jsp?UserName=" + data['username'] + "&Message=" +sentMessage.text);
    sentMessage.clear();
  }


  @override
  void initState() {
    super.initState();
    timer1 = Timer.periodic(Duration(seconds: 3), (Timer t) => getMessages());
    timer2 = Timer.periodic(Duration(seconds: 3), (Timer t) => getActiveUsers());
  }
  @override
  void dispose() {
    timer1?.cancel();
    timer2?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          title: Text("Group Chat"),
        ),
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: <Widget>[
                Text("Active Users",
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(10),
                    width: 300,
                    height: 150,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(activeUsers))),
                Text("Messages",
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(10),
                    width: 300,
                    height: 200,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(messages))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: TextField(
                        controller: sentMessage,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Message',
                        ),
                        autofocus: true,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: RaisedButton(
                        onPressed: (){
                          sendMessage();
                        },
                        child: Text("Send"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

