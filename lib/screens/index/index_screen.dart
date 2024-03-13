import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mp3player/helpers/constants.dart';
import 'package:mp3player/screens/index/index_page_controller.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final PageController _pageController = PageController(
    initialPage: 0,
  );

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
                physics: const BouncingScrollPhysics(),
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
                  SvgPicture.asset(
                    "assets/bg_images/permission_bg.svg",
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.9,
                  )
                ],
              );
            }),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final index = ref.watch(pageChangerProvider);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        return PageViewDotIndicator(
                          currentItem: ref.watch(pageChangerProvider),
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
                          //defaults to circle
                          borderRadius: BorderRadius.circular(5), //only for rectangle shape
                        );
                      },
                    ),
                    Column(
                      children: [
                        Text(
                          index == 0 ? "Let's Enjoy the way" : "I need your Permission to engage !",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        Text(
                          index == 0 ? "Shall we move to the music world ?" : "Can i take it ?",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    Consumer(builder: (context, ref, child) {
                      final indexPage = ref.watch(indexPageProvider);
                      return ElevatedButton(
                        onPressed: () async {
                          int page = _pageController.page!.toInt();
                          if (page != 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear,
                            );
                          } else {
                            final pref = await SharedPreferences.getInstance();
                            final value = await indexPage.checkPermission(context);
                            pref.setBool("hasAccount", true);
                            Navigator.pushNamedAndRemoveUntil(context, AppID.ACCESS, (route) => false);
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
