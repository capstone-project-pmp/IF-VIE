import 'package:flutter/material.dart';

class FlightPage extends StatefulWidget {
  const FlightPage({Key? key}) : super(key: key);

  @override
  State<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {
  String fromCity = 'Bandung';
  String fromAirport = 'Bandar Udara Internasional Husein Sastranegara
';
  String toCity = "Jakarta";
  String toAirport = "Bandara Sooekarno-Hatta";
  DateTime departureDate = DateTime.now();
  bool showResults = false;
  List<Flight> flights = [];

  @override
  void initState() {
    super.initState();
    // Sample flight data
    flights = [
      Flight(
        airline: 'Air Asia',
        flightNumber: 'BG 101',
        departureTime: '08:00 AM',
        arrivalTime: '09:15 AM',
        duration: '1h 15m',
        price: 'IDR.150.000',
      ),
      Flight(
        airline: 'LION AIR',
        flightNumber: 'BS 201',
        departureTime: '11:30 AM',
        arrivalTime: '12:45 PM',
        duration: '1h 15m',
        price: 'IDR.170.800',
      ),
      Flight(
        airline: 'Novo Air',
        flightNumber: 'NV 301',
        departureTime: '03:15 PM',
        arrivalTime: '04:30 PM',
        duration: '1h 15m',
        price: 'IDR.12O.000',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (showResults) {
      return _buildResultsPage();
    }
    return _buildBookingPage();
  }

  Widget _buildBookingPage() {
    String formattedDate = "${departureDate.day} ${_getMonthAbbreviation(departureDate.month)}";
    String formattedDay = _getWeekdayName(departureDate.weekday);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flights'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripTypeSelector(),
            const SizedBox(height: 20),
            _buildLocationTile('From', fromCity, fromAirport, (city, airport) {
              setState(() {
                fromCity = city;
                fromAirport = airport;
              });
            }),
            _buildLocationTile('To', toCity, toAirport, (city, airport) {
              setState(() {
                toCity = city;
                toAirport = airport;
              });
            }),
            _buildDateSelector('Departure', formattedDate, formattedDay, (picked) {
              setState(() {
                departureDate = picked;
              });
            }),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text('+ ADD RETURN DATE', style: TextStyle(color: Colors.blue)),
            ),
            const SizedBox(height: 10),
            _buildInfoTile('TRAVELERS', '01'),
            _buildInfoTile('CLASS', 'Economy'),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  setState(() {
                    showResults = true;
                  });
                },
                child: const Text('Search', style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flight_takeoff, color: Colors.black54),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('How to Book Flight?')),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Watch Video', style: TextStyle(color: Colors.blue)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Hot Deals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[300],
                    height: 80,
                    child: const Center(child: Text('Deal 1')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    color: Colors.grey[300],
                    height: 80,
                    child: const Center(child: Text('Deal 2')),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('$fromCity to $toCity'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              showResults = false;
            });
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: flights.length,
        itemBuilder: (context, index) {
          return _buildFlightCard(flights[index]);
        },
      ),
    );
  }

  Widget _buildFlightCard(Flight flight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(flight.airline, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(flight.flightNumber, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(flight.departureTime, style: const TextStyle(fontSize: 18)),
                    Text(fromCity, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  children: [
                    Text(flight.duration, style: const TextStyle(color: Colors.grey)),
                    const Icon(Icons.flight, color: Colors.blue),
                  ],
                ),
                Column(
                  children: [
                    Text(flight.arrivalTime, style: const TextStyle(fontSize: 18)),
                    Text(toCity, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Details', style: TextStyle(color: Colors.blue)),
                ),
                Text(
                  flight.price,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for date formatting without intl package
  String _getMonthAbbreviation(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    return weekdays[weekday - 1];
  }

  // Trip type selector widget
  Widget _buildTripTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabButton('One Way', true),
        _buildTabButton('Round Way', false),
        _buildTabButton('Multi City', false),
      ],
    );
  }

  Widget _buildTabButton(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.yellow[700] : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? Colors.black : Colors.black54,
          ),
        ),
      ),
    );
  }

  // Location tile widget
  Widget _buildLocationTile(String title, String city, String airport, void Function(String, String) onSelected) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  title: const Text("Bandung"),
                  subtitle: const Text("Bandar Udara Internasional Husein Sastranegara"),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected("Bandung", "Bandar Udara Internasional Husein Sastranegara");
                  },
                ),
                ListTile(
                  title: const Text("Palembang"),
                  subtitle: const Text("Bandara Sultan Mahmud Badaruddin II Palembang"),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected("Palembang", "Bandara Sultan Mahmud Badaruddin II Palembang");
                  },
                ),
                ListTile(
                  title: const Text("Jakarta"),
                  subtitle: const Text("Bandara Sooekarno-Hatta"),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected("Jakarta", "Bandara Sooekarno-Hatta");
                  },
                ),
              ],
            );
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(city, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(airport, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Date selector widget
  Widget _buildDateSelector(String title, String date, String day, void Function(DateTime) onSelected) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: departureDate,
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onSelected(picked);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(day, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Info tile widget
  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class Flight {
  final String airline;
  final String flightNumber;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String price;

  Flight({
    required this.airline,
    required this.flightNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
  });
}