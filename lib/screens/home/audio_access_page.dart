import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mp3player/helpers/constants.dart';
import 'package:mp3player/screens/home/home_page_controller.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: SvgPicture.asset(
              "assets/bg_images/search_bg.svg",
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.9,
            ),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Please Be Patient !", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text(
                  "This won't take much time",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(scanPageLoaderProvider);
                return isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, AppID.HOME, (route) => false);
                        },
                        child: const Text("Shall We ?"),
                      );
              },
            ),
          )
        ],
      ),
    );
  }
}
