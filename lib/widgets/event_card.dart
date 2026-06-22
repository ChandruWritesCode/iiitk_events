import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String host;
  final String date;
  final String location;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const EventCard({
    super.key,
    required this.title,
    required this.host,
    required this.date,
    required this.location,
    this.imageUrl,
    this.onTap,
    this.onEdit,
  });

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: const Color(0xFF0A0A0A), 
      child: const Center(
        child: Icon(Icons.image_rounded, size: 48, color: Color(0xFF333333)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        color: const Color(0xFF121212), 
        clipBehavior:
            Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // IMAGE AREA
              SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (imageUrl != null && imageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            // loadingBuilder: (context, child, loadingProgress) {}
                            // errorBuilder: (context, error, stackTrace) =>
                            //     _buildPlaceholder(theme),
                          )
                        : _buildPlaceholder(theme),

                    if (onEdit != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: onEdit,
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // THE EVENT DETAILS
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      host.toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            date,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
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
            ],
          ),
        ),
      ),
    );
  }
}
