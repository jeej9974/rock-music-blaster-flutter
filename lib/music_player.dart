import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

// Déclaration des Fonctions de Lecture
class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({this.songInfo, this.changeTrack, this.key}) : super(key: key);
  MusicPlayerState createState() => MusicPlayerState();
}

// Temps de Lecture Mis à Zero
class MusicPlayerState extends State<MusicPlayer> {
  double minimumValue = 0.0, maximumValue = 0.0, currentValue = 0.0;
  String currentTime = '', endTime = '';
  bool isPlaying = false;
  final AudioPlayer player = AudioPlayer();

  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  void dispose() {
    super.dispose();
    player?.dispose();
  }

// Récupération du Temps de Lecture de La Chanson
  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentValue = minimumValue;
    maximumValue = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maximumValue);
    });
    isPlaying = false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentValue);
      });
    });
  }

  void changeStatus() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

// Titre Entête
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_outlined,
                color: Colors.black, size: 30.0)),
        title: Text('En Lecture',
            style: TextStyle(color: Colors.white, fontSize: 30.0)),
      ),
// Contenu Principal et Affichage Artwork de la Chanson
      backgroundColor: Colors.grey[900],
      body: Container(
        margin: EdgeInsets.fromLTRB(5, 40, 5, 0),
        child: Column(children: <Widget>[
          CircleAvatar(
            backgroundImage: widget.songInfo.albumArtwork == null
                ? AssetImage('assets/images/guitare.jpg')
                : FileImage(File(widget.songInfo.albumArtwork)),
            radius: 95,
          ),
//Affichage Titre de la Chanson
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
            child: Text(
              widget.songInfo.title,
              style: TextStyle(
                  color: Colors.yellow[200],
                  fontStyle: FontStyle.italic,
                  fontSize: 23.0,
                  fontWeight: FontWeight.w800),
            ),
          ),
// Affichage Artiste de la Chanson
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Text(
              widget.songInfo.artist,
              style: TextStyle(
                  color: Colors.yellow[200],
                  fontStyle: FontStyle.italic,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
// Affichage Slider et Avance Rapide de la Chanson
          Slider(
            inactiveColor: Colors.grey[400],
            activeColor: Colors.purpleAccent[400],
            min: minimumValue,
            max: maximumValue,
            value: currentValue,
            onChanged: (value) {
              currentValue = value;
              player.seek(Duration(milliseconds: currentValue.round()));
            },
          ),
// Affichage Temps de la Chanson
          Container(
            transform: Matrix4.translationValues(0, -5, 0),
            margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentTime,
                    style: TextStyle(
                        color: Colors.yellow[200],
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text(endTime,
                    style: TextStyle(
                        color: Colors.yellow[200],
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        fontWeight: FontWeight.w500))
              ],
            ),
          ),
// Affichage des Boutons de Lecture
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
// Action Bouton Lecture Chanson Précédante
                GestureDetector(
                  child: Icon(Icons.skip_previous,
                      color: Colors.lightBlue[600], size: 55),
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    widget.changeTrack(false);
                  },
                ),
// Action Bouton Lecture et Pause
                GestureDetector(
                  child: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: Colors.lightBlue[600],
                      size: 75),
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    changeStatus();
                  },
                ),
// Action Bouton Lecture Chanson Suivante
                GestureDetector(
                  child: Icon(Icons.skip_next,
                      color: Colors.lightBlue[600], size: 55),
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    widget.changeTrack(true);
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
