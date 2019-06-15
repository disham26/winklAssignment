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
  //var _categoryNameController = new TextEditingController();
  bool search=false;
  String queryTerm="";
  String hintForTextSearch="Search";
  FocusNode _searchTextFocus = new FocusNode();
  List<models.Pictures> images = new List();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _searchController = TextEditingController();
  bool showLoading=false;
  var page=1;

  @override
  void initState(){
    super.initState();
    fetch();
    _searchController.addListener(onChange); 
    _searchTextFocus.addListener(onChange);
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        if(!search){
          fetch();
          }else{
            fetchSearch(queryTerm);
          }
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
        backgroundColor: Colors.teal,
        title: Container(
          margin: EdgeInsets.symmetric(horizontal: 15.0,vertical: 8.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(50, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                showLoading
                ?
                IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: (){
                  setState(() {
                    _searchController.clear();
                    images.clear();
                    page=1;
                    search=false;
                    fetch();
                    showLoading=false;
                  });
                },
                ): 
                Text('' ),
              
              Expanded(
                flex: 1,
                child: Container(
                  padding:EdgeInsets.symmetric(horizontal: 5.0),
                  child:TextFormField(
                    
                    controller: _searchController,
                    focusNode: _searchTextFocus,
                    onFieldSubmitted: (text){
                      setState(() {
                        images.clear();
                        page=1;
                        fetchSearch(text);
                      });
                      
                    },
                    decoration: InputDecoration(
                    border: InputBorder.none,       
                    hintText: hintForTextSearch,
                    hintStyle: TextStyle(color: Colors.black),
                    icon: Icon(Icons.search,color: Colors.black,),
                  ),
                ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.cancel),
                onPressed: (){
                  setState(() {
                    _searchController.clear();
                  });
                },
                ),
              
              // SizedBox(height: 32),
              // Divider(),    
              // SizedBox(height: 32),
            ],
          ),
        ),
        centerTitle: true,
    ),body: 
            ListView.builder(
              
              controller: _scrollController,
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index){
                return Card(
                  elevation: 2,
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Image.network(images[index].link,fit:BoxFit.scaleDown),
                        Spacer(flex: 2,),
                        Image.network(images[index].link,fit:BoxFit.fitHeight),
                       
                        ],
                    ),
                  )
                  
                );
              },
            )
        
        );
  }
void onChange(){
  print("Onchange called-------------");
  String text = _searchController.text;
  bool hasFocus = _searchTextFocus.hasFocus;
  //do your text transforming
  String newText = "Search Anything";
  _searchController.text = newText;
  _searchController.selection = new TextSelection(
                                baseOffset: newText.length, 
                                extentOffset: newText.length
                          );
}
  fetch() async{
    final response = await http.get('https://api.unsplash.com/photos?client_id=641f7742e10311edcb08d2df0ef6cc2600b2868c0d0872bc7e1df277cba259bd&per_page=30&page='+page.toString());
    print("Status response:"+response.statusCode.toString());
    if(response.statusCode == 200){
      setState((){
        page++;
        List jsonData = json.decode(response.body);
        jsonData.forEach((i){
            models.Pictures pictures = models.Pictures(
              alt_description: i['alt_description'],
              id: i['id'],
              link: i['urls']['thumb']
            );
            images.add(pictures);
          });
        });
    }
    else{
      throw Exception('Failed to load image');
    }
  }


  fetchSearch(String text) async{
    queryTerm=text;
    String query = 'https://api.unsplash.com/search/photos?client_id=641f7742e10311edcb08d2df0ef6cc2600b2868c0d0872bc7e1df277cba259bd&per_page=30&page='+page.toString()+'&query='+text;
    print(query);
    final response = await http.get(query);
    print("Status response:"+response.statusCode.toString());
    if(response.statusCode == 200){
      setState((){
        showLoading=true;
        page++;
        List jsonData = json.decode(response.body)['results'];
        jsonData.forEach((i){
            models.Pictures pictures = models.Pictures(
              alt_description: i['alt_description'],
              id: i['id'],
              link: i['urls']['thumb']
            );
            images.add(pictures);
          });
        });
    }
    else{
      throw Exception('Failed to load image');
    }
  }
}
