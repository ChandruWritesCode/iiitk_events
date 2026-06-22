import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iiitk_events/pages/create_event_form_page.dart';
import 'package:iiitk_events/pages/event_details_page.dart';
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
    'Cultural',
    'Sports',
    'Other',
  ];
  int _selectedFilter = 0;
  bool _isFabExtended = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<QuerySnapshot>? _eventsFuture;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    Query query = FirebaseFirestore.instance.collection('events');

    if (_filters[_selectedFilter].toLowerCase() != 'all') {
      query = query.where('category', isEqualTo: _filters[_selectedFilter]);
    }

    final future = query.orderBy('eventDate').get();
    setState(() {
      _eventsFuture = future;
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<Authentication>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.reverse) {
              if (_isFabExtended) {
                setState(() => _isFabExtended = false);
              }
            } else if (notification.direction == ScrollDirection.forward) {
              if (!_isFabExtended) {
                setState(() => _isFabExtended = true);
              }
            }
            return true;
          },
          child: RefreshIndicator(
            color: theme.colorScheme.primary,
            backgroundColor: const Color(0xFF121212),
            onRefresh: _fetchEvents,
            child: CustomScrollView(
              slivers: [
                SliverAppBar.medium(
                  backgroundColor: Colors.black,
                  pinned: true,
                  leadingWidth: 64,
                  leading: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      top: 8.0,
                      bottom: 8.0,
                      right: 8,
                    ),
                    child: Image.asset('assets/logo/IIITKEventsLogo.png'),
                  ),
                  titleSpacing: 0,
                  title: Text(
                    'Hello, ${user.displayName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserManagePage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 38,
                          width: 38,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF333333),
                              width: 1,
                            ),
                          ),
                          child: user.profilePhotoUrl != ''
                              ? const ProfileHero()
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      height: 48, // Slightly taller for a premium feel
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        cursorColor: theme.colorScheme.primary,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF121212),
                          hintText: 'Search events, clubs...',
                          hintStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Colors.white54,
                            size: 22,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    FocusScope.of(
                                      context,
                                    ).unfocus();
                                  },
                                  child: const Icon(
                                    Icons.cancel_rounded,
                                    color: Colors.white54,
                                    size: 18,
                                  ),
                                )
                              : null,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              24,
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFF333333),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                            selectedColor: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
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
                              if (value) {
                                setState(() {
                                  _selectedFilter = idx;
                                });
                                _fetchEvents();
                              }
                            },
                            selected: _selectedFilter == idx,
                            label: Text(_filters[idx]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                FutureBuilder<QuerySnapshot>(
                  future: _eventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'Error loading events.',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      );
                    }

                    final allDocs = snapshot.data?.docs ?? [];
                    final now = DateTime.now();
                    final startOfToday = DateTime(now.year, now.month, now.day);

                    final docs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title = (data['title'] ?? '')
                          .toString()
                          .toLowerCase();
                      final host = (data['host'] ?? '')
                          .toString()
                          .toLowerCase();

                      // 1. DATE CHECK
                      bool isUpcoming = false;
                      if (data['eventDate'] != null) {
                        DateTime eventDate = (data['eventDate'] as Timestamp)
                            .toDate();
                        isUpcoming =
                            eventDate.isAfter(startOfToday) ||
                            eventDate.isAtSameMomentAs(startOfToday);
                      }

                      // 2. SEARCH CHECK
                      bool matchesSearch =
                          title.contains(_searchQuery) ||
                          host.contains(_searchQuery);

                      return matchesSearch && isUpcoming;
                    }).toList();

                    if (docs.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'No results found for "$_searchQuery"'
                                : 'No upcoming events\nenjoy your time!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.all(10.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;

                          String dateString = 'TBA';
                          if (data['eventDate'] != null) {
                            DateTime date = (data['eventDate'] as Timestamp)
                                .toDate();
                            dateString =
                                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                          }

                          return EventCard(
                            title: data['title'] ?? 'Untitled Event',
                            host: data['host'] ?? 'Unknown Club',
                            date: dateString,
                            location: data['venue'] ?? 'TBA',
                            imageUrl: data['imageUrl'] ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsPage(
                                    eventId: docs[index].id,
                                    title: data['title'] ?? 'Untitled',
                                    host: data['host'] ?? 'Unknown',
                                    date: dateString,
                                    location: data['venue'] ?? 'TBA',
                                    description: data['description'] ?? '',
                                    imageUrl: data['imageUrl'] ?? '',
                                    link: data['registrationLink'] ?? '',
                                  ),
                                ),
                              );
                            },
                          );
                        }, childCount: docs.length),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventPage()),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
                      overflow: TextOverflow.clip,
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
