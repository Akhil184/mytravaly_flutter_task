import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.mytravaly.com/public/v1/';
  static const String token = '71523fdd8d26f585315b4233e39d9263';
  static const String vtoken = '3ebb-5bcc-7152-4f3f-5ad3-00c1-5352-1af7';

  static Future<List<Map<String, dynamic>>> searchHotels(String query,
      {int limit = 10}) async {
    final headers = {
      'Content-Type': 'application/json',
      'authtoken': token,
      'visitorToken': vtoken,
    };

    final body = jsonEncode({
      "action": "searchAutoComplete",
      "searchAutoComplete": {
        "inputText": query,
        "searchType": [
          "byCity",
          "byState",
          "byCountry",
          "byRandom",        // ✅ replaced invalid 'byStreet'
          "byPropertyName"
        ],
        "limit": limit
      }
    });

    final response =
    await http.post(Uri.parse(baseUrl), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final autoCompleteList = data['data']?['autoCompleteList'] ?? {};
      List<Map<String, dynamic>> results = [];

      for (var key in autoCompleteList.keys) {
        final list = autoCompleteList[key]?['listOfResult'];
        if (list != null && list is List) {
          for (final item in list) {
            results.add({
              'display': item['valueToDisplay'] ?? '',
              'city': item['address']?['city'] ?? '',
              'state': item['address']?['state'] ?? '',
              'country': item['address']?['country'] ?? '',
              'type': key,
            });
          }
        }
      }

      return results;
    } else {
      throw Exception('Failed to load hotels: ${response.body}');
    }
  }


  static Future<List<Map<String, dynamic>>> getSearchResultListOfHotels({
    required List<String> searchQuery,
    required String checkIn,
    required String checkOut,
    int rooms = 1,
    int adults = 2,
    int children = 0,
    String searchType = "hotelIdSearch",
    int limit = 5,
    String currency = "INR",
    int rid = 0,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'authtoken': token,
      'visitorToken': vtoken,
    };

    final body = jsonEncode({
      "action": "getSearchResultListOfHotels",
      "getSearchResultListOfHotels": {
        "searchCriteria": {
          "checkIn": checkIn,
          "checkOut": checkOut,
          "rooms": rooms,
          "adults": adults,
          "children": children,
          "searchType": searchType,
          "searchQuery": searchQuery,
          "accommodation": ["all", "hotel"],
          "arrayOfExcludedSearchType": ["street"],
          "highPrice": "3000000",
          "lowPrice": "0",
          "limit": limit,
          "preloaderList": [],
          "currency": currency,
          "rid": rid
        }
      }
    });

    final response =
    await http.post(Uri.parse(baseUrl), headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] == true &&
          jsonData['data']?['arrayOfHotelList'] != null) {
        final List hotels = jsonData['data']['arrayOfHotelList'];

        return List<Map<String, dynamic>>.from(hotels.map((hotel) => {
          "id": hotel["propertyCode"] ?? "",
          "name": hotel["propertyName"] ?? "",
          "image": hotel["propertyImage"]?["fullUrl"] ?? "",
          "rating": hotel["googleReview"]?["data"]?["overallRating"] ?? 0.0,
          "city": hotel["propertyAddress"]?["city"] ?? "",
          "state": hotel["propertyAddress"]?["state"] ?? "",
          "country": hotel["propertyAddress"]?["country"] ?? "",
          "price": (hotel["availableDeals"] != null &&
              hotel["availableDeals"] is List &&
              hotel["availableDeals"].isNotEmpty)
              ? (hotel["availableDeals"][0]["price"]?["displayAmount"] ?? "")
              : "",

          "url": hotel["propertyUrl"] ?? "",
        }));
      } else {
        return [];
      }
    } else {
      throw Exception(
          'Failed to fetch hotels: ${response.statusCode} → ${response.body}');
    }
  }



}