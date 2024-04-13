import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mp3player/helpers/constants.dart';
import 'package:mp3player/screens/index/index_page_controller.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_page_controller.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(
      initialPage: 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Consumer(builder: (context, ref, child) {
              return PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (int changedIndex) {
                  ref.read(pageChangerProvider.notifier).state = changedIndex;
                },
                scrollDirection: Axis.horizontal,
                children: [
                  SvgPicture.asset(
                    "assets/bg_images/music_bg.svg",
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.9,
                  ),
                  Consumer(builder: (context, ref, child) {
                    return ref.watch(scanPageLoaderProvider)
                        ? SvgPicture.asset(
                            "assets/bg_images/search_bg.svg",
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width * 0.9,
                          )
                        : SvgPicture.asset(
                            "assets/bg_images/permission_bg.svg",
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width * 0.9,
                          );
                  })
                ],
              );
            }),
          ),
          Expanded(
            flex: 2,
            child: Consumer(
              builder: (context, ref, child) {
                final index = ref.watch(pageChangerProvider);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    PageViewDotIndicator(
                      currentItem: index,
                      count: 2,
                      unselectedColor: Colors.black26,
                      selectedColor: Colors.deepPurpleAccent,
                      size: const Size(20, 8),
                      unselectedSize: const Size(8, 8),
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      fadeEdges: false,
                      boxShape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5), //only for rectangle shape
                    ),
                    Column(
                      children: [
                        Text(
                          ref.watch(scanPageLoaderProvider)
                              ? "Please Be Patient !"
                              : index == 0
                                  ? "Let's Enjoy the way"
                                  : index == 1
                                      ? "I need your Permission to engage !"
                                      : "",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        Text(
                          ref.watch(scanPageLoaderProvider)
                              ? "This won't take much time"
                              : index == 0
                                  ? "Shall we move to the music world ?"
                                  : index == 1
                                      ? "Can i take it ?"
                                      : "",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    Consumer(builder: (context, ref, child) {
                      final indexPage = ref.watch(indexPageProvider);
                      final isLoading = ref.watch(scanPageLoaderProvider);
                      return isLoading
                          ? CircularProgressIndicator()
                          : FilledButton(
                              onPressed: () async {
                                int page = _pageController.page!.toInt();
                                if (page != 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.linear,
                                  );
                                } else {
                                  await indexPage.checkPermission(context);
                                  Navigator.pushNamedAndRemoveUntil(context, AppID.HOME, (route) => false);
                                  final pref = await SharedPreferences.getInstance();
                                  await pref.setBool("hasAccount", true);
                                }
                              },
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 30,
                              ),
                            );
                    })
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
