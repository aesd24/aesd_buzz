import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/models/membership_request.dart';
import 'package:aesd/provider/church.dart';
import 'package:aesd/services/message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MembershipRequestsList extends StatefulWidget {
  const MembershipRequestsList({super.key});

  @override
  State<MembershipRequestsList> createState() => _MembershipRequestsListState();
}

class _MembershipRequestsListState extends State<MembershipRequestsList> {
  bool _isLoading = false;
  List<MembershipRequestModel> requests = [];

  Future init() async {
    print('🔍 [MEMBERSHIP] Chargement des demandes d\'adhésion...');
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Church>(
        context,
        listen: false,
      ).getMembershipRequests().then((value) {
        print('🔍 [MEMBERSHIP] Réponse reçue: $value');
        if (value != null) {
          print('🔍 [MEMBERSHIP] Nombre de demandes: ${value.length}');
          setState(() => requests = value);
        } else {
          print('❌ [MEMBERSHIP] Réponse null');
        }
      });
    } catch (e) {
      print('❌ [MEMBERSHIP] Erreur: $e');
      e.printError();
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('🔍 [MEMBERSHIP] Fin du chargement. Total demandes: ${requests.length}');
    }
  }

  Future onValidate(MembershipRequestModel request) async {
    try {
      setState(() => request.isLoading = true);
      await Provider.of<Church>(
        context,
        listen: false,
      ).acceptMembershipRequest(request.id).then((value) {
        if (value) {
          setState(() {
            request.state = 'accepted';
            request.isLoading = false;
          });
        }
      });
    } catch (e) {
      print('❌ [MEMBERSHIP] Erreur UI: $e');
      // Afficher l'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          backgroundColor: Colors.red,
        ),
      );
      e.printError();
    } finally {
      setState(() => request.isLoading = false);
    }
  }

  Future onReject(MembershipRequestModel request) async {
    try {
      setState(() => request.isLoading = true);
      await Provider.of<Church>(
        context,
        listen: false,
      ).rejectMembershipRequest(request.id).then((value) {
        if (value) {
          setState(() {
            request.state = 'rejected';
            request.isLoading = false;
          });
        }
      });
    } catch (e) {
      e.printError();
    } finally {
      setState(() => request.isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: notifire.getbgcolor,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: CloseButton(),
          title: Text(
            "Demandes d'adhésion",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child:
              _isLoading
                  ? CommentsPlaceholder()
                  : requests.isEmpty
                  ? Center(
                    child: notFoundTile(
                      text: "Aucune demande d'adhésion actuellement !",
                    ),
                  )
                  : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return requests[index].buildWidget(
                        context,
                        onValidate: (r) async => await onValidate(r),
                        onReject: (r) async => await onReject(r),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
