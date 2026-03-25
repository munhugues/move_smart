import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/scheduled_route.dart';
import '../providers/app_providers.dart';
import 'live_map_screen.dart';

class TicketScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const TicketScreen({super.key, required this.bookingId});

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  bool _cancelling = false;

  Future<void> _cancelBooking(Map<String, dynamic> d) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
            'Are you sure? This booking will be permanently deleted and your seats released.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      // Permanently delete the booking document
      batch.delete(db.collection('Booking').doc(widget.bookingId));

      // Restore seats in BusSeat collection
      final routeId = d['routeId'] as String? ?? '';
      final depTime =
          (d['departureTime'] as String? ?? '').replaceAll(':', '-');
      final seatDocId = '${routeId}_$depTime';
      final seats =
          (d['seats'] as List? ?? []).map((e) => e as int).toSet();

      if (seats.isNotEmpty) {
        final seatRef = db.collection('BusSeat').doc(seatDocId);
        final seatSnap = await seatRef.get();
        if (seatSnap.exists) {
          final sd = seatSnap.data() as Map<String, dynamic>;
          final taken = Set<int>.from(
              (sd['takenSeats'] as List? ?? []).map((e) => e as int));
          taken.removeAll(seats);
          final total = (sd['totalSeats'] as num?)?.toInt() ?? 30;
          batch.update(seatRef, {
            'takenSeats': taken.toList()..sort(),
            'seatsLeft': total - taken.length,
          });
        }
      }

      await batch.commit();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled and deleted successfully.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      setState(() => _cancelling = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Cancel failed: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () =>
              Navigator.of(context).popUntil((r) => r.isFirst),
        ),
        title: const Text('Your Ticket',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Booking')
            .doc(widget.bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Doc is gone (deleted) — just show a spinner, popUntil handles navigation
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final d = snapshot.data!.data() as Map<String, dynamic>;
          final seats = (d['seats'] as List? ?? [])
              .map((e) => e.toString())
              .toList();
          final seatCount =
              (d['seatCount'] as num?)?.toInt() ?? seats.length;
          final fare = (d['fare'] as num?)?.toDouble() ?? 0;
          final farePerSeat =
              (d['farePerSeat'] as num?)?.toDouble() ?? fare;
          final shortCode =
              widget.bookingId.substring(0, 8).toUpperCase();
          final passengerName =
              d['passengerName'] as String? ?? 'Passenger';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Success banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.white, size: 44),
                      SizedBox(height: 8),
                      Text('Booking Confirmed!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Ticket card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 12)
                    ],
                  ),
                  child: Column(
                    children: [
                      // Blue header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text('MOVE SMART — BUS TICKET',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(d['from'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Icon(Icons.arrow_forward,
                                      color: Colors.white70, size: 20),
                                ),
                                Flexible(
                                  child: Text(d['to'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _headerInfo('Departs',
                                    d['departureTime'] ?? '--'),
                                _headerInfo(
                                    'Arrives', d['arrivalTime'] ?? '--'),
                                _headerInfo(
                                    'Duration', d['duration'] ?? '--'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Detail rows
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _row('Passenger', passengerName),
                            _divider(),
                            _row('Bus', d['busName'] ?? '--'),
                            _divider(),
                            _row('Bus ID', d['routeId'] ?? '--',
                                color: Colors.grey),
                            _divider(),
                            _row('Type', d['busType'] ?? '--'),
                            _divider(),
                            _row('Boarding', d['boardingPoint'] ?? '--'),
                            _divider(),
                            _row('Drop Point', d['dropPoint'] ?? '--'),
                            _divider(),
                            _row(
                              'Seat${seatCount > 1 ? "s" : ""}',
                              seats.isEmpty ? '--' : seats.join(', '),
                              bold: true,
                            ),
                            _divider(),
                            _row('Fare/Seat',
                                'RWF ${farePerSeat.toStringAsFixed(0)}'),
                            _divider(),
                            _row(
                              'Total Fare',
                              'RWF ${fare.toStringAsFixed(0)}',
                              bold: true,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),

                      // Dashed separator
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: List.generate(
                            30,
                            (i) => Expanded(
                              child: Container(
                                height: 1,
                                color: i.isEven
                                    ? Colors.grey[300]
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Show to driver
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const Text('SHOW TO DRIVER',
                                style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 2,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    shortCode,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${d['from']} → ${d['to']}',
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Seat${seatCount > 1 ? "s" : ""}: ${seats.join(", ")}  |  ${d['departureTime'] ?? ""}',
                                    style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Booking ID: $shortCode',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Track Bus
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final route = ScheduledRoute(
                        id: d['routeId'] ?? '',
                        from: d['from'] ?? '',
                        to: d['to'] ?? '',
                        departureTime: d['departureTime'] ?? '',
                        arrivalTime: d['arrivalTime'] ?? '',
                        busName: d['busName'] ?? '',
                        busType: d['busType'] ?? '',
                        fare: fare,
                        seatsLeft: 0,
                        duration: d['duration'] ?? '',
                        fromCoords: LatLng(
                          (d['fromLat'] as num?)?.toDouble() ?? -1.9441,
                          (d['fromLng'] as num?)?.toDouble() ?? 30.0619,
                        ),
                        toCoords: LatLng(
                          (d['toLat'] as num?)?.toDouble() ?? -1.9536,
                          (d['toLng'] as num?)?.toDouble() ?? 30.1127,
                        ),
                        routePoints: const [],
                      );
                      ref.read(tripProvider.notifier).startTrip(route);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveMapScreen(route: route),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Track Bus',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel booking — deletes from Firestore
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed:
                        _cancelling ? null : () => _cancelBooking(d),
                    icon: _cancelling
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.red))
                        : const Icon(Icons.cancel_outlined,
                            color: Colors.red),
                    label: const Text('Cancel Booking',
                        style:
                            TextStyle(color: Colors.red, fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Home',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _headerInfo(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ],
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        bold ? FontWeight.bold : FontWeight.w500,
                    color: color ?? Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey[100]);
}
