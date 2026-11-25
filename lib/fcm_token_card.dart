import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Kartu untuk menampilkan FCM Token + tombol salin.
/// Token ini yang nanti ditempel di Postman.
class FcmTokenCard extends StatelessWidget {
  const FcmTokenCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      // ignore: deprecated_member_use
      future: FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb
            ? 'BLL9c10uUXIOxoTe7PSqi2zmniIIQPPvC0foqCLgn-XQsvt4u3tU2izABHEZYJI3-zR50d3gLOco-Lt2jU9BBas'
            : null,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final token = snapshot.data ?? 'Token tidak tersedia';
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FCM Token:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(token, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Salin Token'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: token));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token disalin!')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
