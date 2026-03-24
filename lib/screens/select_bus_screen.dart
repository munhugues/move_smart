import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scheduled_route.dart';
import 'trip_detail_screen.dart';

// Shows all buses that match the from/to the user typed
class SelectBusScreen extends StatelessWidget {
  final String from;
  final String to;
  const SelectBusScreen({super.key, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final dateLabel = '${now.day} ${months[now.month - 1]} ${now.year} | ${days[now.weekday - 1]}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Blue top header
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              bottom: 20,
              left: 4,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(from.isEmpty ? 'Any' : from,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.swap_horiz,
                            color: Colors.white70, size: 24),
                      ),
                      Text(to.isEmpty ? 'Any' : to,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(dateLabel,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ),
              ],
            ),
          ),

          // Bus list from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ScheduleRoute')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Filter by from/to — partial match, not case sensitive
                final filtered = (snapshot.data?.docs ?? [])
                    .map(ScheduledRoute.fromFirestore)
                    .where((r) {
                  final fMatch = from.isEmpty ||
                      r.from.toLowerCase().contains(from.toLowerCase());
                  final tMatch = to.isEmpty ||
                      r.to.toLowerCase().contains(to.toLowerCase());
                  return fMatch && tMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_bus_filled,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No buses found for\n"${from.isEmpty ? "Any" : from}" → "${to.isEmpty ? "Any" : to}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go back'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Select your bus!',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _BusCard(route: filtered[i]),
                      ),
                    ),
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

// One bus card — streams live seat count from BusSeat collection
class _BusCard extends StatelessWidget {
  final ScheduledRoute route;
  const _BusCard({required this.route});

  // Unique ID for this bus at this departure time
  String get _seatDocId =>
      '${route.id}_${route.departureTime.replaceAll(':', '-')}';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('BusSeat')
          .doc(_seatDocId)
          .snapshots(),
      builder: (context, snap) {
        // Calculate seats left from the BusSeat doc
        int seatsLeft = route.seatsLeft > 0 ? route.seatsLeft : 30;
        if (snap.hasData && snap.data!.exists) {
          final d = snap.data!.data() as Map<String, dynamic>;
          final total = (d['totalSeats'] as num?)?.toInt() ?? seatsLeft;
          final taken = (d['takenSeats'] as List? ?? []).length;
          seatsLeft = total - taken;
        }

        final isFull = seatsLeft == 0;
        final seatColor = isFull
            ? Colors.red
            : seatsLeft < 5
                ? Colors.orange
                : Colors.green;

        return GestureDetector(
          onTap: isFull
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This bus is full. Please choose another.'),
                      backgroundColor: Colors.red,
                    ),
                  )
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TripDetailScreen(route: route)),
                  ),
          child: Opacity(
            opacity: isFull ? 0.6 : 1.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route.busName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(route.busType,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                        const SizedBox(height: 8),
                        // Departure → Arrival time
                        Row(
                          children: [
                            Text(route.departureTime,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text('→',
                                  style: TextStyle(color: Colors.grey[400])),
                            ),
                            Text(route.arrivalTime,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            const SizedBox(width: 8),
                            Text(route.duration,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Seat count
                        Row(
                          children: [
                            Icon(Icons.event_seat, size: 13, color: seatColor),
                            const SizedBox(width: 4),
                            Text(
                              isFull ? 'Full' : '$seatsLeft seats left',
                              style: TextStyle(
                                  color: seatColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Fare + FULL badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(route.fare.toStringAsFixed(0),
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 24)),
                      Text('RWF',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 11)),
                      if (isFull)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('FULL',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
