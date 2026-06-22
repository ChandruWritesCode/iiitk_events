import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;
  final String title;
  final String host;
  final String date;
  final String location;
  final String description;
  final String imageUrl;
  final String link;

  const EventDetailsPage({
    super.key,
    required this.eventId,
    required this.title,
    required this.host,
    required this.date,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.link,
  });

  Future<void> _launchExternalLink(
    String urlString,
    BuildContext context,
  ) async {
    if (urlString.isEmpty) return;

    final uri = Uri.parse(
      urlString.startsWith('http') ? urlString : 'https://$urlString',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the provided link.')),
        );
      }
    }
  }

  Widget _buildDetailBox(IconData icon, String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00FF66), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttendeesSheet(BuildContext context, List<String> uids) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          builder: (_, controller) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Attendees',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<DocumentSnapshot>>(
                    future: Future.wait(
                      uids.map(
                        (id) => FirebaseFirestore.instance
                            .collection('users')
                            .doc(id)
                            .get(),
                      ),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(
                          child: Text(
                            'Error loading attendees.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }

                      final docs = snapshot.data!;
                      return ListView.builder(
                        controller: controller,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>?;

                          final name = data?['displayName'] ?? 'IIITK Student';
                          final photoUrl =
                              data?['profilePhotoUrl'] ??
                              data?['photoUrl'] ??
                              '';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF333333),
                              backgroundImage: photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white54,
                                    )
                                  : null,
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final Color neonEmerald = const Color(0xFF00FF66);
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final savedBy = List<String>.from(data?['savedBy'] ?? []);
        final attendees = List<String>.from(data?['attendees'] ?? []);

        final isSaved =
            currentUser != null && savedBy.contains(currentUser.uid);
        final isAttending =
            currentUser != null && attendees.contains(currentUser.uid);
        final int attendeeCount = attendees.length;

        return Scaffold(
          backgroundColor: Colors.black,

          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(
                onPressed: () async {
                  if (currentUser == null) return;

                  final docRef = FirebaseFirestore.instance
                      .collection('events')
                      .doc(eventId);

                  if (isAttending) {
                    await docRef.update({
                      'attendees': FieldValue.arrayRemove([currentUser.uid]),
                    });
                  } else {
                    await docRef.update({
                      'attendees': FieldValue.arrayUnion([currentUser.uid]),
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registration confirmed!'),
                        ),
                      );
                    }

                    if (link.isNotEmpty && context.mounted) {
                      await _launchExternalLink(link, context);
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: isAttending
                      ? Colors.transparent
                      : neonEmerald,
                  foregroundColor: isAttending
                      ? Colors.redAccent
                      : Colors.black,
                  side: isAttending
                      ? const BorderSide(color: Colors.redAccent, width: 1.5)
                      : BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isAttending ? 'Cancel Registration' : 'Register Now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  // SHARE
                  IconButton(
                    icon: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      final String shareText =
                          "🔥 Check out this event: $title!\n\n"
                          "📅 $date\n"
                          "📍 $location\n\n"
                          "${link.isNotEmpty ? '🔗 Register here: $link\n\n' : ''}"
                          "Shared via IIITK Events App";
                      // ignore: deprecated_member_use
                      Share.share(shareText);
                    },
                  ),
                  // BOOKMARK 
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: isSaved ? neonEmerald : Colors.white,
                        size: 28,
                      ),
                      onPressed: () async {
                        if (currentUser == null) return;

                        final docRef = FirebaseFirestore.instance
                            .collection('events')
                            .doc(eventId);

                        if (isSaved) {
                          await docRef.update({
                            'savedBy': FieldValue.arrayRemove([
                              currentUser.uid,
                            ]),
                          });
                        } else {
                          await docRef.update({
                            'savedBy': FieldValue.arrayUnion([currentUser.uid]),
                          });
                        }
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFF121212),
                              child: const Icon(
                                Icons.image_rounded,
                                size: 80,
                                color: Color(0xFF333333),
                              ),
                            ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              Colors.black,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        host.toUpperCase(),
                        style: TextStyle(
                          color: neonEmerald,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: () {
                          if (attendeeCount > 0) {
                            _showAttendeesSheet(context, attendees);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orangeAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                attendeeCount > 0
                                    ? '$attendeeCount student${attendeeCount == 1 ? '' : 's'} attending'
                                    : 'Be the first to register!',
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildDetailBox(
                        Icons.calendar_month_rounded,
                        date,
                        context,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailBox(
                        Icons.location_on_rounded,
                        location,
                        context,
                      ),

                      if (link.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _launchExternalLink(link, context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: neonEmerald.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: neonEmerald.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  color: neonEmerald,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Official Registration Form',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  color: neonEmerald,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      const Text(
                        'About this Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        description.isEmpty
                            ? 'No additional details provided by the host.'
                            : description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
