import 'dart:math';
import '../models/models.dart';

/// The two inner planets modelled by this application.
enum Planet { mercury, venus }

extension PlanetLabel on Planet {
  String get name => this == Planet.mercury ? 'Mercury' : 'Venus';

  String get symbol => this == Planet.mercury ? 'M' : 'V';
}

/// Calculation mode selector.
///
/// [heritage] is a faithful port of the original 1982 BASIC formulas and
/// epoch. [modern] uses J2000.0-based Keplerian orbital elements computed with
/// a Newton–Raphson solve of Kepler's equation.
enum CalculationMode { heritage, modern }

/// Common interface describing a planetary position engine.
abstract class AstronomyCalculator {
  PlanetData calculate(DateTime date, Planet planet);

  /// Finds the date of the next maximum elongation (angular separation from
  /// the Sun) of [planet] after [startDate], using an iterative search.
  DateTime findNextElongation({
    required DateTime startDate,
    required Planet planet,
  }) {
    var current = DateTime(startDate.year, startDate.month, startDate.day);
    double previousElongation = 0;
    bool initialised = false;

    for (int i = 0; i < 1000; i++) {
      final data = calculate(current, planet);
      final elongation = data.angularDistFromSun.abs();

      if (!initialised) {
        final jump = planet == Planet.mercury ? 5 : 10;
        current = DateTime(current.year, current.month, current.day + jump);
        previousElongation = elongation;
        initialised = true;
        continue;
      }

      final difference = elongation - previousElongation;
      if (difference.abs() < 0.05) {
        return current;
      }

      final useLargeStep =
          elongation < (planet == Planet.mercury ? 15 : 40);
      final step = useLargeStep
          ? (planet == Planet.mercury ? 5 : 10)
          : 1;

      current = DateTime(current.year, current.month, current.day + step);
      previousElongation = elongation;
    }
    return current;
  }
}

/// Faithful Dart port of the original 1982 MERVE.BAS / MVENC.BAS formulas
/// (Eric Burgess F.R.A.S., S & T Software Service). Uses an epoch of 1960
/// and the same simplified trigonometric approximations as the original.
class HeritageCalculator extends AstronomyCalculator {
  static const double p1 = pi;
  static const double p2 = 2 * pi;

  @override
  PlanetData calculate(DateTime date, Planet planet) {
    final y = date.year;
    final m = date.month;
    final d = date.day;

    // 1480-1570: Days from epoch
    double dg = 365.0 * y + d + ((m - 1) * 31);
    if (m >= 3) {
      dg = dg -
          (m * 0.4 + 2.3).floor() +
          (y / 4).floor() -
          (0.75 * (y / 100).floor() + 1).floor();
    } else {
      dg = dg +
          ((y - 1) / 4).floor() -
          (0.75 * ((y - 1) / 100 + 1).floor()).floor();
    }
    final ni = dg - 715875;

    // 1050-1120: Earth position
    double ae = ni * 0.017202 + 1.74022;
    ae = _normalizeAngle(ae);
    double ce = 0.032044 * sin(ae - 1.78547);
    ae = _normalizeAngle(ae + ce);
    double de = 1 + 0.017 * sin(ae - 3.33926);

    if (planet == Planet.mercury) {
      return _calculateMercury(date, ni, ae, de);
    } else {
      return _calculateVenus(date, ni, ae, de);
    }
  }

  PlanetData _calculateMercury(DateTime date, double ni, double ae, double de) {
    // 1600-1670: Mercury position
    double ma = ni * 0.071425 + 3.8494;
    ma = _normalizeAngle(ma);
    double mc = 0.388301 * sin(ma - 1.34041);
    ma = _normalizeAngle(ma + mc);
    double md = 0.3871 + 0.079744 * sin(ma - 2.73514);

    double mz = ae - ma;
    double zm = mz;
    mz = _adjustRange(mz);

    // 1190: Dist from Earth
    double mq = sqrt(pow(md, 2) + pow(de, 2) - 2 * md * de * cos(mz));

    // 1220: Ang dist from Sun
    double mp = (md + de + mq) / 2;
    double mv = sqrt((mp * (mp - md)) / (de * mq));
    double mw = 2 * acos(mv);

    zm = _adjustRange(zm);
    if (zm > 0) mw = -mw;

    // 2710-2790: Viewing favorability
    String favorability = _getMercuryFavorability(mw * 57.29578, date.month);

    // 2520-2600: Phase
    double phValue = 180 - (mw.abs() + mz.abs()) * 57.2958;
    String phaseName = _getPhaseName(phValue);
    double illumination = 180 - phValue;

    return PlanetData(
      date: date,
      planet: Planet.mercury,
      distanceSun: md,
      distanceEarth: mq,
      angularDistFromSun: mw * 57.29578,
      angularDiameter: 6.68 / mq,
      illumination: illumination,
      phaseName: phaseName,
      viewingFavorability: favorability,
    );
  }

