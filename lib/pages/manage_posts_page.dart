import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iiitk_events/pages/create_event_form_page.dart';
import 'package:iiitk_events/widgets/event_card.dart';
import 'package:iiitk_events/pages/event_details_page.dart';

class ManagePostsPage extends StatelessWidget {
  const ManagePostsPage({super.key});

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
          'Manage My Posts',
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
            .where('creatorId', isEqualTo: currentUser?.uid)
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
                'Error loading your posts.',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t posted any events yet.',
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
                    color: Colors.redAccent.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF121212),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFF333333)),
                        ),
                        title: const Text(
                          "Confirm Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          "Are you sure you want to delete this event? This action cannot be undone.",
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('events')
                      .doc(doc.id)
                      .delete();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event deleted successfully.'),
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
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateEventPage(eventId: doc.id, initialData: data),
                      ),
                    );
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsPage(
                          eventId: doc.id,
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
