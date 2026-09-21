import 'package:growth_companion/app/app.dart';
import 'package:growth_companion/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
