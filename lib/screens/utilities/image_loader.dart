import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageLoader extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const ImageLoader({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('Loading image from URL: $imageUrl');

    if (imageUrl.startsWith('http')) {
      // Network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            loadingWidget ??
            const Center(
              child: CircularProgressIndicator(),
            ),
        errorWidget: (context, url, error) {
          debugPrint('Error loading image: $error');
          return errorWidget ??
              const Center(
                child: Icon(Icons.error),
              );
        },
      );
    } else {
      // Asset image
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading asset image: $error');
          return errorWidget ??
              const Center(
                child: Icon(Icons.error),
              );
        },
      );
    }
  }
}
// lol
