import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

class CustomFileLoader extends StatefulWidget {
  const CustomFileLoader({super.key, required this.isLoading, required this.child});
  
  final bool isLoading;
  final Widget child;

  @override
  State<CustomFileLoader> createState() => _CustomFileLoaderState();
}

class _CustomFileLoaderState extends State<CustomFileLoader> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: widget.isLoading,
      progressIndicator: customProgressIndicator(),
      child: widget.child
    );
  }

  Widget customProgressIndicator() {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 25),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: notifire.getbgcolor,
            borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Chargement en cours ...",
                style: textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: notifire.getMainText
                ),
              ),
            ),
            Text(
              "L'opération peut prendre quelques minutes. Veuillez patienter",
              style: textTheme.bodySmall!.copyWith(
                color: notifire.getMainText
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
