import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:rock_blaster/music_player.dart';

class Tracks extends StatefulWidget {
  _TracksState createState() => _TracksState();
}

// Récupération de la liste de Musique
class _TracksState extends State<Tracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];
  int currentIndex = 0;
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  void initState() {
    super.initState();
    getTracks();
  }

  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  void changeTrack(bool isNext) {
    if (isNext) {
      if (currentIndex != songs.length - 1) {
        currentIndex++;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
      }
    }
    key.currentState.setSong(songs[currentIndex]);
  }

// Titre Entête
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        leading:
            Icon(Icons.music_note_outlined, color: Colors.black, size: 30.0),
        title: Text('Rock Music Blaster',
            style: TextStyle(color: Colors.white, fontSize: 30)),
      ),

// Affichage du Contenu Principal avec Artwork, Titre, Artiste de la Chanson
      backgroundColor: Colors.grey[900],
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: songs.length,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            backgroundImage: songs[index].albumArtwork == null
                ? AssetImage('assets/images/guitare.jpg')
                : FileImage(File(songs[index].albumArtwork)),
          ),
          title:
              Text(songs[index].title, style: TextStyle(color: Colors.white)),
          subtitle:
              Text(songs[index].artist, style: TextStyle(color: Colors.white)),
          onTap: () {
            currentIndex = index;
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MusicPlayer(
                    changeTrack: changeTrack,
                    songInfo: songs[currentIndex],
                    key: key)));
          },
        ),
      ),
    );
  }
}
