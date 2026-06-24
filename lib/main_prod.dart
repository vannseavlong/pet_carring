import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/app_config.dart';
import 'main.dart' as runner;

Future<void> main() async {
  await dotenv.load(fileName: '.env.prod');
  AppConfig.setup(AppConfig.prod());
  runner.bootstrap();
}
