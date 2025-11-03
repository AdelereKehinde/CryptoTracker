// Custom Range Chart Screen
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CustomRangeChartScreen extends StatefulWidget {
  const CustomRangeChartScreen({super.key});

  @override
  State<CustomRangeChartScreen> createState() => _CustomRangeChartScreenState();
}

class _CustomRangeChartScreenState extends State<CustomRangeChartScreen> {
  List chartData = [];
  bool loading = true;
  String coinId = 'bitcoin';
  String coinName = 'Bitcoin';

  Future<void> fetchChart(String id, int from, int to) async {
    setState(() => loading = true);
    try {
      final response = await Dio().get(
        'https://cryptotracker-yof6.onrender.com/$id/market_chart/range',
        queryParameters: {
          'vs_currency': 'usd',
          'from_': from,
          'to': to,
        },
      );
      chartData = response.data['prices'] ?? [];
    } catch (e) {
      chartData = [];
    }
    setState(() => loading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    coinId = args['id'] ?? 'bitcoin';
    coinName = args['name'] ?? 'Bitcoin';
    final from = args['from'] ?? DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch ~/ 1000;
    final to = args['to'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    fetchChart(coinId, from, to);
  }

  void _refreshData() {
    final from = DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch ~/ 1000;
    final to = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    fetchChart(coinId, from, to);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E2A),
      appBar: AppBar(
        title: Text(
          '$coinName Chart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E2A), Color(0xFF1A237E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue[200]),
                    SizedBox(height: 16),
                    Text(
                      'Loading chart data...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            : chartData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.white54, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'No chart data available',
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _refreshData,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Summary Card
                      Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Data Points', chartData.length.toString()),
                            _buildStatItem(
                              'Current Price',
                              '\$${chartData.last[1].toStringAsFixed(2)}',
                            ),
                            _buildStatItem(
                              'Period',
                              '${_formatDate(DateTime.fromMillisecondsSinceEpoch(chartData.first[0].toInt()))} - ${_formatDate(DateTime.fromMillisecondsSinceEpoch(chartData.last[0].toInt()))}',
                            ),
                          ],
                        ),
                      ),
                      // Data List
                      Expanded(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: chartData.length,
                          itemBuilder: (context, index) {
                            final point = chartData[index];
                            final date = DateTime.fromMillisecondsSinceEpoch(point[0].toInt());
                            final price = point[1];
                            final isLatest = index == chartData.length - 1;
                            
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    // Optional: Add detail view for specific point
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isLatest 
                                          ? Colors.blue[800]!.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isLatest 
                                            ? Colors.blue[400]!
                                            : Colors.white.withOpacity(0.1),
                                        width: isLatest ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Date and Time
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _formatDate(date),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                _formatTime(date),
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Price
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '\$${price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        // Trend Indicator
                                        Expanded(
                                          flex: 1,
                                          child: _buildTrendIndicator(index, price),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(int index, double currentPrice) {
    if (index == 0) {
      return Icon(Icons.remove, color: Colors.grey, size: 20);
    }
    
    final previousPrice = chartData[index - 1][1];
    final isUp = currentPrice > previousPrice;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          isUp ? Icons.arrow_upward : Icons.arrow_downward,
          color: isUp ? Colors.greenAccent : Colors.redAccent,
          size: 20,
        ),
        SizedBox(width: 4),
        Text(
          '${((currentPrice - previousPrice) / previousPrice * 100).abs().toStringAsFixed(2)}%',
          style: TextStyle(
            color: isUp ? Colors.greenAccent : Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}