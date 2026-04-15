import 'package:flutter/material.dart';
import 'package:votera_app/app.dart';
import 'package:votera_app/core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const VoteraApp());
}
