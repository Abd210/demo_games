import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_provider.dart';

void main() {
  runApp(const AdventureGameApp());
}

class AdventureGameApp extends StatelessWidget {
  const AdventureGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Survival Adventure',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survival Adventure'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => gameProvider.clearGame(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  gameProvider.story,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            if (gameProvider.isLoading)
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
            if (!gameProvider.isLoading)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => gameProvider.makeChoice('Explore the cave'),
                    child: const Text('Explore the cave'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => gameProvider.makeChoice('Go to the oasis'),
                    child: const Text('Go to the oasis'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
