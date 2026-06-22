import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iiitk_events/providers/authentication.dart';
import 'package:provider/provider.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAuth = context.watch<Authentication>();
    return Hero(
      curve: Curves.decelerate,
      tag: 'profile',
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: userAuth.profilePhotoUrl != ''
            ? CachedNetworkImage(
                fit: .contain,
                imageUrl: context.read<Authentication>().profilePhotoUrl,
              )
            : const Icon(Icons.person, size: 50, color: Colors.white),
      ),
    );
  }
}
