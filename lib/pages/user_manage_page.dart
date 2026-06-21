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
                          return AlertDialog(
                            title: const Text(
                              'Edit your user name',
                              style: TextStyle(fontSize: 20),
                            ),
                            content: TextField(
                              controller: cont,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            actions: [
                              FilledButton(
                                onPressed: () {
                                  context
                                      .read<Authentication>()
                                      .updateDisplayName(cont.text);
                                  Navigator.pop(context);
                                },
                                child: Text('Submit'),
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
