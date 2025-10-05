import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';

class SocialElementsList extends StatefulWidget {
  const SocialElementsList({super.key, this.loadElements});

  final Future<dynamic> Function()? loadElements;

  @override
  State<SocialElementsList> createState() => _SocialElementsListState();
}

class _SocialElementsListState extends State<SocialElementsList> {
  bool _isLoading = false;
  List elements = [];

  Future<void> init() async {
    if (widget.loadElements != null) {
      try {
        setState(() => _isLoading = true);
        await widget.loadElements!().then((value) {
          setState(() => elements = value);
        });
      } catch (e) {
        MessageService.showErrorMessage("Oups quelque chose s'est mal passé");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: SafeArea(child: ListShimmerPlaceholder()));
    }
    return Scaffold(
      appBar: AppBar(leading: customBackButton()),
      body:
          elements.isEmpty
              ? notFoundTile(text: "Aucun élément trouvé !")
              : ListView.builder(
                itemCount: elements.length,
                itemBuilder: (context, index) {
                  final element = elements[index];
                  return element.buildWidget(context);
                },
              ),
    );
  }
}