  PlanetData _calculateVenus(DateTime date, double ni, double ae, double de) {
    // 1700-1770: Venus position
    double va = ni * 0.027962 + 3.02812;
    va = _normalizeAngle(va);
    double vc = 0.013195 * sin(va - 2.28638);
    va = _normalizeAngle(va + vc);
    double vd = 0.7233 + 0.00506 * sin(va - 3.85017);

    double zv = ae - va;
    double vz = zv;
    zv = _adjustRange(zv);

    // 1830: Dist from Earth
    double vq = sqrt(pow(vd, 2) + pow(de, 2) - 2 * vd * de * cos(zv));

    // 1860: Ang dist from Sun
    double vp = (vd + de + vq) / 2;
    double vv = sqrt((vp * (vp - vd)) / (de * vq));
    double vw = 2 * acos(vv);

    vz = _adjustRange(vz);
    if (vz > 0) vw = -vw;

    // Phase
    double phValue = 180 - (vw.abs() + zv.abs()) * 57.2958;
    String phaseName = _getPhaseName(phValue);
    double illumination = 180 - phValue;

    return PlanetData(
      date: date,
      planet: Planet.venus,
      distanceSun: vd,
      distanceEarth: vq,
      angularDistFromSun: vw * 57.29578,
      angularDiameter: 16.82 / vq,
      illumination: illumination,
      phaseName: phaseName,
      viewingFavorability: "",
    );
  }

  double _normalizeAngle(double angle) {
    double res = angle % p2;
    if (res < 0) res += p2;
    return res;
  }

  double _adjustRange(double angle) {
    if (angle.abs() > p1) {
      if (angle < 0) return angle + p2;
      return angle - p2;
    }
    return angle;
  }

  String _getPhaseName(double ph) {
    if (ph > 150) return "THIN CRESCENT";
    if (ph > 120) return "FAT CRESCENT";
    if (ph > 70) return "NEAR HALF";
    if (ph > 29) return "GIBBOUS";
    return "NEAR FULL";
  }

  String _getMercuryFavorability(double mx, int month) {
    if (mx > 13 && month > 7 && month < 12) return "UNFAVORABLY";
    if (mx > 18 && month > 7 && month < 12) return "VERY UNFAVORABLY";
    if (mx < -13 && month > 1 && month < 7) return "FAVORABLY";
    if (mx < -18 && month > 1 && month < 7) return "VERY FAVORABLY";
    return "UNFAVORABLY";
  }
}

/// Modern, high-precision engine using J2000.0 epoch Keplerian orbital
/// elements for Mercury, Venus and Earth. Kepler's equation is solved with
/// five Newton–Raphson iterations and full 3D heliocentric coordinates are
/// computed.
class ModernCalculator extends AstronomyCalculator {
  static const double degToRad = pi / 180.0;
  static const double radToDeg = 180.0 / pi;

  @override
  PlanetData calculate(DateTime date, Planet planet) {
    // Julian Date for the given date at 0h UT
    final jd = _calculateJulianDate(date);
    // Centuries since J2000.0
    final t = (jd - 2451545.0) / 36525.0;

    // Orbital elements for Earth
    final earthElements = _getEarthElements(t);
    final earthPos = _calculatePosition(earthElements);

    final planetElements = planet == Planet.mercury
        ? _getMercuryElements(t)
        : _getVenusElements(t);
    final planetPos = _calculatePosition(planetElements);

    // Heliocentric coordinates
    final dx = planetPos.x - earthPos.x;
    final dy = planetPos.y - earthPos.y;
    final dz = planetPos.z - earthPos.z;

    final distEarth =
        sqrt(dx * dx + dy * dy + dz * dz);
    final distSun = sqrt(planetPos.x * planetPos.x +
        planetPos.y * planetPos.y +
        planetPos.z * planetPos.z);
    final distEarthSun = sqrt(earthPos.x * earthPos.x +
        earthPos.y * earthPos.y +
        earthPos.z * earthPos.z);

    // Angular distance from Sun (elongation)
    final cosElong = (distEarthSun * distEarthSun +
            distEarth * distEarth -
            distSun * distSun) /
        (2 * distEarthSun * distEarth);
    double elong = acos(cosElong.clamp(-1.0, 1.0)) * radToDeg;

    // Determine if East or West elongation (simplified: cross product sign)
    final crossZ = (-earthPos.x * dx) - (-earthPos.y * dy);
    if (crossZ < 0) elong = -elong;

    // Phase angle phi: angle Earth-Planet-Sun
    final cosPhi = (distSun * distSun +
            distEarth * distEarth -
            distEarthSun * distEarthSun) /
        (2 * distSun * distEarth);
    final phi = acos(cosPhi.clamp(-1.0, 1.0));
    final illumination = (1 + cos(phi)) / 2 * 100;

    final phaseName = _getPhaseName(illumination);
    final angularDiameter = (planet == Planet.mercury ? 6.73 : 16.92) /
        distEarth;

    String favorability = "";
    if (planet == Planet.mercury) {
      favorability = _getMercuryFavorability(elong, date.month);
    }

    return PlanetData(
      date: date,
      planet: planet,
      distanceSun: distSun,
      distanceEarth: distEarth,
      angularDistFromSun: elong,
      angularDiameter: angularDiameter,
      illumination: illumination,
      phaseName: phaseName,
      viewingFavorability: favorability,
    );
  }

