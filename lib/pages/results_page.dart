import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  int _limit = 5;
  String _query = '';
  bool _hasMore = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _query = args?['query'] ?? '';
    _fetchResults();
  }

  Future<void> _fetchResults({bool loadMore = false}) async {
    if (_loading || !_hasMore) return;

    setState(() => _loading = true);

    try {
      final data = await ApiService.getSearchResultListOfHotels(
        searchQuery: [_query],
        checkIn: "2025-11-05",  // You can make this dynamic
        checkOut: "2025-11-06", // or pass via route arguments
        limit: _limit,
      );

      setState(() {
        if (loadMore) {
          _results.addAll(data);
        } else {
          _results = data;
        }

        _loading = false;
        _hasMore = data.length >= _limit;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching results: $e')),
      );
    }
  }

  void _loadMore() {
    _limit += 10;
    _fetchResults(loadMore: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "$_query"'),
        centerTitle: true,
      ),
      body: _loading && _results.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? const Center(child: Text('No results found.'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final hotel = _results[i];
                final name = hotel['name'] ?? 'Unknown Hotel';
                final city = hotel['city'] ?? '';
                final state = hotel['state'] ?? '';
                final country = hotel['country'] ?? '';
                final price = hotel['price']?.toString() ?? '';
                final rating = hotel['rating']?.toString() ?? '';
                final image = hotel['image'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    leading: image.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(Icons.hotel, size: 40),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$city, $state, $country'),
                        const SizedBox(height: 4),
                        Text(
                          price.isNotEmpty ? '₹$price/night' : '',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 20),
                        Text(rating),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_hasMore && !_loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                onPressed: _loadMore,
                child: const Text('Load More'),
              ),
            ),
          if (_loading && _results.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
