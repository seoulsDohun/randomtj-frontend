import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:randomtj/model/sing_model.dart';
import 'dart:convert';

import 'package:randomtj/service/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 바인딩 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SongSearch(),
    );
  }
}

class SongSearch extends StatefulWidget {
  const SongSearch({super.key});

  @override
  _SongSearchState createState() => _SongSearchState();
}

class _SongSearchState extends State<SongSearch> {
  List<Map<String, String>> songList = [];
  bool isLoading = false;
  final client = http.Client();

  Future<List<SingModel>> sings = ApiService.getKaraokeOpenApi();

  /// Keyword 검색어
  /// Type 검색 타입 (0: 통합검색, 1: 제목, 2: 가수, 4: 작사가, 8: 작곡가, 16: 곡 번호, 32: 가사)
  /// Nation 국가 ("": 모든국가, "KOR": 국내가요, "ENG": 팝송, "JPN": 일본곡, "CHN": 중국곡)
  /// strCond 0: 통합검색, 1: 단일검색
  Future<void> searchSongs(String keyword, String type, String nation) async {
    setState(() {
      isLoading = true;
    });
    final url =
        Uri.parse('https://www.tjmedia.com/tjsong/song_search_list.asp');
    final response = await client.post(url, body: {
      'strText': keyword,
      'strType': type,
      'natType': nation,
      'strCond': '0',
      'strSize01': '15',
      'strSize02': '15',
      'strSize03': '15',
      'strSize04': '15',
      'strSize05': '15',
    }, headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    });

    if (response.statusCode == 200) {
      // 응답 바이트 데이터를 utf-8로 디코딩
      final decodedBody = utf8.decode(response.bodyBytes, allowMalformed: true);
      final document = parse(decodedBody);
      final songElements = document.querySelectorAll('#BoardType1 tr');

      List<Map<String, String>> songs = [];
      for (var i = 1; i < songElements.length; i++) {
        final songElement = songElements[i];
        if (songElement.text.contains("검색 결과를 찾을 수 없습니다.")) continue;

        final song = {
          'test': songElement.text,
          'songId': songElement.children[0].text.trim(),
          'songTitle': songElement.children[1].text.trim(),
          'singer': songElement.children[2].text.trim(),
          'composer': songElement.children[3].text.trim(),
          'lyricist': songElement.children[4].text.trim(),
        };
        songs.add(song);
      }

      setState(() {
        songList = songs;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load songs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Search'),
      ),
      body: Column(
        children: [
          TextField(
            onSubmitted: (value) {
              searchSongs(value, "1", "");
            },
            decoration: const InputDecoration(
              labelText: 'Search for a song',
            ),
          ),
          Expanded(child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (songList.isEmpty) {
                return const Center(
                  child: Text('검색된 노래가 없습니다.'),
                );
              } else {
                return ListView.builder(
                  itemCount: songList.length,
                  itemBuilder: (context, index) {
                    final song = songList[index];
                    return ListTile(
                      title: Text(song['songTitle'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('가수: ${song['singer']}'), // 가수 표시
                          Text('곡번호: ${song['songId']}'), // 곡번호 표시
                        ],
                      ),
                      hoverColor: Colors.yellow,
                    );
                  },
                );
              }
            },
          )),
        ],
      ),
    );
  }
}
