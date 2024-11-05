import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/widgets/download_or_cached_image.dart';
import 'package:widget_zoom/widget_zoom.dart';

class BookImageData {
  final String? documentUrl;
  final String documentTag;
  final double size;

  BookImageData(
      {required this.documentUrl,
        required this.documentTag,
        required this.size});
}

class BookImage extends StatelessWidget {
  const BookImage({super.key});

  @override
  Widget build(BuildContext context) {
    final documentUrl = Provider.of<BookImageData>(context).documentUrl;
    final documentTag = Provider.of<BookImageData>(context).documentTag;
    final size = Provider.of<BookImageData>(context).size;

    return SizedBox(
      height: size,
      width: (21 / 30) * size,
      child: Center(
        child: WidgetZoom(
          heroAnimationTag: documentTag,
          zoomWidget: FutureBuilder<Widget>(
            future: downloadOrCachedImage(documentUrl, documentTag),
            builder: (context, snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.waiting) {
                child = const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: backgroundColor,
                  ),
                );
              } else if (snapshot.hasError) {
                child = Text('Error: ${snapshot.error}');
              } else {
                child = ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: snapshot.data!);
              }
              return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300), child: child);
            },
          ),
        ),
      ),
    );
  }
}
