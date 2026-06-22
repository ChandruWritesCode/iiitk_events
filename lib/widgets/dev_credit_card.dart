import 'package:flutter/material.dart';
import 'package:iiitk_events/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class DevCreditCard extends StatelessWidget {
  const DevCreditCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              chandruProfilePic,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Developed by Chandragouda M K',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'with Flutter & Firebase',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.code_rounded, color: Colors.white54),
                onPressed: () => launchUrl(
                  Uri.parse('https://github.com/ChandruWritesCode'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.link_rounded, color: Colors.white54),
                onPressed: () => launchUrl(
                  Uri.parse(
                    'https://linkedin.com/in/chandragouda-karegoudra-096414373',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
