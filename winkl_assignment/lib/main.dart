import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/models.dart' as models;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "WinklDemo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget{  
    _FirstPage createState() => _FirstPage();

}
class _FirstPage extends State<FirstPage>{
  var _categoryNameController = new TextEditingController();
  List<models.Pictures> images = new List();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState(){
    super.initState();
    fetchFive();
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        fetchFive();
      }
    });
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor:Colors.black));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0,vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(22.0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding:EdgeInsets.symmetric(horizontal: 5.0),
                  child:TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    
                    hintText: "Search Pictures",
                    hintStyle: TextStyle(color: Colors.black),
                    icon: Icon(Icons.search,color: Colors.black,),

                  ),
                ),
                ),
              ),
                      
            ],
          ),
        ),
        centerTitle: true,
    ),body: 
            ListView.builder(
              controller: _scrollController,
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index){
                return Container(
                  constraints: BoxConstraints.tightFor(height:150.0),
                  child: Image.network(images[index].link,fit:BoxFit.fitWidth)
                );
              },
            )
        
        );
  }

  fetch() async{
    print("Called fetch");
    final response = await http.get('https://api.unsplash.com/photos/random?client_id=0fc5f9fb1612ae89062b4777ecf0773d33e9e45838c6e86347279a1df7616c65');
    print("Status response:"+response.statusCode.toString());
    if(response.statusCode == 200){
      print("Succesfully received");
      setState((){
        //print("Response is:"+response.body);
        var jsonData= json.decode(response.body);
        models.Pictures pictures = models.Pictures(
          alt_description: jsonData['alt_description'],
          id: jsonData['id'],
          link: jsonData['urls']['small']

        );
        images.add(pictures);
      });
      
    }else{
      throw Exception('Failed to load image');
    }
  }

  fetchFive(){
    print("Called fetch5");
    for(int i=0;i<10;i++){
      fetch();
    }
  }
}