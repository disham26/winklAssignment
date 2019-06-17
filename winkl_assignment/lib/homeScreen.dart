import 'dart:math';
import 'dart:ui' as prefix0;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'models/models.dart' as models;
import 'helpers/widgets.dart' as widgets;
import 'dart:convert';
import 'onClickScreen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FirstPage extends StatefulWidget {
  _FirstPage createState() => _FirstPage();
}

class _FirstPage extends State<FirstPage> {
  //var _categoryNameController = new TextEditingController();
  bool search = false;
  String queryTerm = "";
  String hintForTextSearch = "Search";
  FocusNode _searchTextFocus = new FocusNode();
  static List<models.Pictures> images = new List();
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
          backgroundColor: Colors.grey,
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
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: TextFormField(
                      controller: _searchController,
                      focusNode: _searchTextFocus,
                      onFieldSubmitted: (text) {
                        setState(() {
                          images.clear();
                          page = 1;
                          search=true;
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
            SizedBox(),
            checkImageLength()
                ? new Expanded(
                    child: new StaggeredGridView.countBuilder(
              crossAxisCount: 3,
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              itemCount: images.length,
              controller: _scrollController,
              itemBuilder: (BuildContext context, int index) => new Container(
                  color: Colors.white,
                  child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ExtractArgumentsScreen.routeName,
                                arguments:
                                    models.ScreenArguments(images[index]),
                              );
                            },
                            child: new widgets.HomeImageCard(images[index]),
                          )
                  ),
              staggeredTileBuilder: (int index) =>
              new StaggeredTile.count(crossAxisCellCountGet(images[index]), mainAxisCellCountGet(images[index]))  ,

              
            ))
                : widgets.NoImageFound(),
          ],
        ));
  }
  crossAxisCellCountGet(models.Pictures images){

    if(images.height==null || images.width==null){
      return 1;
    }
    if((images.height-images.width).abs()<=1000){
        return 2;
    }
    if(images.width>images.height){
      return 2;
    }
    return 1;
  }
  mainAxisCellCountGet(models.Pictures images){
    if(images.height==null || images.width==null){
      return 1;
    }
    if((images.height-images.width).abs()<=1000){
      return 2;
    }
    if(images.height>images.width){
      return 2;
    }
    return 1;
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
    String query = 'https://api.unsplash.com/photos?client_id=641f7742e10311edcb08d2df0ef6cc2600b2868c0d0872bc7e1df277cba259bd&per_page=30&page=' +
        page.toString();
    final response = await http.get(
        query);

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
              link: i['urls']['thumb'],
          linkFull: i['urls']['raw'],
              author_bio: i['user']['bio'],
              author_name: i['user']['name'],
          height: i['height'],
          width: i['width']);
          images.add(pictures);
        });
      });
    } else {
      throw Exception('Failed to load image');
    }
  }

  showMore() {
    showMoreText = true;
  }

  showNoMore() {
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

// class ShowTiles extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     List<Widget> list = new List<Widget>();
//     for(var i = 0; i < _FirstPage.images.length; i+3){
//         list.add(new Text(_FirstPage.images[i].id));
//     }
//     return new Column(children: list);
//   }
// }
