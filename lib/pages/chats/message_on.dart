import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MessageOnPage extends StatefulWidget {
  const MessageOnPage({super.key});

  @override
  State<MessageOnPage> createState() => _MessageOnPageState();
}

class _MessageOnPageState extends State<MessageOnPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary.withAlpha(170),
        leadingWidth: 85,
        toolbarHeight: 80,
        centerTitle: true,
        actions: [
          PopupMenuButton(
            iconColor: colorScheme.onPrimary,
            itemBuilder: (context) => [
              PopupMenuItem(child: Text("Action 1")),
              PopupMenuItem(child: Text("Action 2")),
              PopupMenuItem(child: Text("Action 3")),
            ]
          )
        ],
        leading: Padding(
          padding: EdgeInsets.only(left: 13),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  color: colorScheme.onPrimary,
                  size: 20
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          "Nom du groupe de chat",
          style: textTheme.titleSmall!.copyWith(
            color: Colors.white
          )
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(3, (i) => buildMessagebull(
                    size,
                    colorScheme,
                    textTheme,
                    senderName: "Jean-yves Albert",
                    message: "Contenu d'un message",
                    time: TimeOfDay(hour: 10 + i, minute: (i + 1) * 10),
                    isMine: i == 1,
                  )),
                )
              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 7),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Saisissez votre message...",
                  hintStyle: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurface.withAlpha(100)
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: FaIcon(
                      FontAwesomeIcons.circlePlus,
                      color: colorScheme.onSurface.withAlpha(150)
                    )
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: FaIcon(
                      FontAwesomeIcons.solidPaperPlane,
                      size: 20,
                      color: colorScheme.primary
                    )
                  )
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  Align buildMessagebull(
    Size size,
    ColorScheme colorScheme,
    TextTheme textTheme,
    {
      required String senderName,
      required String message,
      required TimeOfDay time,
      bool isMine = false,
    }
  ) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMine) Padding(
              padding: EdgeInsets.only(right: 5),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage('https://picsum.photos/300/300'),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 100,
                maxWidth: size.width * .7
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isMine ? colorScheme.primaryContainer : colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: isMine ? Radius.zero : Radius.circular(15),
                    bottomLeft: !isMine ? Radius.zero : Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(!isMine) Text(
                      senderName,
                      style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(150),
                        fontSize: 10
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      child: Text(
                        message,
                        style: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSecondaryContainer
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${time.hour}:${time.minute}",
                          style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(150),
                            fontSize: 10
                          ),
                        ),
                        SizedBox(width: 3),
                        FaIcon(
                          FontAwesomeIcons.clock,
                          size: 10,
                          color: colorScheme.onSurface.withAlpha(150),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            if (isMine) Padding(
              padding: EdgeInsets.only(left: 5),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage('https://picsum.photos/300/300'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
