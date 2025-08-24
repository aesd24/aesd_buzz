import 'package:aesd/components/placeholders.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: Hero(
        tag: imageUrl,
        child: PhotoView(
          imageProvider: FastCachedImageProvider(imageUrl),
          loadingBuilder:
              (context, event) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imageShimmerPlaceholder(height: 400),
                ),
              ),
          backgroundDecoration: BoxDecoration(
            color: Colors.black.withAlpha(100),
          ),
        ),
      ),
    );
  }
}
