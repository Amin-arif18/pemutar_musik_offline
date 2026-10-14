import 'package:flutter/material.dart';

void main() {
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline Music Player',
      theme: ThemeData.dark(), // Tema gelap cocok untuk pemutar musik
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Contoh data dummy daftar lagu lokal
  final List<Map<String, String>> dummySongs = const [
    {'title': 'Lagu Populer 1', 'artist': 'Penyanyi A', 'duration': '03:45'},
    {'title': 'Lagu Favorit 2', 'artist': 'Penyanyi B', 'duration': '04:10'},
    {'title': 'Nada Santai 3', 'artist': 'Penyanyi C', 'duration': '02:55'},
    {'title': 'Melodi Malam 4', 'artist': 'Penyanyi D', 'duration': '03:20'},
    {'title': 'Instrumen Otomatis 5', 'artist': 'Penyanyi E', 'duration': '05:00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemutar Musik Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Daftar Lagu (ListView)
          Expanded(
            child: ListView.builder(
              itemCount: dummySongs.length,
              itemBuilder: (context, index) {
                final song = dummySongs[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.music_note),
                  ),
                  title: Text(song['title']!),
                  subtitle: Text(song['artist']!),
                  trailing: Text(song['duration']!),
                  onTap: () {
                    // Aksi ketika lagu diklik (nanti dihubungkan ke player)
                  },
                );
              },
            ),
          ),

          // Mini Player di bagian bawah (Bottom Player Widget)
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.album, size: 40, color: Colors.blueAccent),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lagu Populer 1',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Penyanyi A',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}