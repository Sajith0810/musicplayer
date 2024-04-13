import 'dart:ui';

import 'package:flutter/cupertino.dart';
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
  final searchTextController = TextEditingController();
  late final Tween<double> animation;
  List<SongsModel> songs = [];

  @override
  void initState() {
    animation = Tween<double>(begin: 0, end: 300);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      songs = await ref.read(homePageControllerProvider).getDBSongs();
      // await compute(scanFiles(), noSuchMethod);
    });
    super.initState();
  }

  scanFiles() async {
    await ref.read(homePageControllerProvider).scanAllMp3Files();
  }

  @override
  Widget build(BuildContext context) {
    AudioPlayerController audioPlayerController = ref.watch(audioPlayerControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Consumer(builder: (context, ref, child) {
          final isTextField = ref.watch(textFieldSwithcerProvider);
          if (isTextField) {
            return TweenAnimationBuilder(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeIn,
                tween: animation,
                builder: (context, value, child) {
                  print(value);
                  return SizedBox(
                    height: AppMethods().getWidth(context) * 0.1,
                    width: value,
                    child: TextFormField(
                      controller: searchTextController,
                      onChanged: (val) {
                        print(val);
                        final data = ref.read(mp3SongListProvider);
                        final filteredSongs = songs.where((element) => element.trackName!.toLowerCase().contains(val.toLowerCase())).toList();
                        if (filteredSongs.isEmpty && val == "") {
                          ref.read(mp3SongListProvider.notifier).state = songs;
                        } else {
                          ref.read(mp3SongListProvider.notifier).state = filteredSongs;
                        }
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          hintFadeDuration: Duration(milliseconds: 500),
                          hintText: "Search songs",
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(width: 1)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(width: 1))),
                    ),
                  );
                });
          } else {
            return const Text("Music");
          }
        }),
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                final oldBool = ref.read(textFieldSwithcerProvider);
                ref.read(textFieldSwithcerProvider.notifier).state = !oldBool;
              },
              icon: Icon(Icons.search_rounded))
        ],
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
          final currentPlayingSongIndex = ref.watch(selectedSongIndexProvider);
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
                        precacheImage(MemoryImage(AppMethods().imageConversion(song.albumArt!)), context);
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
                            leading: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: MemoryImage(
                                    AppMethods().imageConversion(song.albumArt ?? ""),
                                  ),
                                ),
                              ),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                song.trackName ?? "-",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: currentPlayingSongIndex == index ? Colors.deepPurple : null,
                                ),
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
                SizedBox(
                  width: AppMethods().getWidth(context) * 0.95,
                  child: Consumer(builder: (context, ref, child) {
                    final currentPlayingSong = ref.watch(selectedSongProvider);
                    final isPlaying = ref.watch(isPlayingProvider);
                    return currentPlayingSong != null
                        ? Card(
                            color: Colors.deepPurple[100],
                            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(45)),
                            clipBehavior: Clip.hardEdge,
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                Container(
                                  child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 55),
                                      child: Image.memory(
                                        AppMethods().imageConversion(currentPlayingSong.albumArt ?? ""),
                                        width: AppMethods().getWidth(context),
                                        height: AppMethods().getHeight(context) * 0.05,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                Container(
                                  color: Colors.white54,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundImage: MemoryImage(
                                        AppMethods().imageConversion(currentPlayingSong.albumArt ?? ""),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () async {
                                        final audioPlayer = ref.read(audioPlayerControllerProvider);
                                        ref.read(isPlayingProvider) ? await audioPlayer.pauseSong() : await audioPlayer.resumeSong();
                                        ref.read(isPlayingProvider.notifier).state = !ref.read(isPlayingProvider);
                                      },
                                      icon: Icon(
                                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    title: Text(
                                      currentPlayingSong.trackName ?? "",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox();
                  }),
                )
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
                          gaplessPlayback: true,
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
                                  activeColor: Colors.black,
                                  secondaryActiveColor: Colors.black87,
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
                                    color: Colors.black87,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    audioPlayer.changeSong(isForward: false);
                                  },
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                    size: 25,
                                    color: Colors.black87,
                                  )),
                              IconButton(
                                onPressed: () async {
                                  ref.read(isPlayingProvider) ? await audioPlayer.pauseSong() : await audioPlayer.resumeSong();
                                  ref.read(isPlayingProvider.notifier).state = !ref.read(isPlayingProvider);
                                },
                                style: IconButton.styleFrom(backgroundColor: Colors.black87),
                                icon: Consumer(builder: (context, ref, child) {
                                  final isPlaying = ref.watch(isPlayingProvider);
                                  return Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 35,
                                    color: Colors.white,
                                  );
                                }),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    await audioPlayer.changeSong();
                                  },
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    size: 25,
                                    color: Colors.black87,
                                  )),
                              Consumer(builder: (context, ref, child) {
                                final isRepeat = ref.watch(isRepeatModeProvider);
                                return IconButton(
                                    onPressed: () {
                                      ref.read(isRepeatModeProvider.notifier).state = !ref.read(isRepeatModeProvider);
                                    },
                                    style: IconButton.styleFrom(backgroundColor: isRepeat ? Colors.blueAccent : null),
                                    icon: const Icon(
                                      Icons.repeat_rounded,
                                      size: 25,
                                      color: Colors.black87,
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
