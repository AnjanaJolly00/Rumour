import 'package:get/get.dart';
import 'package:rumour/screens/chat_screen.dart';
import 'package:rumour/screens/home_screen.dart';
import 'package:rumour/screens/id_screen.dart';

abstract class AppRoutes {
  static const home = '/';
  static const identity = '/identity';
  static const chat = '/chat';
}

abstract class AppPages {
  static final pages = [
    GetPage(name: '/', page: () => const HomeScreen()),
    GetPage(name: '/identity', page: () => const IdScreen()),
    GetPage(name: '/chat', page: () => const ChatScreen()),
  ];
}
