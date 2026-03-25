import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../providers/app_providers.dart';
import '../models/scheduled_route.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  final ScheduledRoute route;
  const LiveMapScreen({super.key, required this.route});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _polyline = [];
  LatLng? _fromCoords;
  LatLng? _toCoords;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveAndFetch();
  }

  /// Geocode a place name to LatLng using Nominatim
  Future<LatLng?> _geocode(String place) async {
    try {
      final query = Uri.encodeComponent('$place, Kigali, Rwanda');
      final url =
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';
      final res = await http.get(Uri.parse(url),
          headers: {'User-Agent': 'MoveSmart/1.0'});
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty) {
          return LatLng(
            double.parse(list[0]['lat'] as String),
            double.parse(list[0]['lon'] as String),
          );
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _resolveAndFetch() async {
    final r = widget.route;

    // If Firestore has routePoints use them directly
    if (r.routePoints.length >= 2) {
      setState(() {
        _fromCoords = r.routePoints.first;
        _toCoords = r.routePoints.last;
        _polyline = r.routePoints;
        _loading = false;
      });
      return;
    }

    // Geocode the from and to place names
    final fromResult = await _geocode(r.from);
    final toResult = await _geocode(r.to);

    if (!mounted) return;

    if (fromResult == null || toResult == null) {
      setState(() {
        _error =
            'Could not find location for "${fromResult == null ? r.from : r.to}"';
        _loading = false;
      });
      return;
    }

    setState(() {
      _fromCoords = fromResult;
      _toCoords = toResult;
    });

    // Fetch road polyline from OSRM between the geocoded coords
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/${fromResult.longitude},${fromResult.latitude};${toResult.longitude},${toResult.latitude}?overview=full&geometries=geojson';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final routes = json['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final coords =
              (routes[0]['geometry']['coordinates'] as List)
                  .map((c) => LatLng(
                      (c[1] as num).toDouble(),
                      (c[0] as num).toDouble()))
                  .toList();
          if (mounted) setState(() => _polyline = coords);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _polyline = [fromResult, toResult]);
    }

    if (mounted) {
      setState(() => _loading = false);
      // Fit map to show both markers
      if (_fromCoords != null && _toCoords != null) {
        final bounds = LatLngBounds.fromPoints([_fromCoords!, _toCoords!]);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripProvider);
    final userLoc = trip?.userLocation;

    // Default center to Kigali while loading
    final center = _fromCoords ?? const LatLng(-1.9441, 30.0619);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: center, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.move_smart',
              ),
              if (_polyline.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polyline,
                      color: Colors.blue,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // From marker — green label + pin
                  if (_fromCoords != null)
                    Marker(
                      point: _fromCoords!,
                      width: 130,
                      height: 64,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Text(
                              widget.route.from,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Icon(Icons.location_pin,
                              color: Colors.green, size: 28),
                        ],
                      ),
                    ),
                  // User location — blue dot
                  if (userLoc != null)
                    Marker(
                      point: userLoc,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.4),
                                blurRadius: 8)
                          ],
                        ),
                      ),
                    ),
                  // To marker — red label + pin
                  if (_toCoords != null)
                    Marker(
                      point: _toCoords!,
                      width: 130,
                      height: 64,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Text(
                              widget.route.to,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Icon(Icons.location_pin,
                              color: Colors.red, size: 28),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Loading overlay
          if (_loading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        'Finding ${widget.route.from} → ${widget.route.to}...',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Error overlay
          if (_error != null)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off,
                          color: Colors.red, size: 40),
                      const SizedBox(height: 12),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _error = null;
                            _loading = true;
                          });
                          _resolveAndFetch();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _iconBtn(Icons.arrow_back, () {
                      ref.read(tripProvider.notifier).endTrip();
                      Navigator.pop(context);
                    }),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_bus,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '${widget.route.from}  →  ${widget.route.to}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _iconBtn(Icons.my_location, () {
                      if (userLoc != null) {
                        _mapController.move(userLoc, 15);
                      } else if (_fromCoords != null) {
                        _mapController.move(_fromCoords!, 14);
                      }
                    }, color: Colors.blue),
                  ],
                ),
              ),
            ),
          ),

          // Bottom card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(tripProvider.notifier).endTrip();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              trip?.locationReady == true
                                  ? '${trip!.etaMinutes} Min'
                                  : '-- Min',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trip?.locationReady == true
                              ? '${trip!.distanceKm.toStringAsFixed(1)} km  |  ${widget.route.departureTime}'
                              : '${widget.route.from} → ${widget.route.to}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_fromCoords != null && _toCoords != null) {
                        final bounds = LatLngBounds.fromPoints(
                            [_fromCoords!, _toCoords!]);
                        _mapController.fitCamera(CameraFit.bounds(
                            bounds: bounds,
                            padding: const EdgeInsets.all(60)));
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fit_screen,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
