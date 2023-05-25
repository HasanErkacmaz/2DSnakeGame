import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d2_snake_game/view/blank_pixel.dart';
import 'package:d2_snake_game/view/food_pixel.dart';
import 'package:d2_snake_game/view/highscore_tile.dart';
import 'package:d2_snake_game/view/menu_view.dart';
import 'package:d2_snake_game/view/snake_pixel.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayView extends StatefulWidget {
  const PlayView({super.key});

  @override
  State<PlayView> createState() => _PlayViewState();
}

enum SnakeDirections { UP, DOWN, LEFT, RIGHT }

class _PlayViewState extends State<PlayView> {
  //grid dimensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;
  int currentScore = 0;
  bool gameHasStarted = false;
  final _nameController = TextEditingController();
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  final player = AudioPlayer();

  //Snake directions initially to the right
  var currentDirection = SnakeDirections.RIGHT;
  //Food position
  int foodPos = 63;

  //highScore list
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

  //Start Game
  void startgame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();

        //check if the game is over
        if (gameOver()) {
          timer.cancel();
          //display a message for the user
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Game Over'),
                content: Column(
                  children: [
                    Text('Your Score Is: $currentScore'),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Enter Name'),
                    )
                  ],
                ),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      submitScore();
                      newGame();
                      Navigator.pop(context);
                    },
                    color: Colors.pink,
                    child: const Text('Submit'),
                  )
                ],
              );
            },
          );
        }
        eatFood();
      });
    });
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();

    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos == 63;
      currentDirection = SnakeDirections.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void submitScore() {
    //get access to the collection
    var dataBase = FirebaseFirestore.instance;

    //add data to fireBase
    dataBase.collection('highscores').add({"name": _nameController.text, "score": currentScore});
  }

  void moveSnake() {
    switch (currentDirection) {
      case SnakeDirections.RIGHT:
        {
          //add a new head
          //if snake is at the right wall, need re-adjust
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case SnakeDirections.LEFT:
        {
          //add a new head
          //if snake is at the right wall, need re-adjust
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case SnakeDirections.UP:
        {
          //add a new head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case SnakeDirections.DOWN:
        {
          //add a new head
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }

    //snake is eating food
    if (snakePos.last == foodPos) {
      eatFood();
      playEatSound();
      currentScore++;
    } else {
      //remove the  tail
      snakePos.removeAt(0);
    }
  }

  Future<void> playEatSound() async {
     await player.play(AssetSource('EatingSound.mp3'));
  }
  Future<void> eatFood() async {
    //making sure the new food is not where the snake is
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  //game over method
  bool gameOver() {
    //game is over when the snake hit to itself
    //this occours when there is a duplicate position in the snakPos list
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);
    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Current Score'),
                    Text(currentScore.toString(), style: const TextStyle(fontSize: 36)),
                    //high scores top 5
                  ], //user current score
                ),
              ),
              Expanded(
                child: gameHasStarted
                    ? Container()
                    : FutureBuilder(
                        future: letsGetDocIds,
                        builder: (context, snapshot) {
                          return ListView.builder(
                              itemCount: highscore_DocIds.length,
                              itemBuilder: (context, index) {
                                return HighscoreTile(documentId: highscore_DocIds[index]);
                              });
                        },
                      ),
              )
            ],
          )),
          Expanded(
            flex: 4,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 && currentDirection != SnakeDirections.UP) {
                  currentDirection = SnakeDirections.DOWN;
                } else if (details.delta.dy < 0 && currentDirection != SnakeDirections.DOWN) {
                  currentDirection = SnakeDirections.UP;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && currentDirection != SnakeDirections.LEFT) {
                  currentDirection = SnakeDirections.RIGHT;
                } else if (details.delta.dx < 0 && currentDirection != SnakeDirections.RIGHT) {
                  currentDirection = SnakeDirections.LEFT;
                }
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowSize,
                ),
                itemCount: totalNumberOfSquares,
                itemBuilder: (BuildContext context, int index) {
                  if (snakePos.contains(index)) {
                    return const SnakePixel();
                  } else if (foodPos == index) {
                    return const FoodPixel();
                  } else {
                    return const BlankPixel();
                  }
                },
              ),
            ),
          ),
          //play button
          Center(
            child: MaterialButton(
              onPressed: gameHasStarted
                  ? () {}
                  : () {
                      startgame();
                    },
              color: gameHasStarted ? Colors.grey : Colors.pink,
              child: const Text('Start'),
            ),
          ),
          Center(
            child: MaterialButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (context) => const MenuView()), (route) => false);
              },
              color: Colors.pink,
              child: const Text('Menu'),
            ),
          )
        ],
      ),
    );
  }
}
