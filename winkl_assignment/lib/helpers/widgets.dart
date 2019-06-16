import 'package:flutter/material.dart';
import '../models/models.dart' as models;

class MoreImagesLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: Padding(
            padding: EdgeInsets.only(top: 20), child: Text(models.moreImagesLoading)));
  }
}

class EndOfList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child:
            Padding(padding: EdgeInsets.only(top: 20), child: Text(models.endOfList)));
  }
}

class NoImageFound extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: Padding(
            padding: EdgeInsets.only(top: 20), child: Text(models.noImageFound)));
  }
}

class HomeImageCard extends StatelessWidget {
  HomeImageCard(this.link);
  final models.Pictures link;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: link.height.ceilToDouble(),
      width: link.width.ceilToDouble(),
      
      child: Card(   
      child: Image.network(
        link.link,
        fit: BoxFit.cover,
      ),
    )
    );
  }
}