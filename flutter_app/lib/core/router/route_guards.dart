import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import 'app_router.dart';

@injectable
class AuthGuard extends AutoRouteGuard {
  final AuthRepository _authRepository;

  AuthGuard(this._authRepository);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = _authRepository.currentUser;

    if (user != null) {
      resolver.next();
    } else {
      router.push(const LoginRoute());
    }
  }
}
