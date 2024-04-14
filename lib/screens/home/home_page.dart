import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                          hintFadeDuration: const Duration(milliseconds: 500),
                          hintText: "Search songs",
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(width: 1)),
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
              icon: const Icon(Icons.search_rounded))
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
                    addRepaintBoundaries: true,
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
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: Card(
                                elevation: 0,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                child: FadeInImage(
                                    fit: BoxFit.cover,
                                    image: MemoryImage(
                                      AppMethods().imageConversion(song.albumArt ?? ""),
                                    ),
                                    placeholder: const AssetImage("assets/bg_images/music-placeholder.png")),
                              ),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                song.trackName ?? "-",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: currentPlayingSongIndex == index && ref.read(selectedSongProvider) != null ? Colors.deepPurple : null,
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
                        ? InkWell(
                            onTap: () {
                              songPage(audioPlayer: audioPlayerController);
                            },
                            child: Card(
                              color: Colors.deepPurple[100],
                              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(45)),
                              clipBehavior: Clip.hardEdge,
                              child: Stack(
                                clipBehavior: Clip.hardEdge,
                                children: [
                                  Container(
                                    width: AppMethods().getWidth(context),
                                    height: AppMethods().getHeight(context) * 0.05,
                                    child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 55),
                                        child: FadeInImage(
                                            fit: BoxFit.cover,
                                            image: MemoryImage(
                                              AppMethods().imageConversion(currentPlayingSong.albumArt ?? ""),
                                            ),
                                            placeholder: const AssetImage("assets/bg_images/music-placeholder.png"))),
                                  ),
                                  Container(
                                    color: Colors.white54,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                      leading: Card(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        child: FadeInImage(
                                            fit: BoxFit.cover,
                                            image: MemoryImage(
                                              AppMethods().imageConversion(currentPlayingSong.albumArt ?? ""),
                                            ),
                                            placeholder: const AssetImage("assets/bg_images/music-placeholder.png")),
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
                      child: FadeInImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(
                            AppMethods().imageConversion(songData?.albumArt ?? ""),
                          ),
                          placeholder: const AssetImage("assets/bg_images/music-placeholder.png")),
                    ),
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
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: FadeInImage(
                              fit: BoxFit.cover,
                              image: MemoryImage(
                                AppMethods().imageConversion(songData?.albumArt ?? ""),
                              ),
                              placeholder: const AssetImage("assets/bg_images/music-placeholder.png")),
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
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        audioPlayer.convertSecondsToMinutes(
                                          songMax.toInt(),
                                        ),
                                        style: const TextStyle(fontSize: 15),
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
                              Consumer(builder: (context, ref, child) {
                                final isShuffleEnabled = ref.watch(isShuffleEnabledPRovider);
                                return IconButton(
                                    style: IconButton.styleFrom(backgroundColor: isShuffleEnabled ? Colors.blueAccent : null),
                                    onPressed: () {
                                      if (!isShuffleEnabled) {
                                        ref.read(audioPlayerControllerProvider).shuffleSongs();
                                      } else {
                                        ref.read(audioPlayerControllerProvider).sortSongs();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.shuffle_rounded,
                                      size: 25,
                                      color: Colors.black87,
                                    ));
                              }),
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
