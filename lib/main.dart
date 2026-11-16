import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Ganti IP sesuai perangkat pengujian:
// - Emulator Android: 'http://10.0.2.2:3000/api'
// - HP Fisik (1 Wi-Fi): 'http://192.168.x.x:3000/api' (IP laptop/server)
// - Windows/Web/iOS Simulator: 'http://localhost:3000/api'
const String baseUrl = 'http://192.168.1.117:3000/api';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final userName = prefs.getString('user_name') ?? 'Pengguna';

  runApp(
    MusicPlayerApp(
      isLoggedIn: token != null && token.isNotEmpty,
      initialUserName: userName,
    ),
  );
}

class MusicPlayerApp extends StatelessWidget {
  final bool isLoggedIn;
  final String initialUserName;

  const MusicPlayerApp({
    super.key,
    required this.isLoggedIn,
    required this.initialUserName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline Music Player',
      theme: ThemeData.dark(),
      home: isLoggedIn
          ? HomeScreen(userName: initialUserName)
          : const LoginScreen(),
    );
  }
}

// ==========================================
// HALAMAN LOGIN
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_name', data['user']['name']);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(userName: data['user']['name']),
          ),
        );
      } else {
        _showMessage(data['message'] ?? 'Login gagal');
      }
    } catch (e) {
      _showMessage('Gagal terhubung ke server Docker ($baseUrl)');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.library_music,
                size: 72,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Pemutar Musik Offline',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Masuk'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Belum punya akun? Daftar sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN REGISTRASI
// ==========================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.pop(context);
      } else {
        _showMessage(data['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      _showMessage('Gagal terhubung ke server Docker ($baseUrl)');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN UTAMA PEMUTAR MUSIK
// ==========================================
class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dummySongs = const [
    {'title': 'Lagu Populer 1', 'artist': 'Penyanyi A', 'duration': '03:45'},
    {'title': 'Lagu Favorit 2', 'artist': 'Penyanyi B', 'duration': '04:10'},
    {'title': 'Nada Santai 3', 'artist': 'Penyanyi C', 'duration': '02:55'},
    {'title': 'Melodi Malam 4', 'artist': 'Penyanyi D', 'duration': '03:20'},
    {
      'title': 'Instrumen Otomatis 5',
      'artist': 'Penyanyi E',
      'duration': '05:00',
    },
  ];

  int _currentIndex = 0;
  bool _isPlaying = false;

  void _playSong(int index) {
    setState(() {
      _currentIndex = index;
      _isPlaying = true;
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _nextSong() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % dummySongs.length;
      _isPlaying = true;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = dummySongs[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${widget.userName}'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dummySongs.length,
              itemBuilder: (context, index) {
                final song = dummySongs[index];
                final isSelected = index == _currentIndex;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? Colors.blueAccent : null,
                    child: Icon(
                      isSelected && _isPlaying
                          ? Icons.equalizer
                          : Icons.music_note,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  title: Text(
                    song['title']!,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.blueAccent : null,
                    ),
                  ),
                  subtitle: Text(song['artist']!),
                  trailing: Text(song['duration']!),
                  onTap: () => _playSong(index),
                );
              },
            ),
          ),
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.album, size: 40, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentSong['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentSong['artist']!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: _nextSong,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
