import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'core.dart';

/// Puntos de la ruta (en una cuadrícula de 400x520, calles cada 34 px).
const tripPts = <Offset>[
  Offset(34, 476), Offset(34, 408), Offset(102, 408), Offset(102, 340), Offset(136, 340), Offset(136, 306), // A (recogida)
  Offset(136, 272), Offset(204, 272), Offset(204, 204), Offset(272, 204), Offset(272, 170), Offset(340, 170), Offset(340, 136), Offset(340, 102),
];
const aIdx = 5;

/// Dónde se dibuja la ruta dentro del mapa: left/top en fracción del tamaño, scale = ancho de la ruta (400u) en fracción del ancho.
class MapFrame {
  final double left, top, scale, lake;
  const MapFrame({this.left = .0, this.top = .1, this.scale = 1, this.lake = .12});
}

class TripMap extends StatelessWidget {
  final MapFrame frame;
  final double progress;
  final bool onlyAB, showRoute, showVehicle;
  const TripMap({super.key, this.frame = const MapFrame(), this.progress = 0, this.onlyAB = false, this.showRoute = true, this.showVehicle = true});
  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      RepaintBoundary(child: CustomPaint(painter: _BasePainter(frame))),
      CustomPaint(painter: _RoutePainter(frame, progress, onlyAB, showRoute, showVehicle)),
    ]);
  }
}

class _Geo {
  final double s, ox, oy, g;
  _Geo(Size size, MapFrame f)
      : s = size.width * f.scale / 400,
        ox = size.width * f.left,
        oy = size.height * f.top,
        g = size.width * f.scale / 400 * 34;
  Offset pt(Offset p) => Offset(ox + p.dx * s, oy + p.dy * s);
}

class _BasePainter extends CustomPainter {
  final MapFrame f;
  _BasePainter(this.f);
  @override
  void paint(Canvas c, Size size) {
    final geo = _Geo(size, f);
    final rnd = math.Random(7);
    final rect = Offset.zero & size;
    // tierra
    c.drawRect(rect, Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(size.width, size.height), const [Color(0xFF2A6A54), Color(0xFF205646), Color(0xFF173F37)], const [0, .6, 1]));
    // manchas de bosque
    for (int i = 0; i < 70; i++) {
      final o = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
      c.drawCircle(o, 20 + rnd.nextDouble() * 60, Paint()
        ..color = a(const Color(0xFF0E3329), .25 + rnd.nextDouble() * .25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    }
    // ciudad
    final center = Offset(size.width * .45, size.height * .58);
    final cr = size.longestSide * .5;
    c.drawCircle(center, cr, Paint()..shader = ui.Gradient.radial(center, cr, [a(const Color(0xFF1C2F63), .85), a(const Color(0xFF1C2F63), .55), a(const Color(0xFF1C2F63), 0)], const [0, .6, 1]));
    final half = geo.g / 2;
    double startX = geo.ox % half, startY = geo.oy % half;
    for (double x = startX; x <= size.width; x += half) {
      _fadeLine(c, Offset(x + (rnd.nextDouble() - .5) * 3, 0), Offset(x + (rnd.nextDouble() - .5) * 6, size.height), center, cr, .32, .8);
    }
    for (double y = startY; y <= size.height; y += half) {
      _fadeLine(c, Offset(0, y + (rnd.nextDouble() - .5) * 3), Offset(size.width, y + (rnd.nextDouble() - .5) * 6), center, cr, .32, .8);
    }
    // calles principales sobre la cuadrícula de la ruta
    startX = geo.ox % geo.g;
    startY = geo.oy % geo.g;
    for (double x = startX; x <= size.width; x += geo.g) {
      final major = ((x - geo.ox) / geo.g).round() % 4 == 0;
      c.drawLine(Offset(x, 0), Offset(x, size.height), Paint()
        ..color = a(const Color(0xFFB9C6FF), major ? .42 : .15)
        ..strokeWidth = major ? 1.8 : .9);
    }
    for (double y = startY; y <= size.height; y += geo.g) {
      final major = ((y - geo.oy) / geo.g).round() % 4 == 0;
      c.drawLine(Offset(0, y), Offset(size.width, y), Paint()
        ..color = a(const Color(0xFFB9C6FF), major ? .42 : .15)
        ..strokeWidth = major ? 1.8 : .9);
    }
    // avenidas curvas
    final av = Paint()
      ..style = PaintingStyle.stroke
      ..color = a(const Color(0xFFDFE5FF), .45)
      ..strokeWidth = 2.4;
    c.drawPath(Path()
      ..moveTo(-20, size.height * .8)
      ..cubicTo(size.width * .3, size.height * .72, size.width * .5, size.height * .95, size.width + 20, size.height * .66), av);
    c.drawPath(Path()
      ..moveTo(size.width * .64, -10)
      ..cubicTo(size.width * .56, size.height * .4, size.width * .82, size.height * .6, size.width * .72, size.height + 10), av);
    // lago
    final lh = size.height * f.lake;
    final lake = Path()..moveTo(size.width * .12, -10)..lineTo(size.width + 10, -10)..lineTo(size.width + 10, lh * 1.4);
    for (double x = size.width; x >= size.width * .2; x -= size.width / 10) {
      lake.quadraticBezierTo(x - size.width / 20, lh * (.7 + rnd.nextDouble() * .7), x - size.width / 10, lh * (.5 + rnd.nextDouble() * .6));
    }
    lake.close();
    c.drawPath(lake, Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(0, lh * 1.5), const [Color(0xFF0B2FA0), Color(0xFF0A2585)]));
    c.drawPath(lake, Paint()
      ..style = PaintingStyle.stroke
      ..color = a(const Color(0xFF2F5FD0), .6)
      ..strokeWidth = 2);
    _label(c, 'Lago Xolotlán', Offset(size.width * .66, lh * .5), italic: true);
    _label(c, 'BOLONIA', Offset(size.width * .2, size.height * .36));
    _label(c, 'LOS ROBLES', Offset(size.width * .22, size.height * .62));
    _label(c, 'VILLA FONTANA', Offset(size.width * .74, size.height * .44));
    _label(c, 'ALTAMIRA', Offset(size.width * .5, size.height * .82));
  }

