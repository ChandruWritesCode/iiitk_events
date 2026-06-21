import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iiitk_events/pages/create_event_form_page.dart';
import 'package:iiitk_events/pages/user_manage_page.dart';
import 'package:iiitk_events/providers/authentication.dart';
import 'package:iiitk_events/widgets/event_card.dart';
import 'package:iiitk_events/widgets/hero_widgets.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _filters = [
    'All',
    'Technical',
    "Cultural",
    'Sports',
    'new',
  ];
  int _selectedFilter = 0;
  bool _isFabExtended = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<Authentication>();
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isFabExtended) {
              setState(() {
                _isFabExtended = false;
              });
            }
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isFabExtended) {
              setState(() {
                _isFabExtended = true;
              });
            }
          }

          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              // snap: true,
              leadingWidth: 80,
              leading: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                height: 80,
                width: 80,
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: theme.colorScheme.primary,
                //     width: 1.5,
                //   ),
                //   borderRadius: BorderRadius.circular(20),
                // ),
                child: Icon(
                  Icons.terminal_rounded, // Coding/Tech aesthetic
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              pinned: true,
              title: Text(
                'Hello, ${user.displayName}',
                softWrap: true,
                maxLines: 2,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
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
                      child:
                          context.watch<Authentication>().profilePhotoUrl != ''
                          ? ProfileHero()
                          : Icon(Icons.person),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, idx) {
                    bool isSelected = _selectedFilter == idx;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        backgroundColor: const Color(0xFF121212),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : const Color(0xFF333333),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.white70,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedFilter = idx;
                              // TODO here goes filtering logic
                            }
                          });
                        },
                        selected: _selectedFilter == idx,
                        label: Text(_filters[idx]),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Replace your current SliverList block with this:
            SliverPadding(
              padding: const EdgeInsets.all(10.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return EventCard(
                    title: 'Intro to Data Structures & Algorithms',
                    host: 'Coding Club',
                    date: 'Tomorrow, 5:00 PM',
                    location: 'Lab 3',
                    imageUrl: 'placeholder',
                  );
                }, childCount: 6),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventPage()),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.decelerate,
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: _isFabExtended ? 20 : 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(_isFabExtended ? 16 : 28),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.black, size: 26),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuart,
                child: SizedBox(
                  width: _isFabExtended ? null : 0,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Post Event',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow
                          .clip,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
