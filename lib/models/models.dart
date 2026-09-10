import '../logic/astronomy_engine.dart';

/// Planetary data produced by one of the calculation engines.
///
/// All angles are in degrees. Elongation angles are negative when the
/// planet lies East of the Sun (an Evening Star) and positive when it lies
/// West of the Sun (a Morning Star).
class PlanetData {
  final DateTime date;
  final Planet planet;

  /// Heliocentric distance from the Sun in Astronomical Units.
  final double distanceSun;

  /// Geocentric distance from Earth in Astronomical Units.
  final double distanceEarth;

  /// Angular distance (elongation) of the planet from the Sun in degrees.
  /// Negative values indicate the planet is East of the Sun (Evening Star).
  final double angularDistFromSun;

  /// Apparent angular diameter in arcseconds.
  final double angularDiameter;

  /// Fraction of the planet's disk illuminated, as a percentage (0-100).
  final double illumination;

  /// Human-readable phase name: THIN CRESCENT, FAT CRESCENT, NEAR HALF,
  /// GIBBOUS, or NEAR FULL.
  final String phaseName;

  /// Viewing favorability for Mercury (seasonally dependent).
  final String viewingFavorability;

  PlanetData({
    required this.date,
    required this.planet,
    required this.distanceSun,
    required this.distanceEarth,
    required this.angularDistFromSun,
    required this.angularDiameter,
    required this.illumination,
    required this.phaseName,
    required this.viewingFavorability,
  });

  /// Distance from Earth in millions of miles (1 A.U. = 92.9 million miles).
  double get distanceEarthMiles => distanceEarth * 92.9;

  /// Human-readable position of the planet relative to the Sun.
  String get positionRelativeToSun => angularDistFromSun < 0
      ? 'East of Sun (Evening Star)'
      : 'West of Sun (Morning Star)';
}