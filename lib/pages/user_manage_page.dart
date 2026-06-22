// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:iiitk_events/pages/manage_posts_page.dart';
import 'package:iiitk_events/pages/saved_events_page.dart';
import 'package:iiitk_events/providers/authentication.dart';
import 'package:iiitk_events/widgets/dev_credit_card.dart';
import 'package:iiitk_events/widgets/hero_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserManagePage extends StatefulWidget {
  const UserManagePage({super.key});

  @override
  State<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await messaging.subscribeToTopic('all_events');
        await prefs.setBool('notifications_enabled', true);
        setState(() => _notificationsEnabled = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Push notifications enabled!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permissions were denied.'),
            ),
          );
        }
        setState(() => _notificationsEnabled = false);
      }
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('all_events');
      await prefs.setBool('notifications_enabled', false);
      setState(() => _notificationsEnabled = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Push notifications disabled.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAuth = context.watch<Authentication>();

    Widget buildSettingsGroup(List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          color: const Color(0xFF0A0A0A),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF222222), width: 1),
          ),
          child: Column(children: children),
        ),
      );
    }

    Widget buildSectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.only(left: 32, top: 16, bottom: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      );
    }

    const subtleDivider = Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFF1A1A1A),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    ProfileHero(),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        'IIITK Student',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // PROFILE SECTION
                buildSectionHeader('PROFILE'),
                buildSettingsGroup([
                  ListTile(
                    leading: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                    ),
                    title: Text(
                      userAuth.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Tap to change display name',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onTap: () {
                      final cont = TextEditingController(
                        text: userAuth.displayName,
                      );
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFF121212),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: Color(0xFF333333),
                                width: 1,
                              ),
                            ),
                            title: const Text(
                              'Edit display name',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: TextField(
                              controller: cont,
                              style: const TextStyle(color: Colors.white),
                              cursorColor: theme.colorScheme.primary,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF0A0A0A),
                                hintText: 'Enter new name',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF333333),
                                  ),
                                ),
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
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white54,
                                ),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  if (cont.text.trim().isNotEmpty) {
                                    context
                                        .read<Authentication>()
                                        .updateDisplayName(cont.text);
                                    Navigator.pop(context);
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ]),

                // ACCOUNT SECTION
                buildSectionHeader('ACCOUNT'),
                buildSettingsGroup([
                  ListTile(
                    leading: const Icon(
                      Icons.bookmark_rounded,
                      color: Colors.blueAccent,
                    ),
                    title: const Text(
                      'Saved Events',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white24,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedEventsPage(),
                        ),
                      );
                    },
                  ),
                  subtleDivider,
                  ListTile(
                    leading: const Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFF00FF66),
                    ),
                    title: const Text(
                      'Manage My Posts',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white24,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManagePostsPage(),
                        ),
                      );
                    },
                  ),
                ]),

                // PREFERENCES SECTION
                buildSectionHeader('PREFERENCES'),
                buildSettingsGroup([
                  SwitchListTile(
                    activeThumbColor: Colors.black,
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveThumbColor: Colors.white54,
                    inactiveTrackColor: const Color(0xFF1A1A1A),
                    secondary: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.orangeAccent,
                    ),
                    title: const Text(
                      'Push Notifications',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                ]),

                // APP INFO SECTION
                buildSectionHeader('SUPPORT'),
                buildSettingsGroup([
                  ListTile(
                    leading: const Icon(
                      Icons.bug_report_rounded,
                      color: Colors.white54,
                    ),
                    title: const Text(
                      'Report an Issue',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.open_in_new_rounded,
                      color: Colors.white24,
                      size: 18,
                    ),
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'karegoudracm@gmail.com',
                        query: 'subject=IIITK Events App Bug Report',
                      );

                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not open the default email app.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ]),

                buildSectionHeader('ABOUT THE DEV'),
                const SizedBox(height: 12),

                const DevCreditCard(),

                const SizedBox(height: 32),

                // LOGOUT BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await context
                              .read<Authentication>()
                              .googleLogoutFunc();
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to logout at the moment'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        backgroundColor: Colors.redAccent.withValues(
                          alpha: 0.05,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
