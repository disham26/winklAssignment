import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/models.dart' as models;
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ExtractArgumentsScreen.routeName: (context) => ExtractArgumentsScreen(),
      },
      title: "WinklDemo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  _FirstPage createState() => _FirstPage();
}

class _FirstPage extends State<FirstPage> {
  //var _categoryNameController = new TextEditingController();
  bool search = false;
  String queryTerm = "";
  String hintForTextSearch = "Search";
  FocusNode _searchTextFocus = new FocusNode();
  List<models.Pictures> images = new List();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _searchController = TextEditingController();
  bool showLoading = false;
  bool showCancel = false;
  bool hasContent = false;
  var page = 1;

  @override
  void initState() {
    super.initState();
    fetch();
    _searchController.addListener(onChange);
    _searchTextFocus.addListener(onChange);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!search) {
          fetch();
        } else {
          fetchSearch(queryTerm);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.black));
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(50, 255, 255, 255),
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                showLoading
                    ? IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            images.clear();
                            page = 1;
                            search = false;
                            fetch();
                            showLoading = false;
                          });
                        },
                      )
                    : SizedBox(),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: TextFormField(
                      controller: _searchController,
                      focusNode: _searchTextFocus,
                      onFieldSubmitted: (text) {
                        setState(() {
                          images.clear();
                          page = 1;
                          fetchSearch(text);
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hintForTextSearch,
                        hintStyle: TextStyle(color: Colors.black),
                        icon: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                showCancel
                    ? IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : SizedBox(),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: new Column(
          children: <Widget>[
            new Expanded(
                child: new GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 3.0,
                        mainAxisSpacing: 3.0),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            ExtractArgumentsScreen.routeName,
                            arguments: ScreenArguments(images[index]),
                          );
                        },
                        child: Card(
                          child: Image.network(
                            images[index].link,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    controller: _scrollController,
                    itemCount: images.length)),
          ],
        ));
  }

  void onChange() {
    String text = _searchController.text;
    if (_searchController.text.length > 0) {
      setState(() {
        showCancel = true;
      });
    } else {
      setState(() {
        showCancel = false;
      });
    }
    bool hasFocus = _searchTextFocus.hasFocus;
    //do your text transforming

    // _searchController.text = newText;
    // _searchController.selection = new TextSelection(
    //                               baseOffset: newText.length,
    //                               extentOffset: newText.length
    //                         );
  }

  fetch() async {
    final response = await http.get(
        'https://api.unsplash.com/photos?client_id=641f7742e10311edcb08d2df0ef6cc2600b2868c0d0872bc7e1df277cba259bd&per_page=30&page=' +
            page.toString());
    if (response.statusCode == 200) {
      hasContent = false;
      setState(() {
        page++;
        List jsonData = json.decode(response.body);
        jsonData.forEach((i) {
          hasContent = true;
          models.Pictures pictures = models.Pictures(
              alt_description: i['alt_description'],
              id: i['id'],
              link: i['urls']['thumb'],
              author_bio: i['user']['bio'],
              author_name: i['user']['name'],
              linkFull: i['urls']['raw'],
              height: i['height'],
              width: i['width']);
          images.add(pictures);
        });
      });
    } else {
      throw Exception('Failed to load image');
    }
  }

  fetchSearch(String text) async {
    queryTerm = text;
    String query =
        'https://api.unsplash.com/search/photos?client_id=641f7742e10311edcb08d2df0ef6cc2600b2868c0d0872bc7e1df277cba259bd&per_page=30&page=' +
            page.toString() +
            '&query=' +
            text;
    final response = await http.get(query);
    if (response.statusCode == 200) {
      setState(() {
        showLoading = true;
        page++;
        List jsonData = json.decode(response.body)['results'];
        jsonData.forEach((i) {
          models.Pictures pictures = models.Pictures(
              alt_description: i['alt_description'],
              id: i['id'],
              link: i['urls']['thumb']);
          images.add(pictures);
        });
      });
    } else {
      throw Exception('Failed to load image');
    }
  }
}

class ExtractArgumentsScreen extends StatelessWidget {
  static const routeName = '/extractArguments';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text('Picture by ' +
              (args.picture.author_name == null
                  ? "someone"
                  : args.picture.author_name)),
        ),
        body: 

        SingleChildScrollView(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0,top:20.0,bottom:20.0),
                scrollDirection: Axis.vertical,
              child: Flex(direction: Axis.horizontal, children: <Widget>[
                Expanded(
                    child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: args.picture.linkFull == null
                        ? CachedNetworkImage(
                            imageUrl: args.picture.link,
                            placeholder: (context, url) =>
                                new CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                          )
                        : CachedNetworkImage(
                            imageUrl: args.picture.linkFull,
                            placeholder: (context, url) =>
                                new CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                          ),
                  ),
                  args.picture.alt_description == null
                      ? SizedBox()
                      : Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: RichText(
                              text: new TextSpan(
                            children: <TextSpan>[
                              new TextSpan(
                                  text: "Description:",
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              new TextSpan(
                                  text: args.picture.alt_description,
                                  style: new TextStyle(color: Colors.black))
                            ],
                          )),
                        ),
                      ),
                  args.picture.author_bio != null
                      ? Align(
                        
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: new RichText(
                              text: new TextSpan(children: <TextSpan>[
                            new TextSpan(
                                text: "Something about the author: ",
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            new TextSpan(
                                text: args.picture.author_bio == null
                                    ? "The author has not updated the bio yet"
                                    : args.picture.author_bio,
                                style: new TextStyle(color: Colors.black))
                          ]))))
                      : SizedBox()
                    ]
                      )
                )
                
              ]
              ),
)
            );
  }
}

class ScreenArguments {
  final models.Pictures picture;

  ScreenArguments(this.picture);
}

isNull(String input) {
  if (input.length == 0) {
    return true;
  }
  return false;
}
