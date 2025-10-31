import 'package:flutter/material.dart';
import '../models/hotel.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  const HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (hotel.thumbnailUrl.isNotEmpty)
              ? Image.network(hotel.thumbnailUrl, width: 64, height: 64, fit: BoxFit.cover)
              : Container(width: 64, height: 64, color: Colors.grey[300], child: Icon(Icons.hotel)),
        ),
        title: Text(hotel.name),
        subtitle: Text('${hotel.city}, ${hotel.state}, ${hotel.country}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 16),
            Text(hotel.rating.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }
}
