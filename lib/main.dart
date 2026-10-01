import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PetScreen()));

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});
  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  String _petName = 'Pip';
  int _happiness = 50;
  int _hunger = 50;
  bool _gameOver = false;
  bool _hasWon = false;
  bool _paused = false;

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  void _feedPet() {}
  void _playWithPet() {}
  void _reset() {}
  void _togglePause() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_petName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Happiness: $_happiness'),
            Text('Hunger: $_hunger'),
            ElevatedButton(onPressed: _feedPet, child: const Text('Feed')),
            ElevatedButton(onPressed: _playWithPet, child: const Text('Play')),
            ElevatedButton(
                onPressed: _togglePause,
                child: Text(_paused ? 'Resume' : 'Pause')),
            ElevatedButton(onPressed: _reset, child: const Text('Reset')),
          ],
        ),
      ),
    );
  }
}