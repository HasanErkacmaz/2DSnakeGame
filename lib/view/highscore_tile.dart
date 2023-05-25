// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighscoreTile extends StatelessWidget {
  const HighscoreTile({
    Key? key,
    required this.documentId,
  }) : super(key: key);
  final String documentId;
  @override
  Widget build(BuildContext context) {
    //get the collection of highscores
    CollectionReference highscores = FirebaseFirestore.instance.collection("highscores");

    return FutureBuilder<DocumentSnapshot>(
      future: highscores.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Row(
            children: [
              Center(child: Text(data['score'].toString(), style: TextStyle(color: Colors.pink, fontSize: 20))),
              const SizedBox(width: 20),
              Center(
                child: Text(
                  data['name'],
                  style: TextStyle(color: Colors.white , fontSize: 20),
                ),
              )
            ],
          );
        } else {
          return const Text('Loading...');
        }
      },
    );
  }
}
