import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/presentation/views/feed_view.dart';
import '../../../flashcards/presentation/views/flashcards_view.dart';
import '../../../flashcards/data/flashcards_repository.dart';
import '../../../profile/presentation/views/profile_view.dart';

class MainNavigationView extends ConsumerStatefulWidget {
  const MainNavigationView({super.key});

  @override
  ConsumerState<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends ConsumerState<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FeedView(),
    FlashcardsView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isProfile = _currentIndex == 2;
    final backgroundColor = isProfile ? Colors.white : Colors.black;
    final contentColor = isProfile ? Colors.black : Colors.white;
    final unselectedColor = isProfile ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isProfile ? Colors.black12 : Colors.white12;
    final hasVirtualHomeButton = MediaQuery.of(context).padding.bottom > 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: hasVirtualHomeButton ? 15 : 0,
                top: 5,
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                backgroundColor: backgroundColor,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: contentColor,
                unselectedItemColor: unselectedColor,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                elevation: 0,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_filled),
                    label: 'Feed',
                  ),
                  BottomNavigationBarItem(
                    icon: Consumer(
                      builder: (context, ref, child) {
                        final dueCountAsync = ref.watch(
                          flashcardsDueCountProvider,
                        );
                        final dueCount = dueCountAsync.maybeWhen(
                          data: (value) => value,
                          orElse: () => 0,
                        );
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.style_outlined),
                            if (dueCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$dueCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    activeIcon: const Icon(Icons.style),
                    label: 'Flashcards',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
