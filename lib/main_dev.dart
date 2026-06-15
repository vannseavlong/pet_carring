import 'core/config/app_config.dart';
import 'main.dart' as runner;

void main() {
  AppConfig.setup(AppConfig.dev());
  runner.bootstrap();
}
