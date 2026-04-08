import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'models/sporting_event.dart';
import 'data/events_data.dart';
import 'data/roster_data.dart';

void main() {
  ui_web.platformViewRegistry.registerViewFactory(
    'campus-map-iframe',
    (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = 'https://maps.google.com/maps?q=Washington+and+Lee+University+Athletics+Lexington+VA&t=k&z=17&ie=UTF8&iwloc=&output=embed'
        ..allowFullscreen = true;
      iframe.style
        ..border = 'none'
        ..width = '100%'
        ..height = '100%';
      return iframe;
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gennie Live',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF000399),
          primary: const Color(0xFF000399),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000399),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      builder: (context, child) {
        return Container(
          color: const Color(0xFF1A1A2E),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: child!,
            ),
          ),
        );
      },
      home: const MainScaffold(),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN SCAFFOLD — bottom nav shell
// ─────────────────────────────────────────────
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomePage(),
          SchedulePage(),
          ResultsPage(),
          WorkoutClassesPage(showBackButton: false),
          _MoreMenuPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: const Color(0xFF000399),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
        unselectedLabelStyle: const TextStyle(letterSpacing: 1.0),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'SCHEDULE'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'RESULTS'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'GROUPEX'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'MORE'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nextEvents = EventsData.getUpcomingEvents().take(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── Hero banner ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF000399),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 50),
              centerTitle: true,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://dxbhsrqyrr690.cloudfront.net/sidearm.nextgen.sites/generalssports.com/images/logos/site/site.png',
                      height: 36,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'GENNIE LIVE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      'Washington & Lee University Athletics',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0005CC), Color(0xFF000399)],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // ── Featured hero story ──
          const SliverToBoxAdapter(child: _HeroNewsCard()),

          // ── News grid ──
          const SliverToBoxAdapter(child: _NewsGrid()),

          // ── Next Up section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nextEvents.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 12),
                      child: Text(
                        'NEXT UP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...nextEvents.map((e) => _UpcomingEventTile(event: e)),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Game day notifications signup ──
          const SliverToBoxAdapter(child: _EmailSignupSection()),
        ],
      ),
    );
  }
}

// ── Photo gallery section ──
class _PhotoGallerySection extends StatelessWidget {
  const _PhotoGallerySection();

