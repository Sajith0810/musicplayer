import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mp3player/helpers/constants.dart';
import 'package:mp3player/helpers/db_helper.dart';
import 'package:mp3player/screens/home/home_page.dart';
import 'package:mp3player/screens/index/index_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper().initDB();
  runApp(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: const MainPage(),
        routes: {
          AppID.HOME: (context) => const HomePage(),
        },
      ),
    ),
  );
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    getPrefValue();
    super.initState();
  }

  getPrefValue() async {
    final pref = await SharedPreferences.getInstance();
    ref.read(homePageChangerProvider.notifier).state = pref.getBool("hasAccount") == null ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final hasAccount = ref.watch(homePageChangerProvider);
        return hasAccount ? const HomePage() : const IndexPage();
      },
    );
  }
}
