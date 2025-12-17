import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Add a new note...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement note saving
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Note'),
          ),
          const SizedBox(height: 24),
          const Text('Existing Snippets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // The list of snippets will go here
        ],
      ),
    );
  }
}
