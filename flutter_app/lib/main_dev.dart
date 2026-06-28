import 'app.dart';
import 'bootstrap.dart';
import 'core/di/injection.dart';

void main() {
  bootstrap(
    () => const App(),
    environment: Environment.dev,
  );
}
