import 'package:driplix/data/service/index.dart';

// class ClientUserPictureService extends FloweyService {
//   ClientUserPictureService({required String token, required String refreshToken}) : super(token: token, refreshToken: refreshToken);

//   Future<List<ClientUserPicture>> getClientUserPicture() async {
//     final response = await dio.get('/client-user-picture');
//     return response.data.map((e) => ClientUserPicture.fromJson(e)).toList();
//   }
// }