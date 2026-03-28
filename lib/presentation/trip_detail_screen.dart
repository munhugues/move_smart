import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scheduled_route.dart';
import 'seat_selection_screen.dart';

// Shows bus details and lets the user pick boarding/drop points
class TripDetailScreen extends StatefulWidget {
  final ScheduledRoute route;
  const TripDetailScreen({super.key, required this.route});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  String? _boardingPoint;
  String? _dropPoint;

  // Unique ID for this bus + time in BusSeat collection
  String get _seatDocId =>
      '${widget.route.id}_${widget.route.departureTime.replaceAll(':', '-')}';

  @override
  Widget build(BuildContext context) {
    final r = widget.route;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Boarding and Drop Details',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      // Stream live seat count from Firestore
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('BusSeat')
            .doc(_seatDocId)
            .snapshots(),
        builder: (context, snap) {
          // Work out how many seats are still free
          int seatsLeft = r.seatsLeft > 0 ? r.seatsLeft : 30;
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

          return SingleChildScrollView(
            child: Column(
              children: [
                // Blue route header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  color: Colors.blue,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(r.from,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.swap_horiz,
                                color: Colors.white70, size: 22),
                          ),
                          Flexible(
                            child: Text(r.to,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(_todayLabel(),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bus info card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.busName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(r.busType,
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(r.fare.toStringAsFixed(0),
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              Text('RWF / seat',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(r.departureTime,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('→',
                                style: TextStyle(color: Colors.grey[400])),
                          ),
                          Text(r.arrivalTime,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(width: 8),
                          Text(r.duration,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 11)),
                          const Spacer(),
                          // Live seat badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: seatColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_seat,
                                    size: 12, color: seatColor),
                                const SizedBox(width: 4),
                                Text(
                                  isFull
                                      ? 'Full'
                                      : '$seatsLeft seat${seatsLeft == 1 ? "" : "s"} left',
                                  style: TextStyle(
                                      color: seatColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Boarding point picker
                _picker(
                  icon: Icons.login,
                  label: 'Select Boarding Point',
                  value: _boardingPoint,
                  options: [r.from, 'City Centre', 'Nyabugogo'],
                  onPicked: (v) => setState(() => _boardingPoint = v),
                ),

                const SizedBox(height: 10),

                // Drop point picker
                _picker(
                  icon: Icons.logout,
                  label: 'Select Drop Point',
                  value: _dropPoint,
                  options: [r.to, 'Remera', 'Kimironko'],
                  onPicked: (v) => setState(() => _dropPoint = v),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fare per seat',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                      Text('${r.fare.toStringAsFixed(0)} RWF',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isFull
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SeatSelectionScreen(
                                    route: r,
                                    boardingPoint: _boardingPoint ?? r.from,
                                    dropPoint: _dropPoint ?? r.to,
                                  ),
                                ),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        isFull ? 'Bus is Full' : 'Proceed to Seat Selection',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // A tappable tile that opens a bottom sheet to pick an option
  Widget _picker({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> options,
    required void Function(String) onPicked,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<String>(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16))),
          builder: (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              ...options.map((o) => ListTile(
                    title: Text(o),
                    onTap: () => Navigator.pop(ctx, o),
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                    color: value != null ? Colors.black87 : Colors.grey[400],
                    fontSize: 14),
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // Returns today's date as a readable string
  String _todayLabel() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${now.day} ${months[now.month - 1]} ${now.year} | ${days[now.weekday - 1]}';
  }
}
