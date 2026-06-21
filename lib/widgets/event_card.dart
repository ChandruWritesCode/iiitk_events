import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String host;
  final String date;
  final String location;
  final String? imageUrl;

  const EventCard({
    super.key,
    required this.title,
    required this.host,
    required this.date,
    required this.location,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using an InkWell makes the entire compact card tappable with a nice ripple effect
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // Navigate to details page later
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A), // Subtle dark container
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF222222),
              width: 1,
            ), // Crisp outline
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Thumbnail Image (Left)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  // Placeholder for NetworkImage later
                  // image: imageUrl != null && imageUrl!.isNotEmpty
                  //     ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                  //     : null,
                ),
                child: imageUrl == null || imageUrl!.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image_rounded,
                          color: Colors.white24,
                          size: 32,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // 2. Event Details (Middle/Right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Host / Category Badge (Primary Bright Accent)
                    Text(
                      host.toUpperCase(),
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .primary, // This provides the bright accent
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Event Title
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Metadata Row
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Action Indicator (Far Right)
              Padding(
                padding: const EdgeInsets.only(top: 24.0, left: 8.0),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
