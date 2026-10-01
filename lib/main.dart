import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PetScreen()));

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});
  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  // TEST VALUES. Restore to seconds: 30 and minutes: 3 before the release build.
  static const _hungerInterval = Duration(seconds: 5);
  static const _winDuration = Duration(seconds: 5);

  String _petName = 'Pip';
  int _happiness = 50;
  int _hunger = 50;
  bool _gameOver = false;
  bool _hasWon = false;
  bool _paused = false;

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  int _clampMeter(int v) => v.clamp(0, 100).toInt();
  bool get _locked => _gameOver || _hasWon || _paused;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();
    _hungerTimer = Timer.periodic(_hungerInterval, (timer) {
      if (!mounted || _locked) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_hunger + 5 > 100) {
          _hunger = 100;
          _happiness = _clampMeter(_happiness - 20);
        } else {
          _hunger += 5;
        }
      });
      _updateOutcome();
    });
  }

  void _updateOutcome() {
    if (_locked) return;

    if (_hunger == 100 && _happiness <= 10) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      _hungerTimer?.cancel();
      setState(() => _gameOver = true);
      return;
    }

    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    _highMoodTimer ??= Timer(_winDuration, () {
      _highMoodTimer = null;
      if (!mounted || _locked || _happiness <= 80) return;
      setState(() => _hasWon = true);
      _hungerTimer?.cancel();
    });
  }

  void _feedPet() {
    if (_locked) return;
    final nextHunger = _clampMeter(_hunger - 10);
    final change = nextHunger < 30 ? -20 : 10;
    setState(() {
      _hunger = nextHunger;
      _happiness = _clampMeter(_happiness + change);
    });
    _updateOutcome();
  }

  void _playWithPet() {
    if (_locked) return;
    setState(() {
      _happiness = _clampMeter(_happiness + 10);
      _hunger = _clampMeter(_hunger + 5);
    });
    _updateOutcome();
  }

  void _togglePause() {
    if (_gameOver || _hasWon) return;
    if (_paused) {
      setState(() => _paused = false);
      _startHungerTimer();
      _updateOutcome();
    } else {
      _hungerTimer?.cancel();
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      setState(() => _paused = true);
    }
  }

  void _reset() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;
    setState(() {
      _happiness = 50;
      _hunger = 50;
      _gameOver = false;
      _hasWon = false;
      _paused = false;
    });
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    super.dispose();
  }

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
              child: Text(_paused ? 'Resume' : 'Pause'),
            ),
            ElevatedButton(onPressed: _reset, child: const Text('Reset')),
            Image.asset('assets/pet.png', width: 200, height: 200),
          ],
        ),
      ),
    );
  }
}
