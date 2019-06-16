import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'models/models.dart' as models;

class ExtractArgumentsScreen extends StatelessWidget {
  static const routeName = '/extractArguments';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    final models.ScreenArguments args =
        ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text('Picture by ' +
              (args.picture.author_name == null
                  ? "someone"
                  : args.picture.author_name)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 20.0, bottom: 20.0),
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
                  : SizedBox(),
            ]))
          ]),
        ));
  }
}
