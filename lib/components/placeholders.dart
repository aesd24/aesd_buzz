import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget imageShimmerPlaceholder({
  required double height,
  double width = double.infinity,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.withAlpha(150),
    highlightColor: notifire.getbgcolor.withAlpha(50),
    enabled: true,
    child: _buildPlaceholderBox(height: height, width: width),
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
    return Padding(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(10, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlaceholderBox(height: 170, width: size.width),
                  _buildPlaceholderBox(height: 30, width: size.width * .6),
                  _buildPlaceholderBox(height: 15, width: size.width * .25),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class CommentsPlaceholder extends StatefulWidget {
  const CommentsPlaceholder({super.key});

  @override
  State<CommentsPlaceholder> createState() => _CommentsPlaceholderState();
}

class _CommentsPlaceholderState extends State<CommentsPlaceholder> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(10, (index) {
            return _buildPlaceholderBox(height: 30, width: double.infinity);
          }),
        ),
      ),
    );
  }
}

Widget _buildPlaceholderBox({required double height, required double width}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.withAlpha(100),
    highlightColor: Colors.grey.withAlpha(40),
    enabled: true,
    child: Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  );
}
