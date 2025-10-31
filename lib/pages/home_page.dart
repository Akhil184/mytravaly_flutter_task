import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../widgets/hotel_card.dart';
import 'login_page.dart';
import '../services/api_service.dart'; // 👈 where your searchHotels() lives

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Hotel> _sampleHotels = [];
  List<dynamic> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sampleHotels = [
      Hotel(
        id: '1',
        name: 'The Leela Palace',
        city: 'Bangalore',
        state: 'Karnataka',
        country: 'India',
        rating: 4.8,
        thumbnailUrl: '',
      ),
      Hotel(
        id: '2',
        name: 'Taj Mahal Palace',
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        rating: 4.9,
        thumbnailUrl: '',
      ),
      Hotel(
        id: '3',
        name: 'ITC Grand Chola',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        rating: 4.7,
        thumbnailUrl: '',
      ),
      Hotel(
        id: '4',
        name: 'The Oberoi Udaivilas',
        city: 'Udaipur',
        state: 'Rajasthan',
        country: 'India',
        rating: 4.9,
        thumbnailUrl: '',
      ),
      Hotel(
        id: '5',
        name: 'Radisson Blu',
        city: 'New Delhi',
        state: 'Delhi',
        country: 'India',
        rating: 4.6,
        thumbnailUrl: '',
      ),
      Hotel(
        id: '6',
        name: 'The Lalit Ashok',
        city: 'Bangalore',
        state: 'Karnataka',
        country: 'India',
        rating: 4.5,
        thumbnailUrl: '',
      ),
      Hotel(
        id: '7',
        name: 'JW Marriott',
        city: 'Pune',
        state: 'Maharashtra',
        country: 'India',
        rating: 4.7,
        thumbnailUrl: '',
      ),
      Hotel(
        id: '8',
        name: 'The Park Hyderabad',
        city: 'Hyderabad',
        state: 'Telangana',
        country: 'India',
        rating: 4.4,
        thumbnailUrl: '',
      ),
    ];
  }

  /// 🔍 Trigger search manually (navigates to results page)
  void _onSearch([String? selected]) {
    final query = selected ?? _searchController.text.trim();
    if (query.isEmpty) return;
    Navigator.pushNamed(context, '/results', arguments: {'query': query});
  }

  /// ✨ Fetch autocomplete suggestions
  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await ApiService.searchHotels(query);
      setState(() => _suggestions = results);
    } catch (e) {
      debugPrint('Autocomplete error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
        ),
        title: const Text(
          'Hotels - Home',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                height: 80 + (_suggestions.isNotEmpty ? 250 : 0), // give room for dropdown
                child: Stack(
                  children: [
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onChanged: _fetchSuggestions,
                      onSubmitted: (_) => _onSearch(),
                      decoration: InputDecoration(
                        hintText: 'Search by hotel name, city, state, or country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: IconButton(
                          icon: const Icon(Icons.search, color: Colors.teal),
                          onPressed: _onSearch,
                        ),
                      ),
                    ),
                    if (_suggestions.isNotEmpty)
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final item = _suggestions[index];
                              return ListTile(
                                title: Text(item['display'] ?? 'Unknown'),
                                subtitle: Text(
                                  '${item['city'] ?? ''}, ${item['state'] ?? ''}, ${item['country'] ?? ''}',
                                ),
                                onTap: () {
                                  _searchController.text = item['display'] ?? '';
                                  setState(() => _suggestions = []);
                                  _onSearch(item['display']);
                                },
                              );

                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: _sampleHotels.length,
                itemBuilder: (ctx, idx) => HotelCard(hotel: _sampleHotels[idx]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
