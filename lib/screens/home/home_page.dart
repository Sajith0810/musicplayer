import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      drawer: SafeArea(
        child: Container(
          width: AppMethods().getWidth(context) * 0.72,
          margin: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
          child: const Column(
            children: [],
          ),
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
                            audioPlayerController.playSong(songPath: ref.read(selectedSongProvider)!.file);
                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                              ref.read(isPlayingProvider.notifier).state = true;
                            });
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
        return SingleChildScrollView(
          child: Consumer(
            builder: (context, ref, child) {
              final songData = ref.watch(selectedSongProvider);
              return Stack(
                children: [
                  Container(
                    width: AppMethods().getWidth(context),
                    height: AppMethods().getHeight(context),
                    color: Colors.white,
                    child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                        child: Image.memory(
                          AppMethods().imageConversion(songData?.albumArt ?? ""),
                          width: AppMethods().getWidth(context),
                          height: AppMethods().getHeight(context),
                          fit: BoxFit.cover,
                        )),
                  ),
                  Container(
                    height: AppMethods().getHeight(context),
                    width: AppMethods().getWidth(context),
                    color: Colors.white54,
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
                                AppMethods().imageConversion(songData?.albumArt ?? ""),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Text(
                            songData?.trackName ?? "-",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            songData?.albumArtistName ?? "-",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Consumer(builder: (context, ref, child) {
                            final sliderValue = ref.watch(sliderValueProvider);
                            final songMax = ref.watch(songMaxValueProvider);
                            return Column(
                              children: [
                                Slider(
                                  value: sliderValue,
                                  min: 0.0,
                                  max: songMax + 1,
                                  onChanged: (val) {
                                    audioPlayer.seekSong(seekedPosition: val.toInt());
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        audioPlayer.convertSecondsToMinutes(
                                          sliderValue.toInt(),
                                        ),
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        audioPlayer.convertSecondsToMinutes(
                                          songMax.toInt(),
                                        ),
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          }),
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
                                onPressed: () async {
                                  ref.read(isPlayingProvider) ? await audioPlayer.pauseSong() : await audioPlayer.resumeSong();
                                  ref.read(isPlayingProvider.notifier).state = !ref.read(isPlayingProvider);
                                },
                                style: IconButton.styleFrom(backgroundColor: Color(0xff006da4)),
                                icon: Consumer(builder: (context, ref, child) {
                                  final isPlaying = ref.watch(isPlayingProvider);
                                  return Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  );
                                }),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    print("chnage song");
                                    await audioPlayer.changeSong();
                                  },
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    size: 25,
                                  )),
                              Consumer(builder: (context, ref, child) {
                                final isRepeat = ref.watch(isRepeatModeProvider);
                                return IconButton(
                                    onPressed: () {
                                      ref.read(isRepeatModeProvider.notifier).state = !ref.read(isRepeatModeProvider);
                                    },
                                    style: IconButton.styleFrom(backgroundColor: isRepeat ? Colors.green : null),
                                    icon: const Icon(
                                      Icons.repeat_rounded,
                                      size: 25,
                                    ));
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
