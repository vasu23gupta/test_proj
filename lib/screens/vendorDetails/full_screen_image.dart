import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:test_proj/services/database.dart';

class FullScreenImage extends StatefulWidget {
  final List<String> imageIDs;
  final int index;
  FullScreenImage({this.imageIDs, this.index});
  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  List<String> imageIDs;
  int index;

  @override
  void initState() {
    super.initState();
    imageIDs = widget.imageIDs;
    index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            maxScale: PhotoViewComputedScale.contained * 2.0,
            minScale: PhotoViewComputedScale.contained * 0.8,
            imageProvider: VendorDBService.getVendorImage(imageIDs[index]),
            heroAttributes: PhotoViewHeroAttributes(tag: imageIDs[index]),
          );
        },
        enableRotation: true,
        itemCount: imageIDs.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes),
          ),
        ),
        backgroundDecoration:
            BoxDecoration(color: Theme.of(context).canvasColor),
      ),
    );
  }
}
