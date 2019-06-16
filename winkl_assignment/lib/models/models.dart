import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Pictures {
  final String id;
  final String alt_description;
  final String link;
  final String linkFull;
  final String author_name;
  final int height;
  final int width;
  final String author_bio;
  Pictures(
      {this.alt_description,
      this.id,
      this.link,
      this.author_bio,
      this.author_name,
      this.linkFull,
      this.height,
      this.width});
}

final String noImageFound = "No images found";
final String moreImagesLoading = "More Images Loading";
final String endOfList = "Thats all";

class ScreenArguments {
  final Pictures picture;

  ScreenArguments(this.picture);
}

isNull(String input) {
  if (input.length == 0) {
    return true;
  }
  return false;
}