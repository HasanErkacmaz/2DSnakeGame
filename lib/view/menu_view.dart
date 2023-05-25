import 'package:animated_background/animated_background.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:d2_snake_game/view/leaderboards_view.dart';
import 'package:d2_snake_game/view/play_view.dart';
import 'package:flutter/material.dart';



class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> with SingleTickerProviderStateMixin {
  bool playing = true;
  final player = AudioPlayer();

  Future<void> playerSong() async {
    if (playing == true) {
      await player.play(AssetSource('HansZimmerCornfieldChase.mp3'));
    } else {
      await player.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    playerSong();
    return Scaffold(
     
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text('The Snake Game',
              style: TextStyle(color: Colors.pink, fontStyle: FontStyle.italic, fontSize: 40)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black),
      body: AnimatedBackground( vsync:this, behaviour: SpaceBehaviour(), child: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.only(left: 300, top: 20),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    playing = !playing;
                  });
                },
                icon: playing ? const Icon(Icons.music_note) : const Icon(Icons.music_off)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 160),
              child: FloatingActionButton.large(
                backgroundColor: Colors.pink,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayView()));
                  setState(() {
                    playing = false;
                  });
                },
                child: const Text('PLAY'),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: FloatingActionButton.extended(
                label: const Text('LEADERBOARDS'),
                backgroundColor: Colors.pink,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderboardsView(),));
                },
              ),
            ),
          ),
        ],
      )) 
    );
  }
}
