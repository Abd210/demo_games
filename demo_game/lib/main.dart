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
      create: (_) => GameProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Survival Adventure',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _choiceController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _choiceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
            onPressed: () {
              gameProvider.clearGame();
              _choiceController.clear();
            },
          ),
        ],
      ),
      // Gradient background for a polished look
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Story area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildStoryList(gameProvider),
                ),
              ),

              // Either show a loading spinner or the input area
              if (gameProvider.isLoading) const CircularProgressIndicator(),

              if (!gameProvider.isLoading) _buildChoiceArea(gameProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryList(GameProvider gameProvider) {
    // Split by line breaks to create "bubbles" or you can keep it simple
    final lines = gameProvider.story.split('\n').where((e) => e.trim().isNotEmpty).toList();

    return ListView.builder(
      controller: _scrollController,
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final text = lines[index];
        // If line starts with "You:", we consider it user text; otherwise, AI text
        bool isUser = text.trim().toLowerCase().startsWith('you:');
        return _buildMessageBubble(text, isUser);
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.black87 : Colors.black54,
            fontStyle: isUser ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceArea(GameProvider gameProvider) {
    return Container(
      color: Colors.white70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const Text(
            'Enter your choice (or pick below):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _choiceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. Begin or Inspect surroundings',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final choice = _choiceController.text.trim();
                  if (choice.isNotEmpty) {
                    gameProvider.makeChoice(choice);
                    _choiceController.clear();
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // A couple of preset choices
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => gameProvider.makeChoice('Explore the cave'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                ),
                child: const Text('Explore the cave'),
              ),
              ElevatedButton(
                onPressed: () => gameProvider.makeChoice('Go to the oasis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                ),
                child: const Text('Go to the oasis'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