  double _calculateJulianDate(DateTime date) {
    int y = date.year;
    int m = date.month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        date.day +
        b -
        1524.5;
  }

  _OrbitalElements _getEarthElements(double t) {
    return _OrbitalElements(
      a: 1.00000011 + 0.00000005 * t,
      e: 0.01671022 - 0.00004204 * t,
      i: 0.00005 * degToRad,
      l: (100.46435 + 35999.37242 * t) * degToRad,
      w: (102.94719 + 0.32327 * t) * degToRad,
      node: 0.0,
    );
  }

  _OrbitalElements _getMercuryElements(double t) {
    return _OrbitalElements(
      a: 0.38709893 + 0.00000066 * t,
      e: 0.20563069 + 0.00002527 * t,
      i: (7.00487 - 0.00594 * t) * degToRad,
      l: (252.25084 + 149472.67411 * t) * degToRad,
      w: (77.45645 + 0.16213 * t) * degToRad,
      node: (48.33167 - 0.12534 * t) * degToRad,
    );
  }

  _OrbitalElements _getVenusElements(double t) {
    return _OrbitalElements(
      a: 0.72333199 + 0.00000092 * t,
      e: 0.00677323 - 0.00004938 * t,
      i: (3.39471 - 0.00079 * t) * degToRad,
      l: (181.97973 + 58517.81538 * t) * degToRad,
      w: (131.53298 + 0.00213 * t) * degToRad,
      node: (76.68069 - 0.27769 * t) * degToRad,
    );
  }

  _Vector3 _calculatePosition(_OrbitalElements el) {
    final m = el.l - el.w;
    double e = m;
    for (int j = 0; j < 5; j++) {
      e = e - (e - el.e * sin(e) - m) / (1 - el.e * cos(e));
    }

    final x1 = el.a * (cos(e) - el.e);
    final y1 = el.a * sqrt(1 - el.e * el.e) * sin(e);

    final w1 = el.w - el.node;
    final x2 = x1 * cos(w1) - y1 * sin(w1);
    final y2 = x1 * sin(w1) + y1 * cos(w1);

    final x = x2 * cos(el.node) - y2 * sin(el.node) * cos(el.i);
    final y = x2 * sin(el.node) + y2 * cos(el.node) * cos(el.i);
    final z = y2 * sin(el.i);

    return _Vector3(x, y, z);
  }

  String _getPhaseName(double illumination) {
    if (illumination < 10) return "THIN CRESCENT";
    if (illumination < 40) return "FAT CRESCENT";
    if (illumination < 60) return "NEAR HALF";
    if (illumination < 90) return "GIBBOUS";
    return "NEAR FULL";
  }

  String _getMercuryFavorability(double elong, int month) {
    final absElong = elong.abs();
    if (elong > 0) {
      if (absElong > 18 && month > 7 && month < 12) return "VERY UNFAVORABLY";
      if (absElong > 13 && month > 7 && month < 12) return "UNFAVORABLY";
    } else {
      if (absElong > 18 && month > 1 && month < 7) return "VERY FAVORABLY";
      if (absElong > 13 && month > 1 && month < 7) return "FAVORABLY";
    }
    return "NEUTRAL";
  }
}

class _OrbitalElements {
  final double a, e, i, l, w, node;

  _OrbitalElements({
    required this.a,
    required this.e,
    required this.i,
    required this.l,
    required this.w,
    required this.node,
  });
}

class _Vector3 {
  final double x, y, z;

  _Vector3(this.x, this.y, this.z);
}