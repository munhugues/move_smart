import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

// Simple distance formula between two GPS points
double km(LatLng a, LatLng b) {
  const r = 6371.0;
  double rad(double d) => d * pi / 180;
  final dLat = rad(b.latitude - a.latitude);
  final dLng = rad(b.longitude - a.longitude);
  final h = sin(dLat / 2) * sin(dLat / 2) +
      cos(rad(a.latitude)) * cos(rad(b.latitude)) *
          sin(dLng / 2) * sin(dLng / 2);
  return r * 2 * atan2(sqrt(h), sqrt(1 - h));
}

void main() {
  // Two real Kigali locations
  const nyabugogo = LatLng(-1.9441, 30.0619);
  const remera    = LatLng(-1.9536, 30.1127);

  test('same point = 0 km', () {
    expect(km(nyabugogo, nyabugogo), closeTo(0.0, 0.001));
  });

  test('Nyabugogo to Remera is between 4 and 15 km', () {
    final d = km(nyabugogo, remera);
    expect(d, greaterThan(4.0));
    expect(d, lessThan(15.0));
  });

  test('distance A→B equals B→A', () {
    expect(km(nyabugogo, remera), closeTo(km(remera, nyabugogo), 0.001));
  });
}
