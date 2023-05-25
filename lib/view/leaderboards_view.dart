import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d2_snake_game/view/play_view.dart';
import 'package:flutter/material.dart';

import 'highscore_tile.dart';



class LeaderboardsView extends StatefulWidget   {
  const LeaderboardsView({super.key});

  @override
  State<LeaderboardsView> createState() => _LeaderboardsViewState();
}

class _LeaderboardsViewState extends State<LeaderboardsView> {

  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;
  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black,
        title: Text('Leaderboards' , style: TextStyle(color: Colors.pink),), centerTitle: true,
      ),
      body: Column(
        
        children: [
          Expanded(
            child: FutureBuilder(
                          future: letsGetDocIds,
                          builder: (context, snapshot) {
                            return ListView.builder(
                                itemCount: highscore_DocIds.length,
                                itemBuilder: (context, index) {
                                  return HighscoreTile(documentId: highscore_DocIds[index]);
                                });
                          },
                        ),
          ),
        ],
      ),
    );
  }
}