// this is the search result page of hotel results
import 'package:flutter/material.dart';

class HotelResultsPage extends StatelessWidget {
  const HotelResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> hotels = [
      {
        "name": "Hotel Mewah",
        "location": "Manas, Jakarta",
        "rating": 5.0,
        "price": 703000,
        "oldPrice": 1146300,
        "image": 'assets/images/img.png',
        "tags": ["Outdoor Activities", "Disability Friendly", "Air"],
      },
      {
        "name": "Park Hyatt Jakarta",
        "location": "Sugandha, Jakarta",
        "rating": 4.5,
        "price": 590000,
        "oldPrice": 899000,
        "image": 'assets/images/img_1.png',
        "tags": ["Breakfast Included", "Pool", "Sea View"],
        "hasFilter": true,
      },
      {
        "name": "Royal Tulip Sea Pearl",
        "location": "Inani Beach, Jakarta",
        "rating": 5.0,
        "price": 250000,
        "oldPrice": 1200500,
        "image": 'assets/images/img_2.png',
        "tags": ["Private Beach", "Spa", "Luxury"],
      },
      {
        "name": "Long Beach Hotel",
        "location": "Main Road, Jakarta",
        "rating": 4.2,
        "price": 620000,
        "oldPrice": 8500000,
        "image": 'assets/images/img_3.png',
        "tags": ["Free Breakfast", "Gym", "Pool"],
      },
      {
        "name": "Seagull Hotels Ltd",
        "location": "Sea Beach Road, Jakarta",
        "rating": 4.7,
        "price": 800000,
        "oldPrice": 1100000,
        "image": 'assets/images/img_4.png',
        "tags": ["Sea View", "Premium", "Fine Dining"],
        "hasFilter": true,
      },
      {
        "name": "Hotel The Cox Today",
        "location": "Plot-7, Jakarta",
        "rating": 4.0,
        "price": 540000,
        "oldPrice": 790000,
        "image": 'assets/images/img_5.png',
        "tags": ["Conference Hall", "Swimming Pool", "Lounge"],
      },
      {
        "name": "Grace Cox Smart Hotel",
        "location": "Block-A, Jakarta",
        "rating": 4.3,
        "price": 480000,
        "oldPrice": 720000,
        "image": 'assets/images/img_6.png',
        "tags": ["Smart Rooms", "Restaurant", "Rooftop View"],
      },
      {
        "name": "Hotel Sea Crown",
        "location": "Kolatoli Beach, Jakarta",
        "rating": 3.9,
        "price": 450000,
        "oldPrice": 600000,
        "image": 'assets/images/img_7.png',
        "tags": ["Affordable", "Beach Access", "Friendly Staff"],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6F9),
      body: Column(
        children: [
          // Top bar
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            color: const Color(0xFF083D77),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jakarta",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("17 Apr 25 to 18 Apr 25 | 1 Room | 2 Guests",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Icon(Icons.edit, color: Colors.white),
              ],
            ),
          ),
          // Sort/View Map
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: const [
                  Icon(Icons.sort),
                  SizedBox(width: 8),
                  Text("Sort By")
                ]),
                Row(children: const [
                  Icon(Icons.map_outlined),
                  SizedBox(width: 8),
                  Text("View Map")
                ]),
              ],
            ),
          ),
          const Divider(height: 1),
          // Results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return HotelCard(hotel: hotel);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  final Map<String, dynamic> hotel;

  const HotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  hotel['image'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.local_fire_department,
                          size: 14, color: Colors.blueAccent),
                      SizedBox(width: 4),
                      Text("Top Selling",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              if (hotel['hasFilter'] == true)
                Positioned(
                  bottom: 12,
                  left: (MediaQuery.of(context).size.width / 2) - 40,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("Filter",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              Positioned(
                bottom: 10,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[600],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text("Get Points",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel['name'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text('${hotel['rating']} Star'),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    Flexible(
                        child: Text(hotel['location'],
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('IDR ${hotel['oldPrice']}',
                        style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red)),
                    const SizedBox(width: 6),
                    Text('IDR ${hotel['price']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.orange[300],
                          borderRadius: BorderRadius.circular(4)),
                      child:
                          const Text('38% OFF', style: TextStyle(fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: hotel['tags'].map<Widget>((tag) {
                    return Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.green[50],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Extra 5% discount for bKash payment.',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
