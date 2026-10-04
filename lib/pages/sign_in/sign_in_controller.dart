import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../../domain/contracts/repositories.dart';
import '../../models/entities/user_token.dart';

class SignInController extends ChangeNotifier {
  final AuthRepository authRepository;

  bool isLoading = false;
  String? errorMessage;

  SignInController({required this.authRepository});

  Future<Result<UserToken>> authenticate(
      String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await authRepository.signIn(
      username: username,
      password: password,
    );

    isLoading = false;

    if (result.isFailure) {
      errorMessage = result.error?.message;
    }

    notifyListeners();
    return result;
  }
}
