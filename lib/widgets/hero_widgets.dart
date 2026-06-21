import 'package:flutter/material.dart';
import 'package:iiitk_events/providers/authentication.dart';
import 'package:provider/provider.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      curve: Curves.decelerate,
      tag: 'profile',
      child: Image.network(
        fit: .contain,
        context.read<Authentication>().profilePhotoUrl,
      ),
    );
  }
}
