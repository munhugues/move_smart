import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/scheduled_route.dart';
import 'select_bus_screen.dart';
import 'trip_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  void _planTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectBusScreen(
          from: _fromCtrl.text.trim(),
          to: _toCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(routesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, Traveller!',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900])),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.blue),
                          const SizedBox(width: 3),
                          Text('Kigali, Rwanda',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_outlined,
                            color: Colors.grey[700]),
                        onPressed: () {},
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue.withValues(alpha: 0.15),
                        child: const Icon(Icons.person,
                            color: Colors.blue, size: 20),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text('Plan. Ride. Arrive.',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 4),
              Text('Book your ride anywhere',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500])),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trip_origin,
                            color: Colors.blue, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _fromCtrl,
                            decoration: InputDecoration(
                              hintText: 'Your location',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        Icon(Icons.swap_vert,
                            color: Colors.grey[400], size: 20),
                      ],
                    ),
                    Divider(color: Colors.grey[100], height: 20),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _toCtrl,
                            decoration: InputDecoration(
                              hintText: 'Where are you going?',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _planTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Plan My Trip',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Recent trips label
              const Text('Recent Trips',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // All routes from Firestore
              routesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: Colors.red)),
                data: (routes) {
                  if (routes.isEmpty) {
                    return Text('No routes available',
                        style: TextStyle(color: Colors.grey[500]));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: routes.length,
                    itemBuilder: (_, i) => _RouteCard(route: routes[i]),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// One route card on the home screen
class _RouteCard extends StatelessWidget {
  final ScheduledRoute route;
  const _RouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TripDetailScreen(route: route)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus,
                  color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${route.from} → ${route.to}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text('${route.duration}  |  ${route.departureTime}',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 13, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
