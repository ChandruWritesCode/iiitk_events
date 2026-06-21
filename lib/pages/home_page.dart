import 'package:flutter/material.dart';
import 'package:iiitk_events/pages/user_manage_page.dart';
import 'package:iiitk_events/providers/authentication.dart';
import 'package:iiitk_events/widgets/hero_widgets.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final List<String> filters = [
    'All',
    'Technical',
    "Cultural",
    'Sports',
    'new',
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<Authentication>();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              'Hello, ${user.displayName}',
              softWrap: true,
              maxLines: 2,
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserManagePage()),
                  );
                },
                child: Container(
                  clipBehavior: .antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: context.watch<Authentication>().profilePhotoUrl != ''
                      ? ProfileHero()
                      : null,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (context, idx) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Chip(label: Text(filters[idx])),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([SizedBox(height: 800)]),
          ),
        ],
      ),
    );
  }
}
