import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3player/helpers/app_methods.dart';
import 'package:mp3player/screens/home/home_page_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/song_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await ref.read(homePageControllerProvider).getDBSongs();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music"),
        surfaceTintColor: Colors.white,
      ),
      drawer: Container(
        margin: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
        decoration: const BoxDecoration(color: Colors.white),
        child: const Column(
          children: [
            DrawerHeader(
              child: Text("Header"),
            ),
          ],
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          List<SongsModel> songList = ref.watch(mp3SongListProvider);
          if (songList.isNotEmpty) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: songList.length,
                    itemBuilder: (context, index) {
                      SongsModel song = songList[index];
                      return InkWell(
                        onTap: () {},
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          horizontalTitleGap: 1,
                          leading: Container(
                            height: 100,
                            width: 100,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: MemoryImage(
                                  AppMethods().imageConversion(song.albumArt!),
                                ),
                              ),
                            ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              song.trackName ?? "-",
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: const Padding(
                            padding: EdgeInsets.only(right: 13),
                            child: Icon(Icons.more_vert_rounded),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(song.albumArtistName ?? "-",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!, // Light gray for shimmer effect
                              highlightColor: Colors.grey[100]!, // Lighter gray for highlight
                              child: Container(
                                width: 70.0,
                                height: 70.0,
                                decoration: BoxDecoration(
                                  color: Colors.white, // Color for actual image (hidden initially)
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20.0), // Spacing between image and text
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 16.0,
                                      width: AppMethods().getWidth(context), // Height for one line of text
                                      decoration:
                                          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), // Hidden color for actual text
                                      child: const Text(
                                        '',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4.0), // Spacing between text lines
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 16.0,
                                      width: AppMethods().getWidth(context),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                      child: const Text(
                                        '',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4.0), // Spacing between text lines
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 16.0,
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                      child: const Text(
                                        '',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );

                      // return ListTile(
                      //     leading: Shimmer.fromColors(
                      //       baseColor: Colors.grey,
                      //       highlightColor: Colors.purple,
                      //       child: Container(
                      //         margin: EdgeInsets.only(bottom: 5),
                      //         height: 100,
                      //         width: 100,
                      //         color: Colors.grey,
                      //       ),
                      //     ),
                      //     title: Column(
                      //       children: [
                      //         Shimmer.fromColors(
                      //           baseColor: Colors.grey,
                      //           highlightColor: Colors.purple,
                      //           child: Container(
                      //             width: 200,
                      //             height: 20,
                      //             color: Colors.grey,
                      //           ),
                      //         ),
                      //         Shimmer.fromColors(
                      //           baseColor: Colors.grey,
                      //           highlightColor: Colors.purple,
                      //           child: Container(
                      //             width: 200,
                      //             height: 20,
                      //             color: Colors.grey,
                      //           ),
                      //         ),
                      //       ],
                      //     ));
                    },
                  ),
                ),
              ],
            );
            // return Shimmer.fromColors(
            //   baseColor: Colors.white,
            //   enabled: true,
            //   direction: ShimmerDirection.ltr,
            //   highlightColor: Colors.grey,
            //   child: Container(
            //     height: 50,
            //     width: 200,
            //   ),
            //   // child: ListTile(
            //   //   leading: const SizedBox(
            //   //     height: 100,
            //   //     width: 100,
            //   //   ),
            //   //   title: SizedBox(
            //   //     height: 15,
            //   //     width: AppMethods().getWidth(context),
            //   //   ),
            //   //   subtitle: SizedBox(
            //   //     height: 15,
            //   //     width: AppMethods().getWidth(context),
            //   //   ),
            //   // ),
            // );
          }
        },
      ),
    );
  }
}
