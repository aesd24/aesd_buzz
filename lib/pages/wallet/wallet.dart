import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/tiles.dart';
import 'package:aesd/pages/wallet/send.dart';
import 'package:aesd/pages/wallet/transactions.dart';
import 'package:aesd/pages/wallet/withdrawing.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  bool _password = true;
  @override
  Widget build(BuildContext context) {
    var themeColors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: cusFaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white),
        ),
        title: Text(
          "Solde",
          style: mainTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height / 2.8,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.green),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 15,
                      right: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _password ? "8.786" : "********",
                              style: GoogleFonts.orbitron(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 40),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _password = !_password;
                                });
                              },
                              icon: FaIcon(
                                _password
                                    ? FontAwesomeIcons.solidEye
                                    : FontAwesomeIcons.solidEyeSlash,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "XOF",
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // boutons de transactions
                Positioned(
                  bottom: 30,
                  left: 35,
                  right: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customTransactionButton(
                        title: "Envoyer",
                        icon: cusFaIcon(
                          FontAwesomeIcons.shareFromSquare,
                          color: Colors.white,
                        ),
                        backColor: themeColors.primary,
                        onTap: () => Get.to(SendPage()),
                      ),
                      customTransactionButton(
                        title: "Retirer",
                        icon: cusFaIcon(
                          FontAwesomeIcons.download,
                          color: Colors.white,
                        ),
                        backColor: themeColors.primary,
                        onTap: () => Get.to(WithDrawingPage()),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // liste des transactions
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Transactions",
                        style:
                            Theme.of(context).textTheme.labelLarge!.copyWith(),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Get.to(TransactionsPage()),
                        child: Text(
                          "Tout voir",
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(color: themeColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: List.generate(5, (index) {
                      return customTransactionTile(
                        context,
                        label: "Transaction $index",
                        amount: (index + 1) * 1000,
                        date: DateTime(index + 2000, index, index),
                      );
                    }),
                  ),
                  SizedBox(height: 23),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customTransactionButton({
    required String title,
    required Widget icon,
    required Color backColor,
    void Function()? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: backColor,
            ),
            child: Center(child: icon),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
