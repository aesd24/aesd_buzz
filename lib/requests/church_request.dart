import 'package:aesd/services/dio_service.dart';

class ChurchRequest extends DioClient {

  final String baseRoute = "churches";

  Future userChurches() async {
    final client = await getApiClient();
    return await client.get('$baseRoute/serviteur_church');
  }

  Future all({required int page}) async {
    final client = await getApiClient();
    return client.get(baseRoute, queryParameters: {"page": page});
  }

  Future one(int id) async {
    final client = await getApiClient();
    return client.get("$baseRoute/$id");
  }

  Future create(Object data) async {
    final client = await getApiClient(contentType: "Multipart/form-data");
    return await client.post(baseRoute, data: data);
  }

  Future update(Object data, {required int churchId}) async {
    final client = await getApiClient(contentType: "Multipart/form-data");
    return await client.post("$baseRoute/$churchId", data: data);
  }

  Future requestMembership({required int churchId}) async {
    // demande d'adhésion à une église (pour les serviteur)
    final client = await getApiClient();
    return await client.post("$baseRoute/$churchId/membership-request");
  }

  Future getMembershipRequests() async {
    // renvoie la liste des demandes d'adhésion
    final client = await getApiClient();
    return await client.get("membership-requests/adhesion");
  }

  Future acceptMembershipRequest(int requestId) async {
    // renvoie la liste des demandes d'adhésion
    final client = await getApiClient();
    return await client.get("membership-requests/$requestId/approuve");
  }

  Future rejectMembershipRequest(int requestId) async {
    // renvoie la liste des demandes d'adhésion
    final client = await getApiClient();
    return await client.get("membership-requests//$requestId/reject");
  }

  Future retryValidation(int churchId, {required Object data}) async {
    // renvoyer l'attention d'existence de l'église
    final client = await getApiClient();
    return await client.post("$baseRoute/$churchId/attestation", data: data);
  }

  Future subscribe(int id, {required bool willSubscribe}) async {
    final client = await getApiClient();
    return client.post("$baseRoute/$id/subscribe", data: {
      'subscriptionInput': willSubscribe ? 1 : 0
    });
  }
}
