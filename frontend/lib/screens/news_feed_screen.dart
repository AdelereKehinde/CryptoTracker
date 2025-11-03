import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final Dio _dio = Dio();
  List<dynamic> news = [];
  bool loading = true;
  bool error = false;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;

  // LIVE CRYPTO NEWS API
  String get apiUrl =>
      "https://newsdata.io/api/1/news?apikey=pub_420389e36e5f8d1f773e3b4a5d4b79bfc5a5f&q=crypto&page=$_currentPage";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchNews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      if (_hasMore && !loading) loadMoreNews();
    }
  }

  Future<void> fetchNews() async {
    setState(() {
      loading = true;
      error = false;
    });

    try {
      final response = await _dio.get(apiUrl);
      final data = response.data;

      if (response.statusCode == 200 && data['results'] != null) {
        setState(() {
          news = data['results'];
          _hasMore = data['nextPage'] != null;
          loading = false;
        });
      } else {
        _useDummyData();
      }
    } catch (e) {
      _useDummyData();
    }
  }

  Future<void> loadMoreNews() async {
    if (!_hasMore || loading) return;
    setState(() => loading = true);

    try {
      _currentPage++;
      final response = await _dio.get(apiUrl);
      final data = response.data;

      if (response.statusCode == 200 && data['results'] != null) {
        setState(() {
          news.addAll(data['results']);
          _hasMore = data['nextPage'] != null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No more news"), backgroundColor: Colors.orange),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void _useDummyData() {
    setState(() {
      news = _generateDummyNews();
      loading = false;
      error = true;
    });
  }

  // DUMMY DATA FUNCTIONS (FIXED!)
  List<dynamic> _generateDummyNews() {
    return [
      {
        'title': 'Bitcoin Surges to \$120,000 as Trump Wins Election',
        'description': 'Crypto market explodes after pro-Bitcoin candidate victory. ETFs see record inflows.',
        'image_url': 'https://images.unsplash.com/photo-1518546305927-5a555bb7020d?w=400',
        'pubDate': '2025-11-03 10:30:00',
        'source_id': 'coindesk',
        'link': 'https://coindesk.com'
      },
      {
        'title': 'Ethereum Hits All-Time High After ETF Approval',
        'description': 'ETH breaks \$8,000 as institutional money floods in. Staking yields soar.',
        'image_url': 'https://images.unsplash.com/photo-1621761191319-c6fb62004040?w=400',
        'pubDate': '2025-11-03 09:15:00',
        'source_id': 'theblock',
        'link': 'https://theblock.co'
      },
      {
        'title': 'Solana Mobile 2 Sells Out in 2 Hours',
        'description': 'Web3 phone with hardware wallet sells 100K units instantly.',
        'image_url': 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=400',
        'pubDate': '2025-11-02 16:45:00',
        'source_id': 'decrypt',
        'link': 'https://decrypt.co'
      },
    ];
  }

  List<dynamic> _generateMoreDummyData() {
    return [
      {
        'title': 'BlackRock Launches Crypto Fund',
        'description': '\$10B fund opens doors for pension funds to buy Bitcoin.',
        'image_url': 'https://images.unsplash.com/photo-1639762681057-40897d5e7c24?w=400',
        'pubDate': '2025-11-01 14:20:00',
        'source_id': 'bloomberg',
        'link': 'https://bloomberg.com'
      },
    ];
  }

  // OPEN IN BROWSER WITH TOAST
  Future<void> _openInBrowser(String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text("Opening in browser..."),
          ],
        ),
        backgroundColor: Colors.blue[800],
      ),
    );

    await Future.delayed(Duration(seconds: 1));

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Can't open link"), backgroundColor: Colors.red),
      );
    }
  }

  void _openArticle(int index) {
    final article = news[index];
    final link = article['link'] ?? article['url'] ?? 'https://cryptonews.com';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFF0A0E2A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(margin: EdgeInsets.only(top: 12), width: 50, height: 5, color: Colors.white30),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article['image_url'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: article['image_url'],
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[700]!,
                            child: Container(color: Colors.grey),
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    Text(article['title'] ?? 'No Title',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.blue[700]!.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                          child: Text((article['source_id'] ?? 'Crypto').toString().toUpperCase(),
                              style: TextStyle(color: Colors.blue[200], fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 12),
                        Text(_formatDate(article['pubDate'] ?? ''),
                            style: TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(article['description'] ?? 'No description.',
                        style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openInBrowser(link);
                      },
                      icon: Icon(Icons.open_in_browser),
                      label: Text("READ FULL ARTICLE", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      return '${diff.inMinutes}m ago';
    } catch (e) {
      return 'Just now';
    }
  }

  void _refreshNews() {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      news.clear();
    });
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E2A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1E3C72), Color(0xFF2A5298)]),
              ),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  Text('Crypto News', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Spacer(),
                  IconButton(icon: Icon(Icons.refresh, color: Colors.white), onPressed: _refreshNews),
                ],
              ),
            ),

            // Offline Banner
            if (error)
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange[900]!.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)),
                child: Row(children: [Icon(Icons.signal_wifi_off, color: Colors.orange[300]), SizedBox(width: 12), Expanded(child: Text("Offline - Showing demo news", style: TextStyle(color: Colors.orange[200])))]),
              ),

            // News List
            Expanded(
              child: loading && news.isEmpty
                  ? _buildShimmerList()
                  : RefreshIndicator(
                      onRefresh: fetchNews,
                      color: Colors.white,
                      backgroundColor: Colors.blue[800],
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: news.length + (loading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == news.length) {
                            return Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: Colors.blue[300])));
                          }
                          final item = news[index];
                          return _NewsCard(
                            title: item['title'] ?? 'No title',
                            description: item['description'] ?? 'Tap to read',
                            imageUrl: item['image_url'],
                            source: item['source_id'] ?? 'Crypto',
                            date: _formatDate(item['pubDate'] ?? ''),
                            onTap: () => _openArticle(index),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
        child: Container(
          margin: EdgeInsets.all(16),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(16),
  ),
),
      ),
    );
  }
}

// NEWS CARD
class _NewsCard extends StatelessWidget {
  final String title, description, source, date;
  final String? imageUrl;
  final VoidCallback onTap;

  const _NewsCard({required this.title, required this.description, required this.source, required this.date, this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Row(
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(imageUrl: imageUrl!, width: 90, height: 90, fit: BoxFit.cover),
                ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 6),
                    Text(description, style: TextStyle(color: Colors.white70, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.green[700]!.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                          child: Text(source.toUpperCase(), style: TextStyle(color: Colors.green[200], fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 10),
                        Text(date, style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}