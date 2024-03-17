import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3player/helpers/app_methods.dart';
import 'package:mp3player/helpers/constants.dart';
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
    AudioPlayerController audioPlayerController = ref.watch(audioPlayerControllerProvider);
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
                    addAutomaticKeepAlives: true,
                    physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal),
                    itemBuilder: (context, index) {
                      if (songList.isNotEmpty) {
                        SongsModel song = songList[index];
                        return InkWell(
                          onTap: () {
                            ref.read(selectedSongIndexProvider.notifier).state = index;
                            ref.read(selectedSongProvider.notifier).state = song;
                            songPage(audioPlayer: audioPlayerController);
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            horizontalTitleGap: 1,
                            leading: Image.memory(
                              AppMethods().imageConversion(song.albumArt!),
                              width: 100,
                              height: 100,
                              filterQuality: FilterQuality.low,
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
                      } else {
                        return const Center(
                          child: Text("Song is empty"),
                        );
                      }
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
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  songPage({required AudioPlayerController audioPlayer}) {
    return showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final songData = ref.watch(selectedSongProvider);
            audioPlayer.playSong(songPath: songData!.file.path);
            return Container(
              height: AppMethods().getHeight(context),
              width: AppMethods().getWidth(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: MemoryImage(
                          AppMethods().imageConversion(songData?.albumArt),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      songData.trackName ?? "-",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      songData.albumArtistName ?? "-",
                      style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final sliderValue = ref.watch(sliderValueProvider);
                        final songMax = ref.watch(songMaxValueProvider);
                        return Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: songMax,
                          onChanged: (val) {
                            audioPlayer.seekSong(seekedPosition: val.toInt());
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.shuffle_rounded,
                              size: 25,
                            )),
                        IconButton(
                            onPressed: () {
                              audioPlayer.changeSong(isForward: false);
                            },
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              size: 25,
                            )),
                        IconButton(
                          onPressed: () {
                            audioPlayer.playSong(songPath: songData!.file.path);
                          },
                          style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                          icon: Consumer(builder: (context, ref, child) {
                            final isPlaying = ref.watch(isPlayingProvider);
                            return Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 30,
                            );
                          }),
                        ),
                        IconButton(
                            onPressed: () {
                              audioPlayer.changeSong();
                            },
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              size: 25,
                            )),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.repeat_rounded,
                              size: 25,
                            )),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
