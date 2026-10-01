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

  final TextEditingController _nameController =
      TextEditingController(text: 'Pip');

  // ---------- Care systems (Saurav) ----------

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
    _nameController.dispose();
    super.dispose();
  }

  // ---------- Pet personality (Zachary) ----------

  void _confirmName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _petName = name);
  }

  Color get _moodColor {
    if (_happiness > 70) {
      return Colors.green;
    } else if (_happiness >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String get _moodLabel {
    if (_happiness > 70) {
      return 'Happy';
    } else if (_happiness >= 30) {
      return 'Neutral';
    } else {
      return 'Unhappy';
    }
  }

  IconData get _moodIcon {
    if (_happiness > 70) {
      return Icons.sentiment_very_satisfied;
    } else if (_happiness >= 30) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }

  double get _petScale {
    if (_happiness > 70) {
      return 1.06;
    } else if (_happiness < 30) {
      return 0.94;
    } else {
      return 1.0;
    }
  }

  String get _petMessage {
    if (_gameOver) return 'Game over. I need a rest.';
    if (_hasWon) return 'You won! Best day ever!';
    if (_paused) return 'Paused.';
    if (_hunger > 80) return "I'm starving!";
    if (_happiness <= 30) return 'Play with me?';
    return "Hi, I'm $_petName!";
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(title: Text(_petName)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Pet name',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _confirmName(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _confirmName,
                    child: const Text('Confirm'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              AnimatedScale(
                scale: _petScale,
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(_moodColor, BlendMode.modulate),
                  child: Image.asset('assets/pet.png', width: 220, height: 220),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_moodIcon),
                  const SizedBox(width: 8),
                  Text(
                    'Mood: $_moodLabel',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                child: Text(
                  _petMessage,
                  key: ValueKey(_petMessage),
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 25),

              Text('Happiness: $_happiness'),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _happiness / 100),
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 400),
                builder: (context, value, child) {
                  return LinearProgressIndicator(value: value, minHeight: 12);
                },
              ),

              const SizedBox(height: 20),

              Text('Hunger: $_hunger'),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _hunger / 100),
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 400),
                builder: (context, value, child) {
                  return LinearProgressIndicator(value: value, minHeight: 12);
                },
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: _locked ? null : _feedPet,
                child: const Text('Feed'),
              ),

              ElevatedButton(
                onPressed: _locked ? null : _playWithPet,
                child: const Text('Play'),
              ),

              ElevatedButton(
                onPressed: (_gameOver || _hasWon) ? null : _togglePause,
                child: Text(_paused ? 'Resume' : 'Pause'),
              ),

              ElevatedButton(onPressed: _reset, child: const Text('Reset')),
            ],
          ),
        ),
      ),
    );
  }
}