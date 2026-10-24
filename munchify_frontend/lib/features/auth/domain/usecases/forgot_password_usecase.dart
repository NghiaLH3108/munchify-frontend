import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, String>> call(String email) async {
    return await repository.forgotPassword(email);
  }
}
