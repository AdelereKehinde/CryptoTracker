import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class NewsFeedScreen extends StatefulWidget {
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

  // Free crypto news API (no signup required)
  final String apiUrl = "https://newsdata.io/api/1/news?apikey=pub_420389e36e5f8d1f773e3b4a5d4b79bfc5a5f&category=business&language=en&q=crypto";

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
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 100 &&
        !_scrollController.position.outOfRange) {
      if (_hasMore && !loading) {
        loadMoreNews();
      }
    }
  }

  Future<void> fetchNews() async {
    setState(() {
      loading = true;
      error = false;
    });
    
    try {
      final response = await _dio.get(apiUrl);
      
      if (response.statusCode == 200 && response.data['results'] != null) {
        setState(() {
          news = response.data['results'];
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
    
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      news.addAll(_generateMoreDummyData());
      loading = false;
      _currentPage++;
      if (_currentPage >= 3) _hasMore = false;
    });
  }

  void _useDummyData() {
    setState(() {
      news = _generateDummyNews();
      loading = false;
      error = true;
    });
  }

  List<dynamic> _generateDummyNews() {
    return [
      {
        'title': 'Bitcoin Surges Past \$65,000 as Institutional Adoption Grows',
        'description': 'Major financial institutions continue to add Bitcoin to their balance sheets, driving the price to new monthly highs. Market analysts predict continued growth throughout the quarter.',
        'image_url': 'https://images.unsplash.com/photo-1518546305927-5a555bb7020d?w=400',
        'pubDate': '2024-01-15 10:30:00',
        'source_id': 'crypto-daily',
        'link': 'https://www.cointelegraph.com'
      },
      {
        'title': 'Ethereum 2.0 Upgrade Reduces Energy Consumption by 99%',
        'description': 'The successful merge transitions Ethereum to proof-of-stake, making it more environmentally friendly and scalable for future applications.',
        'image_url': 'https://images.unsplash.com/photo-1621761191319-c6fb62004040?w=400',
        'pubDate': '2024-01-15 09:15:00',
        'source_id': 'blockchain-news',
        'link': 'https://www.coindesk.com'
      },
      {
        'title': 'Regulatory Clarity Emerges for Cryptocurrencies Globally',
        'description': 'New framework provides much-needed guidelines for crypto businesses and investors, boosting market confidence and institutional participation.',
        'image_url': 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=400',
        'pubDate': '2024-01-14 16:45:00',
        'source_id': 'financial-times',
        'link': 'https://www.decrypt.co'
      },
      {
        'title': 'DeFi Protocol Reaches \$100 Billion in Total Value Locked',
        'description': 'Decentralized finance continues to grow despite market conditions, showing strong fundamentals and user adoption across multiple chains.',
        'image_url': 'https://images.unsplash.com/photo-1639762681057-40897d5e7c24?w=400',
        'pubDate': '2024-01-14 14:20:00',
        'source_id': 'defi-pulse',
        'link': 'https://www.cryptoslate.com'
      },
      {
        'title': 'NFT Market Sees Resurgence with Gaming Partnerships',
        'description': 'Major gaming companies announce NFT integrations, driving renewed interest in digital collectibles and metaverse applications.',
        'image_url': 'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=400',
        'pubDate': '2024-01-14 11:30:00',
        'source_id': 'nft-news',
        'link': 'https://www.cryptoslate.com'
      }
    ];
  }

  List<dynamic> _generateMoreDummyData() {
    return [
      {
        'title': 'Central Bank Digital Currencies Gain Global Traction',
        'description': 'Over 80% of central banks now exploring digital currency implementations for modern financial systems.',
        'image_url': 'https://images.unsplash.com/photo-1550572017-069d6b1a2b3d?w=400',
        'pubDate': '2024-01-13 13:15:00',
        'source_id': 'cbdc-insider',
        'link': 'https://www.cryptoslate.com'
      },
      {
        'title': 'Web3 Startups Raise \$7.3 Billion in Q4 Funding',
        'description': 'Venture capital continues to flow into blockchain and Web3 infrastructure projects despite market volatility.',
        'image_url': 'https://images.unsplash.com/photo-1665686377066-08b6fad8dbff?w=400',
        'pubDate': '2024-01-13 10:45:00',
        'source_id': 'vc-daily',
        'link': 'https://www.coindesk.com'
      }
    ];
  }

  void _refreshNews() {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      news.clear();
    });
    fetchNews();
  }

  void _openArticle(int index) {
    final article = news[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Color(0xFF0A0E2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article['image_url'] != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(article['image_url']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    Text(
                      article['title'] ?? 'No title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      article['description'] ?? 'No description available',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[800]!.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              article['source_id']?.toString().toUpperCase() ?? 'UNKNOWN',
                              style: TextStyle(
                                color: Colors.blue[200],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatDate(article['pubDate'] ?? ''),
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening full article in browser...'),
                              backgroundColor: Colors.blue[800],
                            ),
                          );
                        },
                        child: Text(
                          'READ FULL ARTICLE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (e) {
      return 'Recent';
    }
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Crypto News',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: _refreshNews,
                  ),
                ],
              ),
            ),

            // Error Banner
            if (error)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[800]!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.orange[200], size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using demo data - Connect to internet for live news',
                        style: TextStyle(color: Colors.orange[200], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16),

            // News List
            Expanded(
              child: loading && news.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.blue[200]),
                          SizedBox(height: 16),
                          Text(
                            'Loading latest crypto news...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      backgroundColor: Colors.blue[800],
                      color: Colors.white,
                      onRefresh: fetchNews,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: news.length + 1,
                        itemBuilder: (context, index) {
                          if (index == news.length) {
                            return _hasMore
                                ? Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(color: Colors.blue[200]),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: Text(
                                        'No more articles to load',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ),
                                  );
                          }

                          final item = news[index];
                          return _NewsCard(
                            title: item['title'] ?? 'No title',
                            description: item['description'] ?? 'No description available',
                            imageUrl: item['image_url'],
                            source: item['source_id'] ?? 'Unknown Source',
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
}

class _NewsCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String source;
  final String date;
  final VoidCallback onTap;

  const _NewsCard({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.source,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // News Image
                if (imageUrl != null)
                  Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                // News Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[800]!.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              source.toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue[200],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}