// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:iiitk_events/providers/authentication.dart';
import 'package:iiitk_events/widgets/hero_widgets.dart';
import 'package:provider/provider.dart';

class UserManagePage extends StatelessWidget {
  const UserManagePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 100),
                  child: context.watch<Authentication>().profilePhotoUrl != ''
                      ? ProfileHero()
                      : null,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(context.watch<Authentication>().displayName),
                  trailing: IconButton(
                    onPressed: () {
                      final cont = TextEditingController();
                      cont.text = context.read<Authentication>().displayName;
                      showDialog(
                        context: context,
                        builder: (context) {
                          final theme = Theme.of(context);

                          return AlertDialog(
                            backgroundColor: const Color(
                              0xFF121212,
                            ), // AMOLED ultra-dark surface
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: Color(0xFF333333),
                                width: 1,
                              ), // Crisp, thin border
                            ),
                            title: const Text(
                              'Edit your user name',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: TextField(
                              controller: cont,
                              style: const TextStyle(
                                color: Colors.white,
                              ), // White typing text
                              cursorColor:
                                  theme.colorScheme.primary, // Neon cursor
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                  0xFF0A0A0A,
                                ), // Pitch black input background
                                hintText: 'Enter new name',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                                // Unfocused state (Grey outline)
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                // Focused state (Bright primary outline)
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            actions: [
                              // Added a subtle cancel button for better UX
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  // Prevent submitting an empty string
                                  if (cont.text.trim().isNotEmpty) {
                                    context
                                        .read<Authentication>()
                                        .updateDisplayName(cont.text);
                                    Navigator.pop(context);
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme
                                      .colorScheme
                                      .primary, // Bright accent background
                                  foregroundColor:
                                      Colors.black, // High-contrast dark text
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.edit),
                  ),
                ),

                SizedBox(height: 800),

                //logout button
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        await context.read<Authentication>().googleLogoutFunc();

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to login at the moment'),
                          ),
                        );
                      }
                    },
                    child: Text('Log out'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
