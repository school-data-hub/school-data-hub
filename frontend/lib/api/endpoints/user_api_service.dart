import 'package:schuldaten_hub/api/dio/dio_client.dart';

import 'package:schuldaten_hub/common/services/locator.dart';

class EndpointsUser {
  static const login = '/users/login';
  //- GET
  static const getAllUsers = '/users/all';
  static const getSelfUser = '/users/me';

  //- POST
  static const createUser = '/users/new';

  //- PATCH
  String patchUser(String publicId) {
    return 'users/$publicId';
  }

  //- DELETE
  String deleteUser(String publicId) {
    return 'users/$publicId';
  }

  //- increase credit
  static const increaseCredit = '/users/all/credit';
}
