import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iiitk_events/pages/event_details_page.dart';
import 'package:iiitk_events/widgets/event_card.dart';

class SavedEventsPage extends StatelessWidget {
  const SavedEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Saved Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('savedBy', arrayContains: currentUser?.uid)
            .orderBy('eventDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading saved events.',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t saved any events yet.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              String dateString = 'TBA';
              if (data['eventDate'] != null) {
                DateTime date = (data['eventDate'] as Timestamp).toDate();
                dateString =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
              }

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(
                      alpha: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.bookmark_remove_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('events')
                      .doc(doc.id)
                      .update({
                        'savedBy': FieldValue.arrayRemove([currentUser?.uid]),
                      });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from Saved Events.'),
                      ),
                    );
                  }
                },
                child: EventCard(
                  title: data['title'] ?? 'Untitled Event',
                  host: data['host'] ?? 'Unknown',
                  date: dateString,
                  location: data['venue'] ?? 'TBA',
                  imageUrl: data['imageUrl'] ?? '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsPage(
                          eventId: docs[index].id,
                          title: data['title'] ?? 'Untitled',
                          host: data['host'] ?? 'Unknown',
                          date: dateString,
                          location: data['venue'] ?? 'TBA',
                          description: data['description'] ?? '',
                          imageUrl: data['imageUrl'] ?? '',
                          link: data['registrationLink'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
