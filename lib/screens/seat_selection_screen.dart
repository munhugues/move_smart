import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scheduled_route.dart';
import 'ticket_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final ScheduledRoute route;
  final String boardingPoint;
  final String dropPoint;

  const SeatSelectionScreen({
    super.key,
    required this.route,
    required this.boardingPoint,
    required this.dropPoint,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final Set<int> _selected = {};
  bool _booking = false;

  // Unique key per route + departure time
  String get _seatDocId =>
      '${widget.route.id}_${widget.route.departureTime.replaceAll(':', '-')}';

  Stream<DocumentSnapshot> get _seatStream => FirebaseFirestore.instance
      .collection('BusSeat')
      .doc(_seatDocId)
      .snapshots();

  Future<void> _confirmBooking(Set<int> takenSeats, int totalBusSeats) async {
    if (_selected.isEmpty) return;
    setState(() => _booking = true);
    try {
      final r = widget.route;
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      // Save booking doc
      final bookingRef = db.collection('Booking').doc();
      final sortedSeats = _selected.toList()..sort();
      batch.set(bookingRef, {
        'routeId': r.id,
        'from': r.from,
        'to': r.to,
        'busName': r.busName,
        'busType': r.busType,
        'departureTime': r.departureTime,
        'arrivalTime': r.arrivalTime,
        'duration': r.duration,
        'fare': r.fare * _selected.length,
        'farePerSeat': r.fare,
        'seatCount': _selected.length,
        'seats': sortedSeats,
        'boardingPoint': widget.boardingPoint,
        'dropPoint': widget.dropPoint,
        'bookedAt': DateTime.now().toIso8601String(),
        'fromLat': r.fromCoords.latitude,
        'fromLng': r.fromCoords.longitude,
        'toLat': r.toCoords.latitude,
        'toLng': r.toCoords.longitude,
        'status': 'active',
      });

      // Update BusSeat — totalSeats is always fixed, only takenSeats grows
      final newTaken = {...takenSeats, ..._selected}.toList()..sort();
      final seatRef = db.collection('BusSeat').doc(_seatDocId);
      batch.set(
        seatRef,
        {
          'routeId': r.id,
          'busName': r.busName,
          'departureTime': r.departureTime,
          'totalSeats': totalBusSeats, 
          'takenSeats': newTaken,
          'seatsLeft': totalBusSeats - newTaken.length,
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TicketScreen(bookingId: bookingRef.id),
        ),
      );
    } catch (e) {
      setState(() => _booking = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

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
        title: const Text('Select Seats',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _seatStream,
        builder: (context, snapshot) {
          Set<int> takenSeats = {};
          // Use r.seatsLeft as fallback so real seat count shows before first booking
          int totalBusSeats = r.seatsLeft > 0 ? r.seatsLeft : 30;

          if (snapshot.hasData && snapshot.data!.exists) {
            final d = snapshot.data!.data() as Map<String, dynamic>;
            takenSeats = Set<int>.from(
                (d['takenSeats'] as List? ?? []).map((e) => e as int));
            // totalSeats is fixed — set once on first booking, never changes
            totalBusSeats = (d['totalSeats'] as num?)?.toInt() ?? totalBusSeats;
          }

          final availableCount =
              totalBusSeats - takenSeats.length - _selected.length;

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.blue,
                child: Column(
                  children: [
                    Text('${r.from}  →  ${r.to}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${r.departureTime}  |  ${r.busName}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      availableCount > 0
                          ? '$availableCount seat${availableCount == 1 ? "" : "s"} available'
                          : 'Bus is full',
                      style: TextStyle(
                          color: availableCount > 0
                              ? Colors.white60
                              : Colors.redAccent,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Legend
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legend(Colors.grey[200]!, Colors.grey[400]!, 'Available'),
                    const SizedBox(width: 20),
                    _legend(Colors.blue, Colors.blue, 'Selected'),
                    const SizedBox(width: 20),
                    _legend(Colors.red[100]!, Colors.red, 'Taken'),
                  ],
                ),
              ),

              // Driver row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.person, color: Colors.orange, size: 14),
                          SizedBox(width: 4),
                          Text('Driver',
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Container(height: 1, color: Colors.grey[200])),
                    const Icon(Icons.directions_bus,
                        color: Colors.blue, size: 26),
                  ],
                ),
              ),

              // Seat grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: totalBusSeats,
                    itemBuilder: (_, i) {
                      final seatNum = i + 1;
                      final isTaken = takenSeats.contains(seatNum);
                      final isSelected = _selected.contains(seatNum);

                      final Color bg;
                      final Color border;
                      final Color textColor;

                      if (isTaken) {
                        bg = Colors.red[100]!;
                        border = Colors.red;
                        textColor = Colors.red;
                      } else if (isSelected) {
                        bg = Colors.blue;
                        border = Colors.blue;
                        textColor = Colors.white;
                      } else {
                        bg = Colors.grey[200]!;
                        border = Colors.grey[400]!;
                        textColor = Colors.black87;
                      }

                      return GestureDetector(
                        onTap: isTaken
                            ? null
                            : () => setState(() {
                                  if (isSelected) {
                                    _selected.remove(seatNum);
                                  } else {
                                    _selected.add(seatNum);
                                  }
                                }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: border, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_seat,
                                  size: 18, color: textColor),
                              const SizedBox(height: 2),
                              Text('$seatNum',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom confirm bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                color: Colors.white,
                child: Column(
                  children: [
                    if (_selected.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Seats: ${(_selected.toList()..sort()).join(", ")}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            Text(
                              '${(r.fare * _selected.length).toStringAsFixed(0)} RWF',
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_selected.isEmpty || _booking)
                            ? null
                            : () => _confirmBooking(takenSeats, totalBusSeats),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _booking
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(
                                _selected.isEmpty
                                    ? 'Select a seat'
                                    : 'Confirm ${_selected.length} Seat${_selected.length > 1 ? "s" : ""}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _legend(Color bg, Color border, String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