  static const List<Map<String, String>> _photos = [
    {'asset': 'assets/images/baseball.webp',        'label': 'Baseball'},
    {'asset': 'assets/images/swimming.webp',        'label': 'Swimming'},
    {'asset': 'assets/images/mens_lacrosse.webp',   'label': "Men's Lacrosse"},
    {'asset': 'assets/images/womens_lacrosse.png',  'label': "Women's Lacrosse"},
    {'asset': 'assets/images/wrestling.webp',       'label': 'Wrestling'},
    {'asset': 'assets/images/volleyball.webp',      'label': 'Volleyball'},
    {'asset': 'assets/images/field_hockey.webp',    'label': 'Field Hockey'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 28, bottom: 12),
          child: Text(
            'GENERALS ATHLETICS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final photo = _photos[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.asset(
                      photo['asset']!,
                      width: 200,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 200,
                        height: 160,
                        color: const Color(0xFF000399).withValues(alpha: 0.1),
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          photo['label']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


// ── News / Highlights data ──
class _NewsItem {
  final String headline;
  final String sport;
  final String sportTag;
  final String timeAgo;
  final String asset;
  final Color tagColor;
  final String url;

  const _NewsItem({
    required this.headline,
    required this.sport,
    required this.sportTag,
    required this.timeAgo,
    required this.asset,
    required this.tagColor,
    required this.url,
  });
}

const List<_NewsItem> _newsItems = [
  _NewsItem(
    headline: 'Gartley Breaks 38-Year-Old Record on Final Day of Colonial Relays',
    sport: "Men's Track & Field",
    sportTag: 'MTF',
    timeAgo: '2 days ago',
    asset: 'assets/images/generals_logo.png',
    tagColor: Color(0xFF4A148C),
    url: 'https://generalssports.com/news/2026/4/4/mens-track-and-field-gartley-breaks-38-year-old-record-on-final-day-of-colonial-relays.aspx',
  ),
  _NewsItem(
    headline: 'Late Innings Production Powers Baseball to Doubleheader Split at Roanoke',
    sport: 'Baseball',
    sportTag: 'BASE',
    timeAgo: '2 days ago',
    asset: 'assets/images/baseball.webp',
    tagColor: Color(0xFF1B5E20),
    url: 'https://generalssports.com/news/2026/4/4/late-innings-production-powers-baseball-to-doubleheader-split-at-roanoke.aspx',
  ),
  _NewsItem(
    headline: 'Lorenz Breaks 100 Wins, No. 12 W&L Celebrates Seniors in Sweep of Hollins',
    sport: "Women's Tennis",
    sportTag: 'WTEN',
    timeAgo: '2 days ago',
    asset: 'assets/images/generals_logo.png',
    tagColor: Color(0xFF880E4F),
    url: 'https://generalssports.com/news/2026/4/4/womens-tennis-lorenz-breaks-100-wins-no-12-w-l-celebrates-seniors-in-sweep-of-hollins.aspx',
  ),
  _NewsItem(
    headline: 'No. 45 Generals Cruise Past Hampden-Sydney on the Road',
    sport: "Men's Tennis",
    sportTag: 'MTEN',
    timeAgo: '2 days ago',
    asset: 'assets/images/generals_logo.png',
    tagColor: Color(0xFF01579B),
    url: 'https://generalssports.com/news/2026/4/4/mens-tennis-no-45-generals-cruise-past-hampden-sydney-on-the-road.aspx',
  ),
  _NewsItem(
    headline: 'Big First Half Keys No. 19 W&L to Pivotal Win Over H-SC',
    sport: "Men's Lacrosse",
    sportTag: 'MLAX',
    timeAgo: '2 days ago',
    asset: 'assets/images/mens_lacrosse.webp',
    tagColor: Color(0xFF283593),
    url: 'https://generalssports.com/news/2026/4/4/mens-lacrosse-big-first-half-keys-no-19-w-l-to-pivotal-win-over-h-sc.aspx',
  ),
  _NewsItem(
    headline: 'Four Hat Tricks Power No. 6 Women\'s Lacrosse Past Roanoke, 15-5',
    sport: "Women's Lacrosse",
    sportTag: 'WLAX',
    timeAgo: '4 days ago',
    asset: 'assets/images/womens_lacrosse.png',
    tagColor: Color(0xFF1565C0),
    url: 'https://generalssports.com/news/2026/4/2/four-hat-tricks-power-no-6-womens-lacrosse-past-roanoke-15-5.aspx',
  ),
];

// ── Hero featured story ──
class _EmailSignupSection extends StatefulWidget {
  const _EmailSignupSection();

  @override
  State<_EmailSignupSection> createState() => _EmailSignupSectionState();
}

class _EmailSignupSectionState extends State<_EmailSignupSection> {
  final _controller = TextEditingController();
  bool _submitted = false;
  String _error = '';

  Future<void> _submit() async {
    final email = _controller.text.trim();
    final valid = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(email);
    if (!valid) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    // Submit silently to Google Form — responses saved to linked Google Sheet
    final url =
        'https://docs.google.com/forms/d/e/1FAIpQLSfktBG7XythS-ADb2qiIaxBnfIR8I1pcxdzQ3rdGG1Xe9jYVg/formResponse?entry.867871500=${Uri.encodeComponent(email)}';
    try {
      web.window.fetch(url.toJS);
    } catch (_) {}
    setState(() {
      _submitted = true;
      _error = '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF000399),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _submitted
          ? const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 36),
                SizedBox(height: 10),
                Text(
                  "You're signed up!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "We'll notify you on game days.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'GAME DAY NOTIFICATIONS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get notified when the Generals play.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _error.isEmpty ? null : _error,
                    errorStyle: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF000399),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _HeroNewsCard extends StatelessWidget {
  const _HeroNewsCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://generalssports.com/news/2026/4/4/womens-lacrosse-no-6-washington-and-lee-cruises-past-bridgewater-19-3.aspx'),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      ),
      child: Stack(
        children: [
          // Photo
          SizedBox(
            width: double.infinity,
            height: 220,
            child: Image.asset(
              'assets/images/womens_lacrosse.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: const Color(0xFF000399),
              ),
            ),
          ),
          // Dark gradient overlay
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          // Text overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ODAC WIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'WIN 19-3',
                    style: TextStyle(
                      color: Color(0xFF6699FF),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'NO. 6 WOMEN\'S LACROSSE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Headline + sport tag below the hero
class _HeroNewsCaption extends StatelessWidget {
  const _HeroNewsCaption();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No. 6 Washington and Lee Cruises Past Bridgewater, 19-3',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.sports_hockey, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'WLAX  •  2 days ago',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// ── News grid (2-column) ──
class _NewsGrid extends StatelessWidget {
  const _NewsGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroNewsCaption(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _newsItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, i) => _NewsCard(item: _newsItems[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final _NewsItem item;
  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(item.url),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Photo
            Positioned.fill(
              child: Image.asset(
                item.asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: item.tagColor,
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ),
                ),
              ),
            ),
            // Text
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.headline,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          _sportIcon(item.sport),
                          size: 11,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${item.sportTag}  •  ${item.timeAgo}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable nav card ──
class _NavCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small upcoming event preview tile ──
class _UpcomingEventTile extends StatelessWidget {
  final SportingEvent event;
  const _UpcomingEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF000399),
          child: Icon(_sportIcon(event.sport), color: Colors.white, size: 18),
        ),
        title: Text(
          '${event.sport} ${event.homeAwayText} ${event.opponent}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text('${event.formattedDate} • ${event.formattedTime}'),
        trailing: Chip(
          label: Text(
            event.isHome ? 'Home' : 'Away',
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: event.isHome
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFFFEBEE),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SCHEDULE PAGE (tab 2)
// ─────────────────────────────────────────────
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late DateTime _selectedDate;
  late DateTime _weekStart;
  late DateTime _displayedMonth;
  bool _isMonthView = false;

  static const _dayAbbrevs = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = [
    '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    // Start week on Sunday (weekday 7 = Sunday in Dart → % 7 = 0)
    final dayOfWeek = now.weekday % 7;
    _weekStart = _selectedDate.subtract(Duration(days: dayOfWeek));
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  bool _hasEventsOn(DateTime date) {
    return EventsData.getAllEvents().any((e) =>
        e.dateTime.year == date.year &&
        e.dateTime.month == date.month &&
        e.dateTime.day == date.day);
  }

  List<SportingEvent> get _filteredEvents {
    return EventsData.getAllEvents().where((e) =>
        e.dateTime.year == _selectedDate.year &&
        e.dateTime.month == _selectedDate.month &&
        e.dateTime.day == _selectedDate.day).toList();
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  List<DateTime?> get _monthCells {
    final firstWeekday = _displayedMonth.weekday % 7; // 0 = Sunday
    final days = _daysInMonth(_displayedMonth.year, _displayedMonth.month);
    final cells = <DateTime?>[];
    for (int i = 0; i < firstWeekday; i++) cells.add(null);
    for (int d = 1; d <= days; d++) {
      cells.add(DateTime(_displayedMonth.year, _displayedMonth.month, d));
    }
    while (cells.length % 7 != 0) cells.add(null);
    return cells;
  }

  Widget _buildMonthGrid() {
    final cells = _monthCells;
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final week = cells.sublist(i, i + 7);
      rows.add(Row(
        children: week.map((date) {
          if (date == null) return const Expanded(child: SizedBox(height: 44));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          final hasEvents = _hasEventsOn(date);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF000399) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasEvents
                            ? (isSelected ? const Color(0xFF000399) : Colors.white)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ));
    }
    return Column(children: rows);
  }

  Widget _toggleBtn(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF000399) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;
    final Map<String, List<SportingEvent>> grouped = {};
    for (final e in events) {
      grouped.putIfAbsent(e.formattedDate, () => []).add(e);
    }
    final dates = grouped.keys.toList();

    final headerMonth = _isMonthView
        ? '${_monthNames[_displayedMonth.month]} ${_displayedMonth.year}'
        : _monthNames[_weekDays[3].month];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final dayOfWeek = today.weekday % 7;
          setState(() {
            _selectedDate = today;
            _weekStart = today.subtract(Duration(days: dayOfWeek));
            _displayedMonth = DateTime(today.year, today.month, 1);
          });
        },
        backgroundColor: const Color(0xFF000399),
        label: const Text(
          'TODAY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        icon: const Icon(Icons.today, color: Colors.white),
      ),
      body: Column(
        children: [
          // ── Blue calendar header ──
          Container(
            color: const Color(0xFF000399),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Title + nav arrows
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: () => setState(() {
                            if (_isMonthView) {
                              _displayedMonth = DateTime(
                                  _displayedMonth.year, _displayedMonth.month - 1, 1);
                            } else {
                              _weekStart = _weekStart.subtract(const Duration(days: 7));
                            }
                          }),
                        ),
                        Column(
                          children: [
                            Text(
                              headerMonth,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'SCHEDULE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white38),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _toggleBtn('WEEK', !_isMonthView,
                                          () => setState(() => _isMonthView = false)),
                                      _toggleBtn('MONTH', _isMonthView,
                                          () => setState(() {
                                                _isMonthView = true;
                                                _displayedMonth = DateTime(
                                                    _selectedDate.year, _selectedDate.month, 1);
                                              })),
                                    ],
                                  ),
                                ),
                                  ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: () => setState(() {
                            if (_isMonthView) {
                              _displayedMonth = DateTime(
                                  _displayedMonth.year, _displayedMonth.month + 1, 1);
                            } else {
                              _weekStart = _weekStart.add(const Duration(days: 7));
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Day-of-week abbreviations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: _dayAbbrevs
                          .map((d) => Expanded(
                                child: Center(
                                  child: Text(
                                    d,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  // Date cells — week strip or full month grid
                  if (_isMonthView)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                      child: _buildMonthGrid(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                      child: Row(
                        children: _weekDays.map((date) {
                          final isSelected = date.day == _selectedDate.day &&
                              date.month == _selectedDate.month &&
                              date.year == _selectedDate.year;
                          final hasEvents = _hasEventsOn(date);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedDate = date),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF000399)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: hasEvents
                                            ? (isSelected
                                                ? const Color(0xFF000399)
                                                : Colors.white)
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Date banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: const Color(0xFF00024A),
            child: Text(
              '${_monthNames[_selectedDate.month]} ${_selectedDate.day}, ${_selectedDate.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Event list ──
          Expanded(
            child: dates.isEmpty
                ? const Center(
                    child: Text(
                      'No events scheduled for this day.',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    itemCount: dates.length,
                    itemBuilder: (context, di) {
                      final date = dates[di];
                      final dayEvents = grouped[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            color: const Color(0xFFF5F5F5),
                            child: Text(
                              date.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          ...dayEvents.map((e) => _ScheduleEventTile(event: e)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleEventTile extends StatelessWidget {
  final SportingEvent event;
  const _ScheduleEventTile({required this.event});

  static const String _livestreamUrl =
      'https://go.flocollege.com/partner/odac?utm_medium=partner&utm_source=multiple&utm_content=landingpage&utm_term=washington-and-lee-university&contract_id=0063m00000n3zlfaam';

  /// Returns a proper street address for Google Maps based on the event location string.
  String get _mapsAddress {
    final loc = event.location;
    final opp = event.opponent;

    // ── W&L Home venues ──
    if (loc.contains('Wilson Field'))                        return '100 Stadium Spur, Lexington, VA 24450';
    if (loc.contains('Holekamp'))                            return '100 Warner Drive, Lexington, VA 24450';
    if (loc.contains('Natatorium') || loc.contains('W&L')) return '100 Warner Drive, Lexington, VA 24450';
    if (loc.contains('Dick Smith') || loc.contains("Cap'n Dick") || loc.contains('Cap\'n Dick')) return '100 Stadium Spur, Lexington, VA 24450';
    if (loc.contains('Alston Parker') || loc.contains('Watt Field'))  return 'Alston Parker Watt Field, Washington and Lee University, Lexington, VA 24450';
    if (loc.contains('Duchossois') || loc.contains('Warner Center'))  return '100 Warner Drive, Lexington, VA 24450';
    if (loc.contains('Lexington'))                           return '204 W Washington St, Lexington, VA 24450';

    // ── Away venues by city/location string ──
    if (loc.contains('Ashland'))       return '204 Henry St, Ashland, VA 23005';           // Randolph-Macon
    if (loc.contains('Hampden-Sydney') || loc.contains('Hampden Sydney')) return '80 College Road, Hampden Sydney, VA 23943';
    if (loc.contains('Danville'))      return '707 Mount Cross Road, Danville, VA 24540';  // Averett
    if (loc.contains('Winchester'))    return '1188 Ralph Shockey Dr, Winchester, VA 22601'; // Shenandoah
    if (loc.contains('Williamsport'))  return '700 College Place, Williamsport, PA 17701'; // Lycoming
    if (loc.contains('Fredericksburg'))return '1301 College Avenue, Fredericksburg, VA 22401'; // UMW
    if (loc.contains('Harrisonburg')) {
      // Disambiguate: EMU vs JMU
      if (opp.contains('Eastern Mennonite') || opp.contains('EMU')) return '1200 Park Road, Harrisonburg, VA 22802';
      return '895 University Blvd, Harrisonburg, VA 22807'; // JMU default
    }
    if (loc.contains('Staunton'))      return '128 Tams Street, Staunton, VA 24401';       // Mary Baldwin
    if (loc.contains('Carlisle'))      return '272 West High Street, Carlisle, PA 17013';  // Dickinson
    if (loc.contains('Meadville'))     return '520 North Main Street, Meadville, PA 16335'; // Allegheny
    if (loc.contains('Virginia Beach'))return '5817 Wesleyan Drive, Virginia Beach, VA 23502'; // Virginia Wesleyan
    if (loc.contains('Lynchburg'))     return '1501 Lakeside Drive, Lynchburg, VA 24501';  // U of Lynchburg
    if (loc.contains('York'))          return '899 South Richland Avenue, York, PA 17403'; // York College
    if (loc.contains('Newport News'))  return '1 University Place, Newport News, VA 23606'; // CNU
    if (loc.contains('Gettysburg'))    return '300 North Washington Street, Gettysburg, PA 17325';
    if (loc.contains('Owings Mills'))  return '100 Campus Circle, Owings Mills, MD 21117'; // Stevenson
    if (loc.contains('Greensboro'))    return '5800 West Friendly Avenue, Greensboro, NC 27410'; // Guilford
    if (loc.contains('Bridgewater'))   return '402 East College Street, Bridgewater, VA 22812';
    if (loc.contains('Granville'))     return '100 West College Street, Granville, OH 43023'; // Denison
    if (loc.contains('Sparks') || loc.contains('Geneva')) return '210 St Clair Street, Geneva, NY 14456'; // William Smith
    if (loc.contains('Berea'))         return '275 Eastland Road, Berea, OH 44017';        // Baldwin Wallace
    if (loc.contains('Arlington'))     return '2807 North Glebe Road, Arlington, VA 22207'; // Marymount
    if (loc.contains('Salem'))         return '221 College Lane, Salem, VA 24153';          // Roanoke College
    if (loc.contains('Salisbury'))     return '1101 Camden Avenue, Salisbury, MD 21801';
    if (loc.contains('Lancaster'))     return '933 Harrisburg Avenue, Lancaster, PA 17603'; // F&M
    if (loc.contains('Buena Vista'))   return '1 University Hill Drive, Buena Vista, VA 24416'; // SVU
    if (loc.contains('Asheboro') || loc.contains('McCrary')) return '138 Southway Road, Asheboro, NC 27205';
    if (loc.contains('Kannapolis'))    return '1 Cannon Baller Way, Kannapolis, NC 28081';
    if (loc.contains('Charlotte'))     return '1 Cannon Baller Way, Kannapolis, NC 28081';
    if (loc.contains('Grantham') || loc.contains('Mechanicsburg')) return '1 University Avenue, Mechanicsburg, PA 17055'; // Messiah
    if (loc.contains('Springfield'))   return '1291 N Yellow Springs St, Springfield, OH 45503'; // Wittenberg
    if (loc.contains('Daytona'))       return 'Ocean Center, 101 N Atlantic Ave, Daytona Beach, FL 32118';
    if (loc.contains('Pittsburgh'))    return '5000 Forbes Avenue, Pittsburgh, PA 15213';  // CMU
    if (loc.contains('Roanoke'))       return '7916 Williamson Road, Roanoke, VA 24020';   // Hollins

    return event.location; // fallback to whatever is stored
  }

  void _showEventDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sport + opponent header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF000399),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_sportIcon(event.sport), color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.sport.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Color(0xFF000399),
                        ),
                      ),
                      Text(
                        '${event.isHome ? 'vs' : '@'} ${event.opponent}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Date & time
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${event.formattedDate}  •  ${event.formattedTime}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Location / address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _mapsAddress,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Directions button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000399),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Get Directions', style: TextStyle(fontSize: 15)),
                onPressed: () {
                  final query = Uri.encodeComponent(_mapsAddress);
                  launchUrl(
                    Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Watch Live button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00024A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.play_circle_outline, size: 18),
                label: const Text('Watch Live', style: TextStyle(fontSize: 15)),
                onPressed: () => launchUrl(
                  Uri.parse(_livestreamUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showEventDetail(context),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Sport name row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Icon(_sportIcon(event.sport), size: 18, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      event.sport.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                ],
              ),
            ),
            // Opponent row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      event.isHome ? 'VS' : '@',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.opponent.toUpperCase(),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                  Text(
                    event.formattedTime,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WORKOUT CLASSES PAGE
// ─────────────────────────────────────────────
class WorkoutClassesPage extends StatefulWidget {
  final bool showBackButton;
  const WorkoutClassesPage({super.key, this.showBackButton = true});

  @override
  State<WorkoutClassesPage> createState() => _WorkoutClassesPageState();
}

class _WorkoutClassesPageState extends State<WorkoutClassesPage> {
  late DateTime _selectedDate;
  late DateTime _weekStart;
  late DateTime _displayedMonth;
  bool _isMonthView = false;

  static const _dayAbbrevs = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = [
    '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  static const List<Map<String, dynamic>> _schedule = [
    {
      'day': 'Sunday',
      'classes': [
        {'time': '1:00 – 4:00 PM', 'name': 'Open Swim', 'type': 'swim'},
      ],
    },
    {
      'day': 'Monday',
      'classes': [
        {'time': '6:00 – 8:00 AM', 'name': 'Open Swim', 'type': 'swim'},
        {'time': '7:00 AM', 'name': 'Yoga', 'type': 'fitness'},
        {'time': '12:00 PM', 'name': 'TRX', 'type': 'fitness'},
        {'time': '12:30 – 2:30 PM', 'name': 'Open Swim', 'type': 'swim'},
        {'time': '5:30 PM', 'name': 'Spin', 'type': 'fitness'},
        {'time': '7:30 – 9:30 PM', 'name': 'Open Swim', 'type': 'swim'},
      ],
    },
    {
      'day': 'Tuesday',
      'classes': [
        {'time': '6:00 – 8:00 AM', 'name': 'Open Swim', 'type': 'swim'},
        {'time': '7:00 AM', 'name': 'Yoga', 'type': 'fitness'},
        {'time': '11:00 AM – 1:00 PM', 'name': 'Open Swim', 'type': 'swim'},
        {'time': '12:00 PM', 'name': 'Open Dancing', 'type': 'fitness'},
        {'time': '5:30 PM', 'name': 'Pilates', 'type': 'fitness'},
        {'time': '6:30 – 9:30 PM', 'name': 'Open Swim', 'type': 'swim'},
      ],
    },
    {
      'day': 'Wednesday',
      'classes': [
        {'time': '6:00 – 8:00 AM', 'name': 'Open Swim', 'type': 'swim'},
        {'time': '7:00 AM', 'name': 'Yoga', 'type': 'fitness'},
        {'time': '12:00 PM', 'name': 'TRX', 'type': 'fitness'},
        {'time': '12:30 – 2:30 PM', 'name': 'Open Swim', 'type': 'swim'},
        {'time': '6:00 PM', 'name': 'Tone45', 'type': 'fitness'},
        {'time': '6:30 – 9:30 PM', 'name': 'Open Swim', 'type': 'swim'},
      ],
    },
    {
      'day': 'Thursday',
      'classes': [
        {'time': '6:00 – 8:00 AM', 'name': 'Open Swim', 'type': 'swim'},
        {'time': '7:00 AM', 'name': 'Yoga', 'type': 'fitness'},
        {'time': '11:00 AM – 1:00 PM', 'name': 'Open Swim', 'type': 'swim'},
        {'time': '12:00 PM', 'name': 'TRX', 'type': 'fitness'},
        {'time': '5:30 PM', 'name': 'Tone45', 'type': 'fitness'},
        {'time': '6:30 – 9:30 PM', 'name': 'Open Swim', 'type': 'swim'},
      ],
    },
    {
      'day': 'Friday',
      'classes': [
        {'time': '11:00 AM – 2:00 PM', 'name': 'Open Swim', 'type': 'swim'},
        {'time': '12:00 PM', 'name': 'TRX', 'type': 'fitness'},
        {'time': '5:30 PM', 'name': 'Spin', 'type': 'fitness'},
      ],
    },
    {
      'day': 'Saturday',
      'classes': [
        {'time': '10:00 AM', 'name': 'Spin', 'type': 'fitness'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    final dayOfWeek = now.weekday % 7;
    _weekStart = _selectedDate.subtract(Duration(days: dayOfWeek));
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  List<DateTime?> get _monthCells {
    final firstWeekday = _displayedMonth.weekday % 7;
    final days = _daysInMonth(_displayedMonth.year, _displayedMonth.month);
    final cells = <DateTime?>[];
    for (int i = 0; i < firstWeekday; i++) cells.add(null);
    for (int d = 1; d <= days; d++) {
      cells.add(DateTime(_displayedMonth.year, _displayedMonth.month, d));
    }
    while (cells.length % 7 != 0) cells.add(null);
    return cells;
  }

  Widget _buildMonthGrid() {
    final cells = _monthCells;
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final week = cells.sublist(i, i + 7);
      rows.add(Row(
        children: week.map((date) {
          if (date == null) return const Expanded(child: SizedBox(height: 44));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          final dayIndex = date.weekday % 7;
          final hasClasses = (_schedule[dayIndex]['classes'] as List).isNotEmpty;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF000399) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasClasses
                            ? (isSelected ? const Color(0xFF000399) : Colors.white)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ));
    }
    return Column(children: rows);
  }

  Widget _toggleBtn(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF000399) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _classesForSelected {
    final dayIndex = _selectedDate.weekday % 7;
    return _schedule[dayIndex]['classes'] as List<Map<String, dynamic>>;
  }

  String get _selectedDayName {
    return _schedule[_selectedDate.weekday % 7]['day'] as String;
  }

  @override
  Widget build(BuildContext context) {
    final classes = _classesForSelected;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final dayOfWeek = today.weekday % 7;
          setState(() {
            _selectedDate = today;
            _weekStart = today.subtract(Duration(days: dayOfWeek));
            _displayedMonth = DateTime(today.year, today.month, 1);
          });
        },
        backgroundColor: const Color(0xFF000399),
        label: const Text(
          'TODAY',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        icon: const Icon(Icons.today, color: Colors.white),
      ),
      body: Column(
        children: [
          // ── Blue calendar header ──
          Container(
            color: const Color(0xFF000399),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Title + nav arrows
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: () => setState(() {
                            if (_isMonthView) {
                              _displayedMonth = DateTime(
                                  _displayedMonth.year, _displayedMonth.month - 1, 1);
                            } else {
                              _weekStart = _weekStart.subtract(const Duration(days: 7));
                            }
                          }),
                        ),
                        Column(
                          children: [
                            Text(
                              _isMonthView
                                  ? '${_monthNames[_displayedMonth.month]} ${_displayedMonth.year}'
                                  : _monthNames[_weekDays[3].month],
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'GROUPEX',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white38),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _toggleBtn('WEEK', !_isMonthView,
                                      () => setState(() => _isMonthView = false)),
                                  _toggleBtn('MONTH', _isMonthView,
                                      () => setState(() {
                                            _isMonthView = true;
                                            _displayedMonth = DateTime(
                                                _selectedDate.year, _selectedDate.month, 1);
                                          })),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: () => setState(() {
                            if (_isMonthView) {
                              _displayedMonth = DateTime(
                                  _displayedMonth.year, _displayedMonth.month + 1, 1);
                            } else {
                              _weekStart = _weekStart.add(const Duration(days: 7));
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Day-of-week abbreviations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: _dayAbbrevs
                          .map((d) => Expanded(
                                child: Center(
                                  child: Text(
                                    d,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  // Date cells — week strip or full month grid
                  if (_isMonthView)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                      child: _buildMonthGrid(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                      child: Row(
                        children: _weekDays.map((date) {
                          final isSelected = date.day == _selectedDate.day &&
                              date.month == _selectedDate.month &&
                              date.year == _selectedDate.year;
                          final dayIndex = date.weekday % 7;
                          final hasClasses =
                              (_schedule[dayIndex]['classes'] as List).isNotEmpty;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedDate = date),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF000399)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: hasClasses
                                            ? (isSelected
                                                ? const Color(0xFF000399)
                                                : Colors.white)
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Date banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: const Color(0xFF00024A),
            child: Text(
              '${_selectedDayName.toUpperCase()} • ${_monthNames[_selectedDate.month]} ${_selectedDate.day}, ${_selectedDate.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Classes list ──
          Expanded(
            child: classes.isEmpty
                ? const Center(
                    child: Text(
                      'No classes scheduled for this day.',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final cls = classes[index];
                      final isSwim = cls['type'] == 'swim';
                      final isOpenSwim = (cls['name'] as String).contains('Open Swim');
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(
                            isSwim ? Icons.pool : Icons.fitness_center,
                            color: isSwim ? Colors.blue[700] : const Color(0xFF000399),
                          ),
                          title: Text(
                            cls['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(cls['time'] as String),
                          trailing: isOpenSwim
                              ? null
                              : SizedBox(
                                  width: 72,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF000399),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 4),
                                      textStyle: const TextStyle(fontSize: 11),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _showClassSignUpDialog(
                                      context,
                                      cls['name'] as String,
                                      _selectedDayName,
                                      cls['time'] as String,
                                    ),
                                    child: const Text('Sign Up'),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showClassSignUpDialog(BuildContext context, String className, String day, String time) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Up — $className'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$day at $time', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'W&L Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000399),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Signed up for $className on $day at $time!'),
                  backgroundColor: const Color(0xFF000399),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FACILITY HOURS PAGE
// ─────────────────────────────────────────────
class FacilityHoursPage extends StatelessWidget {
  const FacilityHoursPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Hours'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _DuchossoisHoursCard(),
          _HoursCard(facility: 'Natatorium — Open Swim (Winter 2026)', hours: 'Sun: 1:00 – 4:00 PM\nMon: 6:00–8:00 AM, 12:30–2:30 PM, 7:30–9:30 PM\nTue: 6:00–8:00 AM, 11:00 AM–1:00 PM, 6:30–9:30 PM\nWed: 6:00–8:00 AM, 12:30–2:30 PM, 6:30–9:30 PM\nThu: 6:00–8:00 AM, 11:00 AM–1:00 PM, 6:30–9:30 PM\nFri: 11:00 AM – 2:00 PM\nSat: Closed'),
          _HoursCard(facility: 'Fitness Center', hours: 'Mon–Fri: 5:30 AM – 11:00 PM\nSat–Sun: 7:00 AM – 10:00 PM'),
          _HoursCard(facility: 'Outdoor Track', hours: 'Daily: 6:00 AM – 9:00 PM'),
          _HoursCard(facility: 'Wilson Field', hours: 'Daily: 6:00 AM – Dark'),
          _HoursCard(facility: 'Captain Dick Smith Baseball Field', hours: 'Daily: 6:00 AM – Dark'),
          _HoursCard(facility: 'Fuge Field', hours: 'Daily: Dawn – Dusk'),
        ],
      ),
    );
  }
}

class _HoursCard extends StatelessWidget {
  final String facility;
  final String hours;
  const _HoursCard({required this.facility, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF000399),
          child: Icon(Icons.access_time, color: Colors.white),
        ),
        title: Text(facility, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(hours),
      ),
    );
  }
}

class _DuchossoisHoursCard extends StatelessWidget {
  const _DuchossoisHoursCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF000399),
          child: Icon(Icons.access_time, color: Colors.white),
        ),
        title: const Text(
          'Richard L. Duchossois Athletic and Recreation Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Mon–Fri: 6:00 AM – 11:00 PM\nSat–Sun: 8:00 AM – 10:00 PM',
        ),
        trailing: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'click for\nbusy hours',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFF000399),
                fontStyle: FontStyle.italic,
              ),
            ),
            Icon(Icons.expand_more, size: 18, color: Colors.grey),
          ],
        ),
        children: const [
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _BusyHoursCard(),
          ),
        ],
      ),
    );
  }
}

class _BusyHoursCard extends StatelessWidget {
  const _BusyHoursCard();

  // (time label, busyness 0.0–1.0)
  static const List<(String, double)> _weekdaySlots = [
    ('6 AM',  0.10),
    ('8 AM',  0.20),
    ('10 AM', 0.40),
    ('12 PM', 0.85),
    ('2 PM',  0.50),
    ('4 PM',  0.72),
    ('6 PM',  0.95),
    ('8 PM',  0.42),
    ('10 PM', 0.15),
  ];

  static const List<(String, double)> _weekendSlots = [
    ('8 AM',  0.10),
    ('10 AM', 0.38),
    ('12 PM', 0.65),
    ('2 PM',  0.58),
    ('4 PM',  0.30),
    ('6 PM',  0.15),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF000399),
                  child: Icon(Icons.bar_chart, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duchossois Center — Predicted Busy Times',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Estimates based on typical student patterns',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Typical Weekday', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            ..._weekdaySlots.map((s) => _busyRow(s.$1, s.$2)),
            const SizedBox(height: 12),
            const Text('Typical Weekend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            ..._weekendSlots.map((s) => _busyRow(s.$1, s.$2)),
            const SizedBox(height: 12),
            const Row(
              children: [
                _LegendDot(color: Colors.green, label: 'Light'),
                SizedBox(width: 16),
                _LegendDot(color: Colors.orange, label: 'Moderate'),
                SizedBox(width: 16),
                _LegendDot(color: Colors.red, label: 'Busy'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _busyRow(String time, double busyness) {
    final Color color;
    final String label;
    if (busyness < 0.35) {
      color = Colors.green;
      label = 'Light';
    } else if (busyness < 0.70) {
      color = Colors.orange;
      label = 'Moderate';
    } else {
      color = Colors.red;
      label = 'Busy';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(time, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: busyness,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// VARSITY SPORTS PAGE
// ─────────────────────────────────────────────
class VarsitySportsPage extends StatelessWidget {
  final bool showBackButton;
  const VarsitySportsPage({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final allSports = EventsData.getAllSports();
    final upcomingEvents = EventsData.getUpcomingEvents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Varsity Sports'),
        leading: showBackButton
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
            : null,
      ),
      body: ListView(
        children: [
          _SectionHeader(icon: Icons.event, label: 'Upcoming Events'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: upcomingEvents.isEmpty
                  ? [const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No upcoming events')))]
                  : upcomingEvents.map((e) => _EventCard(event: e)).toList(),
            ),
          ),
          const SizedBox(height: 8),
          _SectionHeader(icon: Icons.sports, label: 'Sports by Category'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: allSports.map((sport) {
                final events = EventsData.getEventsBySport(sport);
                return _SportCard(sport: sport, events: events);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFF000399),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SportingEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10, top: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF000399),
          child: Icon(_sportIcon(event.sport), color: Colors.white, size: 20),
        ),
        title: Text(
          '${event.sport} ${event.homeAwayText} ${event.opponent}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text('${event.formattedDate} • ${event.formattedTime}\n${event.location}',
            style: const TextStyle(fontSize: 12)),
        isThreeLine: true,
        trailing: Chip(
          label: Text(event.isHome ? 'Home' : 'Away', style: const TextStyle(fontSize: 10)),
          backgroundColor: event.isHome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  final String sport;
  final List<SportingEvent> events;
  const _SportCard({required this.sport, required this.events});

  @override
  Widget build(BuildContext context) {
    final upcomingCount = events.where((e) => e.dateTime.isAfter(DateTime.now())).length;
    return Card(
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF000399),
          child: Icon(_sportIcon(sport), color: Colors.white, size: 20),
        ),
        title: Text(sport, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$upcomingCount upcoming games'),
        children: events.take(5).map((event) {
          return ListTile(
            dense: true,
            title: Text('${event.homeAwayText} ${event.opponent}',
                style: const TextStyle(fontSize: 13)),
            subtitle: Text('${event.formattedDate} • ${event.formattedTime}',
                style: const TextStyle(fontSize: 11)),
            trailing: Icon(
              event.isHome ? Icons.home : Icons.flight_takeoff,
              size: 16,
              color: Colors.grey[600],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CLUB SPORTS PAGE
// ─────────────────────────────────────────────
class ClubSportsPage extends StatelessWidget {
  final bool showBackButton;
  const ClubSportsPage({super.key, this.showBackButton = true});

  static const List<Map<String, String>> _clubs = [
    {'name': 'Club Rugby', 'season': 'Fall & Spring', 'contact': 'rugby@wlu.edu', 'icon': 'rugby'},
    {'name': 'Club Soccer', 'season': 'Fall & Spring', 'contact': 'clubsoccer@wlu.edu', 'icon': 'soccer'},
    {'name': 'Club Swimming', 'season': 'Fall & Spring', 'contact': 'clubswimming@wlu.edu', 'icon': 'swimming'},
    {'name': 'Intramural Basketball', 'season': 'Fall & Spring', 'contact': 'imbasketball@wlu.edu', 'icon': 'basketball'},
    {'name': 'Skiing / Snowboarding', 'season': 'Winter', 'contact': 'skiing@wlu.edu', 'icon': 'skiing'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Sports'),
        leading: showBackButton
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
            : null,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0D47A1).withValues(alpha: 0.08),
            child: const Text(
              'Interested in joining a club sport? Browse the list below and tap "Sign Up" to register your interest.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _clubs.length,
              itemBuilder: (context, index) {
                final club = _clubs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF0D47A1),
                          child: Icon(_clubIcon(club['icon']!), color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(club['name']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text('Season: ${club['season']!}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000399),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            textStyle: const TextStyle(fontSize: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _showSignUpDialog(context, club['name']!),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSignUpDialog(BuildContext context, String sportName) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Up — $sportName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'W&L Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000399),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Interest submitted for $sportName! The club will be in touch.'),
                  backgroundColor: const Color(0xFF000399),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  IconData _clubIcon(String type) {
    switch (type) {
      case 'soccer': return Icons.sports_soccer;
      case 'rugby': return Icons.sports_rugby;
      case 'volleyball': return Icons.sports_volleyball;
      case 'tennis': return Icons.sports_tennis;
      case 'golf': return Icons.golf_course;
      case 'rowing': return Icons.rowing;
      case 'cycling': return Icons.directions_bike;
      case 'climbing': return Icons.terrain;
      case 'skiing': return Icons.downhill_skiing;
      default: return Icons.groups;
    }
  }
}

// ─────────────────────────────────────────────
// CAMPUS MAP PAGE
// ─────────────────────────────────────────────
class CampusMapPage extends StatelessWidget {
  const CampusMapPage({super.key});

  static const List<Map<String, String>> _facilities = [
    {
      'name': 'Richard L. Duchossois Athletic and Recreation Center',
      'description': 'Main athletics & recreation center. Home to basketball, volleyball, fitness center, and more.',
      'icon': 'gym',
      'maps': 'https://maps.google.com/maps?q=Duchossois+Athletic+Recreation+Center+Washington+and+Lee+University+Lexington+VA',
    },
    {
      'name': 'Natatorium',
      'description': 'Indoor aquatics facility. Home to Men\'s & Women\'s Swimming & Diving.',
      'icon': 'pool',
      'maps': 'https://maps.google.com/maps?q=Natatorium+Washington+and+Lee+University+Lexington+VA',
    },
    {
      'name': 'Wilson Field',
      'description': 'Football stadium and track complex on the south end of campus.',
      'icon': 'football',
      'maps': 'https://maps.google.com/maps?q=Wilson+Field+Washington+and+Lee+University+Lexington+VA',
    },
    {
      'name': 'Captain Dick Smith Baseball Field',
      'description': 'Home of Generals Baseball.',
      'icon': 'baseball',
      'maps': 'https://maps.google.com/maps?q=Captain+Dick+Smith+Baseball+Field+Washington+and+Lee+University+Lexington+VA',
    },
    {
      'name': 'Fitness Center',
      'description': 'Cardio and weight training facility inside the Duchossois Athletic and Recreation Center.',
      'icon': 'fitness',
      'maps': 'https://maps.google.com/maps?q=Duchossois+Athletic+Recreation+Center+Washington+and+Lee+University+Lexington+VA',
    },
    {
      'name': 'Outdoor Track',
      'description': 'All-weather track used for track & field events and open recreation.',
      'icon': 'track',
      'maps': 'https://maps.google.com/maps?q=Track+Washington+and+Lee+University+Lexington+VA',
    },
    {
      'name': 'Alston Parker Watt Field',
      'description': "Turf field — home to Men's Soccer, Women's Lacrosse, and field hockey.",
      'icon': 'field',
      'maps': 'https://maps.google.com/maps?q=Alston+Parker+Watt+Field+Washington+and+Lee+University+Lexington+VA',
    },
    {
      'name': 'Fuge Field',
      'description': 'General recreation and intramural field for student use.',
      'icon': 'field',
      'maps': 'https://maps.google.com/maps?q=Fuge+Field+Washington+and+Lee+University+Lexington+VA',
    },
    {
      'name': 'Duchossois Tennis Center',
      'description': 'Indoor and outdoor tennis courts for varsity and recreational play.',
      'icon': 'tennis',
      'maps': 'https://maps.google.com/maps?q=Duchossois+Tennis+Center+Washington+and+Lee+University+Lexington+VA',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open Google Maps',
            onPressed: () => launchUrl(
              Uri.parse('https://www.google.com/maps/search/Washington+and+Lee+University+Athletics+Lexington+VA'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Embedded interactive map
          Container(
            height: 340,
            color: Colors.grey[200],
            child: const HtmlElementView(viewType: 'campus-map-iframe'),
          ),
          // Sporting facilities list
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1B5E20),
            child: const Row(
              children: [
                Icon(Icons.place, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Sporting Facilities',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _facilities.length,
              itemBuilder: (context, index) {
                final f = _facilities[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF1B5E20),
                          child: Icon(_facilityIcon(f['icon']!), color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(f['description']!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            textStyle: const TextStyle(fontSize: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => launchUrl(
                            Uri.parse(f['maps']!),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.directions, size: 14),
                          label: const Text('Directions'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _facilityIcon(String type) {
    switch (type) {
      case 'pool':     return Icons.pool;
      case 'football': return Icons.sports_football;
      case 'baseball': return Icons.sports_baseball;
      case 'fitness':  return Icons.fitness_center;
      case 'track':    return Icons.directions_run;
      case 'tennis':   return Icons.sports_tennis;
      case 'field':    return Icons.grass;
      case 'outing':   return Icons.hiking;
      default:         return Icons.stadium;
    }
  }
}

// ─────────────────────────────────────────────
// RESULTS PAGE
// ─────────────────────────────────────────────
class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _sports = [
    'All',
    'Baseball',
    "Men's Lacrosse",
    "Women's Lacrosse",
    "Men's Tennis",
    "Women's Tennis",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sports.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: _sports.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _sports.map((sport) {
          final results = sport == 'All'
              ? EventsData.getResults()
              : EventsData.getResults().where((e) => e.sport == sport).toList();
          results.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          if (sport == 'All') {
            return _buildResultsList(results);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showRoster(context, sport),
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text('View Roster'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF000399),
                      side: const BorderSide(color: Color(0xFF000399)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildResultsList(results)),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showRoster(BuildContext context, String sport) {
    final players = RosterData.getRoster(sport);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Text(sport, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF000399))),
            Text('${players.length} Players', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: players.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final p = players[i];
                  Widget avatar;
                  if (p.photoUrl != null && p.photoUrl!.isNotEmpty) {
                    avatar = CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF000399),
                      backgroundImage: NetworkImage(p.photoUrl!),
                      onBackgroundImageError: (_, __) {},
                      child: null,
                    );
                  } else {
                    avatar = CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF000399),
                      child: Text(
                        p.number ?? '—',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return ListTile(
                    leading: avatar,
                    title: GestureDetector(
                      onTap: () => _showPlayerDetail(context, p),
                      child: Text(
                        p.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF000399),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      [if (p.position != null) p.position!, p.year, p.hometown].join(' · '),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    onTap: () => _showPlayerDetail(context, p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayerDetail(BuildContext context, RosterPlayer p) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with photo
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    if (p.photoUrl != null && p.photoUrl!.isNotEmpty)
                      Image.network(
                        p.photoUrl!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: 220,
                          color: const Color(0xFF000399),
                          child: const Icon(Icons.person, size: 80, color: Colors.white54),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 220,
                        color: const Color(0xFF000399),
                        child: const Icon(Icons.person, size: 80, color: Colors.white54),
                      ),
                    // Number badge
                    if (p.number != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${p.number}',
                            style: const TextStyle(
                              color: Color(0xFF000399),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF000399))),
                    if (p.position != null) ...[
                      const SizedBox(height: 2),
                      Text(p.position!, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _playerDetailRow(Icons.school, 'Year', p.year),
                    _playerDetailRow(Icons.home_outlined, 'Hometown', p.hometown),
                    if (p.highSchool != null) _playerDetailRow(Icons.account_balance, 'High School', p.highSchool!),
                    if (p.major != null) _playerDetailRow(Icons.menu_book, 'Major', p.major!),
                    if (p.height != null) _playerDetailRow(Icons.height, 'Height', p.height!),
                    if (p.weight != null) _playerDetailRow(Icons.monitor_weight_outlined, 'Weight', p.weight!),
                    if (p.handedness != null) _playerDetailRow(Icons.sports_baseball, 'B/T', p.handedness!),
                    if (p.clubTeam != null) _playerDetailRow(Icons.group, 'Club Team', p.clubTeam!),
                    if (p.stats != null && p.stats!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      const Text('2025–26 Stats', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF000399))),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: p.stats!.entries.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000399).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF000399).withOpacity(0.15)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(e.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF000399))),
                                Text(e.key, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
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

  Widget _playerDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF000399)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SportingEvent> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No results yet.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final event = results[index];
        final result = event.result ?? '';
        final isWin = result.startsWith('W');
        final isLoss = result.startsWith('L');
        final Color chipColor = isWin ? Colors.green : (isLoss ? Colors.red[700]! : Colors.grey);
        final score = result.length > 2 ? result.substring(2) : result;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text(
                      result.isNotEmpty ? result[0] : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.homeAwayText} ${event.opponent}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${event.formattedDate} · ${event.sport}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  score,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isWin ? Colors.green[700] : (isLoss ? Colors.red[700] : Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// MORE MENU PAGE (bottom nav tab 5)
// ─────────────────────────────────────────────
class _MoreMenuPage extends StatelessWidget {
  const _MoreMenuPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MORE',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── DARK Occupancy Banner ──
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF000399), Color(0xFF0005CC)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.fitness_center, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DARK Fitness Center',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Occupancy',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── EXPLORE ──
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'EXPLORE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey),
            ),
          ),
          _NavCard(
            title: 'Facility Hours',
            description: 'Operating hours for the Duchossois Center, Natatorium, fields & more.',
            icon: Icons.schedule,
            color: const Color(0xFF1A237E),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacilityHoursPage())),
          ),
          const SizedBox(height: 12),
          _NavCard(
            title: 'Campus Map',
            description: 'Interactive map of W&L — find sporting facilities, fields & venues.',
            icon: Icons.map,
            color: const Color(0xFF1B5E20),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CampusMapPage())),
          ),
          // ── SPORTS ──
          const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              'SPORTS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey),
            ),
          ),
          _NavCard(
            title: 'Varsity Sports',
            description: 'Game schedules, upcoming events & results for all Generals sports.',
            icon: Icons.emoji_events,
            color: const Color(0xFF283593),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VarsitySportsPage())),
          ),
          const SizedBox(height: 12),
          _NavCard(
            title: 'Club Sports',
            description: 'Browse and sign up for student-run club sports at Washington & Lee.',
            icon: Icons.groups,
            color: const Color(0xFF0D47A1),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClubSportsPage())),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────
IconData _sportIcon(String sport) {
  if (sport.contains('Basketball')) return Icons.sports_basketball;
  if (sport.contains('Football')) return Icons.sports_football;
  if (sport.contains('Swimming')) return Icons.pool;
  if (sport.contains('Lacrosse')) return Icons.sports_hockey;
  if (sport.contains('Baseball')) return Icons.sports_baseball;
  if (sport.contains('Wrestling')) return Icons.sports_kabaddi;
  return Icons.sports;
}
