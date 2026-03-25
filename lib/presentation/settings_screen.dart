import 'package:flutter/material.dart';

// Simple settings / about screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8)
              ],
            ),
            child: Column(
              children: [
                _tile(Icons.info_outline, 'About Move Smart',
                    'Kigali city bus booking app'),
                _tile(Icons.map_outlined, 'Map Source', 'OpenStreetMap'),
                _tile(Icons.location_city, 'City', 'Kigali, Rwanda'),
                _tile(Icons.tag, 'Version', '1.0.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String sub) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: 22),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(sub,
          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
    );
  }
}
