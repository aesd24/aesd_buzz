import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget imageShimmerPlaceholder({
  required double height,
  double width = double.infinity,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.withAlpha(150),
    highlightColor: Colors.white.withAlpha(50),
    enabled: true,
    child: Container(color: Colors.grey, height: height, width: width),
  );
}

class ListShimmerPlaceholder extends StatefulWidget {
  const ListShimmerPlaceholder({super.key});

  @override
  State<ListShimmerPlaceholder> createState() => _ListShimmerPlaceholderState();
}

class _ListShimmerPlaceholderState extends State<ListShimmerPlaceholder> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Shimmer.fromColors(
      baseColor: Colors.grey.withAlpha(150),
      highlightColor: Colors.white.withAlpha(50),
      enabled: true,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(10, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlaceholderBox(height: 300, width: size.width),
                  _buildPlaceholderBox(height: 100, width: size.width * .7),
                  _buildPlaceholderBox(height: 40, width: size.width * .4),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

Widget _buildPlaceholderBox({required double height, required double width}) {
  return Container(
    height: height,
    width: width,
    margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.circular(15)
    ),
  );
}