  void _fadeLine(Canvas c, Offset p1, Offset p2, Offset center, double r, double maxO, double w) {
    const n = 24;
    for (int i = 0; i < n; i++) {
      final s = Offset.lerp(p1, p2, i / n)!, e = Offset.lerp(p1, p2, (i + 1) / n)!;
      final d = ((s + e) / 2 - center).distance / r;
      final o = (1 - d).clamp(0.0, 1.0) * maxO;
      if (o < .02) continue;
      c.drawLine(s, e, Paint()
        ..color = a(const Color(0xFFAAB8FF), o)
        ..strokeWidth = w);
    }
  }

  void _label(Canvas c, String t, Offset at, {bool italic = false}) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: tx(10, w: FontWeight.w700, c: a(Colors.white, .55)).copyWith(letterSpacing: italic ? 0 : 1.2, fontStyle: italic ? FontStyle.italic : FontStyle.normal)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BasePainter old) => old.f != f;
}

class _RoutePainter extends CustomPainter {
  final MapFrame f;
  final double p;
  final bool onlyAB, showRoute, showVeh;
  _RoutePainter(this.f, this.p, this.onlyAB, this.showRoute, this.showVeh);

  @override
  void paint(Canvas c, Size size) {
    final geo = _Geo(size, f);
    final pts = tripPts.map(geo.pt).toList();
    final A = pts[aIdx], B = pts.last;
    final used = onlyAB ? pts.sublist(aIdx) : pts;
    final path = Path()..moveTo(used.first.dx, used.first.dy);
    for (final q in used.skip(1)) {
      path.lineTo(q.dx, q.dy);
    }
    final m = path.computeMetrics().first;
    final L = m.length;
    final prog = onlyAB ? 0.0 : p;
    if (showRoute) {
      final rest = m.extractPath(L * prog, L);
      c.drawPath(rest, Paint()
        ..style = PaintingStyle.stroke
        ..color = a(const Color(0xFF2F86FF), .5)
        ..strokeWidth = 16
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
      c.drawPath(rest, Paint()
        ..style = PaintingStyle.stroke
        ..shader = ui.Gradient.linear(pts.first, B, const [Color(0xFF2F86FF), Color(0xFF6CB8FF)])
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round);
      final dash = Paint()
        ..style = PaintingStyle.stroke
        ..color = a(const Color(0xFFE3F1FF), .85)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (double d = L * prog; d < L; d += 8) {
        final tg = m.getTangentForOffset(d);
        if (tg != null) c.drawCircle(tg.position, .9, dash);
      }
    }
    _pin(c, A, Icons.home_rounded);
    if (showRoute) _pin(c, B, Icons.flag_rounded);
    if (showVeh && !onlyAB) {
      final tg = m.getTangentForOffset(L * p);
      if (tg != null) {
        final o = tg.position;
        c.drawCircle(o, 22, Paint()..color = a(K.blue, .22));
        c.drawCircle(o, 14, Paint()..color = Colors.white);
        c.drawCircle(o, 11, Paint()..color = K.blue);
        _icon(c, o, Icons.close_rounded, 15);
      }
    }
  }

  void _pin(Canvas c, Offset o, IconData i) {
    c.drawCircle(o, 22, Paint()..color = a(K.blue, .25));
    c.drawCircle(o, 16, Paint()..color = K.blue);
    c.drawCircle(o, 16, Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2);
    _icon(c, o, i, 17);
  }

  void _icon(Canvas c, Offset o, IconData i, double s) {
    final tp = TextPainter(
      text: TextSpan(text: String.fromCharCode(i.codePoint), style: TextStyle(fontSize: s, fontFamily: i.fontFamily, package: i.fontPackage, color: Colors.white)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, o - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.p != p || old.showRoute != showRoute || old.f != f;
}
