import 'package:flutter/material.dart';
import 'manual_add_place_screen.dart';

class AddPlaceOptionsScreen extends StatelessWidget {
  const AddPlaceOptionsScreen({super.key});

  static Future<bool> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const AddPlaceOptionsScreen(),
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How would you like to add a place?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.search, size: 32),
              title: const Text('Search on Google Maps'),
              subtitle: const Text('Find and select a place from Google Maps'),
              onTap: () {
                Navigator.pop(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const GoogleMapsSearchScreen(),
                //   ),
              //  );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, size: 32),
              title: const Text('Manual Entry'),
              subtitle: const Text('Enter place details manually or paste a Google Maps link'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManualAddPlaceScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
} 