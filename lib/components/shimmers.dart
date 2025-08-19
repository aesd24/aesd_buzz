import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget imageShimmerContainer({ required double height, double width = double.infinity }) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.withAlpha(150),
    highlightColor: Colors.white.withAlpha(50),
    enabled: true,
    child: Container(
      color: Colors.grey,
      height: height,
      width: width,
    )
  );
}