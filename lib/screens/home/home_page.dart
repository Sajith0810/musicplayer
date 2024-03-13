
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3player/helpers/app_methods.dart';
import 'package:mp3player/screens/home/home_page_controller.dart';

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
                            leading: Image.memory(
                              AppMethods().imageConversion(song.albumArt!),
                              height: 100,
                              width: 100,
                            ),
                            title: Text(
                              song.trackName ?? "-",
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(song.albumArtistName ?? "-", style: const TextStyle(fontSize: 13)),
                          ));
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
