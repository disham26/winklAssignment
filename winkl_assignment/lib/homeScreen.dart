import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'models/models.dart' as models;
import 'helpers/widgets.dart' as widgets;
import 'dart:convert';
import 'onClickScreen.dart';

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
  bool showMoreText = false;
  bool showBottom = true;

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
            checkImageLength()
                ? new Expanded(
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
                                arguments:
                                    models.ScreenArguments(images[index]),
                              );
                            },
                            child:
                                new widgets.HomeImageCard(images[index].link),
                          );
                        },
                        controller: _scrollController,
                        itemCount: images.length))
                : widgets.NoImageFound(),
            showBottom
                ? showMoreText
                    ? widgets.MoreImagesLoading()
                    : widgets.EndOfList()
                : SizedBox()
          ],
        ));
  }

  bool checkImageLength() {
    if (images.length != 0) {
      setState(() {
        showMoreText = true;
        showBottom = true;
      });
      return true;
    } else {
      setState(() {
        showBottom = false;
      });
      return false;
    }
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
        if (jsonData.length < 30) {
          showNoMore();
        } else {
          showMore();
        }
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
    print("total size of images is:" + images.length.toString());
  }

  showMore() {
    print("showMore called");
    showMoreText = true;
  }

  showNoMore() {
    print("Show no more called");
    showMoreText = false;
  }

  void onChange() {
    if (_searchController.text.length > 0) {
      setState(() {
        showCancel = true;
      });
    } else {
      setState(() {
        showCancel = false;
      });
    }
  }
}
