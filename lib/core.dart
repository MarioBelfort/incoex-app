import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// ───────────────────────── Colores y texto ─────────────────────────
class K {
  static const blue = Color(0xFF1E6BFF);
  static const blue2 = Color(0xFF2A79FF);
  static const navy = Color(0xFF020A2A);
  static const ice = Color(0xFF9FD0FF);
  static const yellow = Color(0xFFFFC53D);
  static const green = Color(0xFF22C55E);
  static const purple = Color(0xFF7B3CFF);
  static const red = Color(0xFFC52845);
  static const label = Color(0xFF9FB6FF);
}

TextStyle tx(double size, {FontWeight w = FontWeight.w600, Color c = Colors.white, double? h}) =>
    TextStyle(fontFamily: 'Figtree', fontSize: size, fontWeight: w == FontWeight.w900 ? FontWeight.w800 : w, color: c, height: h);

Color a(Color c, double o) => c.withValues(alpha: o);

String fmt(num n) {
  final s = n.round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return 'C\$ $b';
}

// ───────────────────────── Datos ─────────────────────────
class Veh {
  final String id, name, sub, cap, model, color, plate, driver, img;
  final int eta, lvl;
  const Veh(this.id, this.name, this.sub, this.cap, this.model, this.color, this.plate, this.driver, this.eta, this.lvl, this.img);
}

const vehicles = [
  Veh('moto', 'Moto', 'Envíos pequeños', 'Hasta 20 kg', 'Genesis HJ150S', 'Azul', 'M 149-281', 'Carlos Mendoza', 4, 0, 'assets/img/moto.webp'),
  Veh('auto', 'Auto', 'Espacios medianos', 'Hasta 120 kg', 'Toyota Corolla', 'Azul INCOEX', 'M 220-417', 'Ana Lucía Pérez', 6, 1, 'assets/img/car.webp'),
  Veh('pickup', 'Pickup', 'Electrodomésticos', 'Hasta 900 kg', 'Toyota Hilux', 'Azul', 'M 318-905', 'Javier Ortega', 9, 2, 'assets/img/pickup.png'),
  Veh('camion', 'Camión', 'Mudanzas y mercadería', 'Hasta 5 t', 'Isuzu FVR', 'Azul', 'C 052-118', 'Roberto Silva', 15, 3, 'assets/img/truck.webp'),
];
Veh vehById(String id) => vehicles.firstWhere((v) => v.id == id);

class Cargo {
  final String id, name, note;
  final IconData icon;
  final int lvl, kg;
  const Cargo(this.id, this.name, this.icon, this.lvl, this.kg, [this.note = '']);
}

const cargos = [
  Cargo('doc', 'Documentos', Icons.description_outlined, 0, 1),
  Cargo('paq', 'Paquete pequeño', Icons.inventory_2_outlined, 0, 3),
  Cargo('flor', 'Arreglo floral', Icons.local_florist_outlined, 1, 4, 'Los arreglos florales viajan en auto para que lleguen intactos.'),
  Cargo('pastel', 'Pastel / comida', Icons.cake_outlined, 1, 3, 'Pasteles y bandejas viajan en auto, en superficie plana.'),
  Cargo('tv', 'TV hasta 55"', Icons.tv_outlined, 1, 18, 'Un TV de hasta 55" cabe acostado en un auto.'),
  Cargo('tv65', 'TV 65" o más', Icons.connected_tv_outlined, 2, 30, 'Un TV de 65" no cabe en moto ni en auto: necesita pickup.'),
  Cargo('refri', 'Refri / lavadora', Icons.kitchen_outlined, 2, 80, 'Los electrodomésticos grandes van de pie en una pickup.'),
  Cargo('mueble', 'Muebles', Icons.chair_outlined, 2, 60, 'Los muebles van en pickup; para varias piezas, mejor camión.'),
  Cargo('merca', 'Mercadería / tarimas', Icons.pallet, 3, 500, 'La mercadería en tarimas requiere camión.'),
];

const tariff = {
  'moto': [60.0, 14.0],
  'auto': [95.0, 20.0],
  'pickup': [150.0, 23.0],
  'camion': [450.0, 46.0],
};

// ───────────────────────── Estado global ─────────────────────────
enum Phase { search, toPickup, loading, enRoute, done }

class AppState extends ChangeNotifier {
  String veh = 'moto';
  String cargo = 'paq';
  bool cargoSet = false;
  bool dest = false;
  bool viajes = false;
  bool sched = false;
  int schedD = 0, schedT = 0;
  bool venta = true;
  int valor = 200;
  bool fragil = false;
  final Map<String, bool> svc = {'ida': false, 'mas': false, 'multi': false};
  int masN = 2;
  int stops = 3;
  bool payerRem = true;
  String method = 'transf';
  int rating = 4;
  double km = 4.3;
  String recip = 'María José Castillo';
  String recipTel = '8456 1290';
  String from = 'Floristería Bella Rosa, Los Robles';
  String to = 'Res. Villa Fontana, casa B-14';

  // viaje
  Phase? phase;
  double t = 0, p = 0, sp = 0;
  String tripId = '';
  String tripVeh = 'moto';
  double tripPrice = 0;
  int speed = 4;
  Timer? _timer;
  String? toast;
  final _toastCtrl = StreamController<List<String>>.broadcast();
  Stream<List<String>> get toasts => _toastCtrl.stream;

  Cargo get cargoObj => cargos.firstWhere((c) => c.id == cargo);
  int get minLvl => cargoObj.lvl;
  int price(String v) {
    final t = tariff[v]!;
    return ((t[0] + t[1] * km) / 5).round() * 5;
  }

  int get svcTotal {
    int s = 0;
    if (svc['ida']!) s += ((price(veh) * .6) / 5).round() * 5;
    if (svc['mas']!) s += price(veh) * masN;
    if (svc['multi']!) s += 40 * stops;
    return s;
  }

  int get tarifa => price(veh) + svcTotal;

  void set(VoidCallback f) {
    f();
    notifyListeners();
  }

  static const dur = {Phase.search: 5.0, Phase.toPickup: 22.0, Phase.loading: 6.0, Phase.enRoute: 48.0};
  static const aFrac = 0.30;

  void startTrip() {
    tripId = 'ENV-${48210 + math.Random().nextInt(700)}';
    tripVeh = veh;
    tripPrice = tarifa.toDouble();
    phase = Phase.search;
    t = 0;
    p = 0;
    sp = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick(.1));
    notifyListeners();
  }

  void jumpTo(Phase ph) {
    if (phase == null) startTrip();
    phase = ph;
    t = 0;
    p = ph == Phase.done ? 1 : (ph == Phase.toPickup ? aFrac * .4 : (ph.index >= Phase.loading.index ? aFrac : 0));
    notifyListeners();
  }

  void cancelTrip() {
    _timer?.cancel();
    phase = null;
    notifyListeners();
  }

  void _emit(String a, String b) => _toastCtrl.add([a, b]);

  void _tick(double dt) {
    if (phase == null || phase == Phase.done) return;
    t += dt * speed;
    final d = dur[phase]!;
    final v = vehById(tripVeh);
    switch (phase!) {
      case Phase.search:
        sp = (t / d).clamp(0, 1);
        if (t >= d) {
          phase = Phase.toPickup;
          t = 0;
          _emit('${v.driver} va en camino', '${v.model} · ${v.plate}');
        }
      case Phase.toPickup:
        p = aFrac * (t / d).clamp(0, 1);
        if (t >= d) {
          phase = Phase.loading;
          t = 0;
          _emit('Tu conductor llegó', 'Recogiendo en ${from.split(',').first}');
        }
      case Phase.loading:
        if (t >= d) {
          phase = Phase.enRoute;
          t = 0;
          _emit('¡Paquete recogido!', 'Se envió el link de seguimiento a ${recip.split(' ').first}');
        }
      case Phase.enRoute:
        p = aFrac + (1 - aFrac) * (t / d).clamp(0, 1);
        if (t >= d) {
          phase = Phase.done;
          p = 1;
          _emit('¡Entregado!', '$recip recibió el envío');
        }
      case Phase.done:
        break;
    }
    notifyListeners();
  }

  int get etaMin {
    final v = vehById(tripVeh);
    switch (phase) {
      case Phase.search:
        return v.eta + 18;
      case Phase.toPickup:
        return math.max(1, ((1 - t / dur[Phase.toPickup]!) * v.eta + 18).round());
      case Phase.loading:
        return 18;
      case Phase.enRoute:
        return math.max(1, ((1 - t / dur[Phase.enRoute]!) * 18).round());
      default:
        return 0;
    }
  }

  String get kmLeft => math.max(0, (1 - p) * km * 1.4).toStringAsFixed(1);
  int get stepIdx => phase == null ? 0 : phase!.index;
}

final app = AppState();

// ───────────────────────── Navegación ─────────────────────────
Future<T?> go<T>(BuildContext c, Widget w, {bool replace = false}) {
  final r = PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (_, __, ___) => w,
    transitionsBuilder: (_, an, __, child) {
      final cv = CurvedAnimation(parent: an, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: cv,
        child: SlideTransition(position: Tween(begin: const Offset(.06, 0), end: Offset.zero).animate(cv), child: child),
      );
    },
  );
  return replace ? Navigator.of(c).pushReplacement(r) : Navigator.of(c).push(r);
}

void goHome(BuildContext c) => Navigator.of(c).popUntil((r) => r.settings.name == '/home' || r.isFirst);

// ───────────────────────── Fondo estilo Figma ─────────────────────────
enum BgKind { blue, dark, plain }

class FBg extends StatelessWidget {
  final BgKind kind;
  const FBg({super.key, this.kind = BgKind.blue});
  @override
  Widget build(BuildContext context) {
    if (kind == BgKind.dark) return const ColoredBox(color: Color(0xFF01061F), child: SizedBox.expand());
    if (kind == BgKind.plain) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1B3CB3), Color(0xFF13308F), Color(0xFF0A1A5C)]),
        ),
        child: SizedBox.expand(),
      );
    }
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, .38, .7, 1],
          colors: [Color(0xFF0C37C4), Color(0xFF0A2AA6), Color(0xFF071D7A), Color(0xFF04115A)],
        ),
      ),
      child: CustomPaint(painter: _RibbonPainter(), child: SizedBox.expand()),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter();
  @override
  void paint(Canvas c, Size s) {
    final sx = s.width / 440, sy = s.height / 956;
    Path poly(List<double> p) {
      final path = Path()..moveTo(p[0] * sx, p[1] * sy);
      for (int i = 2; i < p.length; i += 2) {
        path.lineTo(p[i] * sx, p[i + 1] * sy);
      }
      return path..close();
    }

    Paint grad(Offset a1, Offset b1, List<Color> cols, [List<double>? st]) =>
        Paint()..shader = ui.Gradient.linear(Offset(a1.dx * sx, a1.dy * sy), Offset(b1.dx * sx, b1.dy * sy), cols, st);

    c.drawPath(poly([210, -40, 340, -40, 560, 330, 560, 520]),
        grad(const Offset(210, -40), const Offset(560, 520), [a(const Color(0xFF6C9CFF), .75), a(const Color(0xFF2A5FF0), .45), a(const Color(0xFF0A2AA6), 0)], [0, .45, 1]));
    c.drawPath(poly([300, -40, 330, -40, 560, 360, 560, 410]), Paint()..color = a(const Color(0xFFCFE0FF), .18));
    c.drawPath(poly([560, 120, 560, 260, 250, 700, 130, 700]),
        grad(const Offset(560, 120), const Offset(130, 700), [a(const Color(0xFF8FB4FF), .6), a(const Color(0xFF2D63F2), .35), a(const Color(0xFF0A2AA6), 0)], [0, .5, 1]));
    c.drawPath(poly([560, 230, 560, 250, 190, 760, 170, 760]), Paint()..color = a(const Color(0xFFD6E4FF), .14));
    c.drawPath(poly([-60, 520, 120, 640, -60, 1000]), grad(const Offset(-60, 1000), const Offset(120, 520), [a(const Color(0xFF3B6DFF), .55), a(const Color(0xFF0A2AA6), 0)]));
    c.drawPath(poly([-60, 820, 300, 980, -60, 1000]), grad(const Offset(-60, 1000), const Offset(300, 820), [a(const Color(0xFF3B6DFF), .45), a(const Color(0xFF0A2AA6), 0)]));
    final r = Rect.fromLTWH(0, 0, s.width, s.height);
    c.drawRect(r, Paint()..shader = ui.Gradient.radial(Offset(s.width / 2, s.height * .4), s.longestSide * .8, [a(Colors.black, 0), a(const Color(0xFF020A3A), .55)], [.55, 1]));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ───────────────────────── Componentes ─────────────────────────
class FCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? border;
  final VoidCallback? onTap;
  final Gradient? gradient;
  const FCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 24, this.border, this.onTap, this.gradient});
  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a(const Color(0xFF08103A), .88), a(const Color(0xFF030824), .92)]),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? a(Colors.white, .16), width: border != null ? 1.5 : 1),
        boxShadow: [BoxShadow(color: a(Colors.black, .35), blurRadius: 30, offset: const Offset(0, 14))],
      ),
      child: child,
    );
    return onTap == null ? box : GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: box);
  }
}

class FGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  const FGlass({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 26, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a(Colors.white, .16), a(Colors.white, .05), a(Colors.white, .08)]),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: a(Colors.white, .3)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class FButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double height;
  final bool ghost;
  final Widget? leading;
  const FButton(this.text, {super.key, this.onTap, this.height = 56, this.ghost = false, this.leading});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: ghost ? null : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [K.blue2, Color(0xFF1460FF)]),
          color: ghost ? a(const Color(0xFF030824), .6) : null,
          borderRadius: BorderRadius.circular(16),
          border: ghost ? Border.all(color: a(Colors.white, .25)) : null,
          boxShadow: ghost ? null : [BoxShadow(color: a(K.blue, .6), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -8)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [if (leading != null) ...[leading!, const SizedBox(width: 8)], Text(text, style: tx(15, w: FontWeight.w700))]),
      ),
    );
  }
}

class FHeader extends StatelessWidget {
  final String title;
  final String? paso;
  final String? subtitle;
  final VoidCallback? onBack;
  const FHeader(this.title, {super.key, this.paso, this.subtitle, this.onBack});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      child: Row(children: [
        GestureDetector(onTap: onBack ?? () => Navigator.of(context).maybePop(), child: const Icon(Icons.chevron_left_rounded, size: 34, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: tx(subtitle != null ? 20 : 23, w: FontWeight.w700)),
            if (subtitle != null) Text(subtitle!, style: tx(12.5)),
          ]),
        ),
        if (paso != null) Pill(paso!),
      ]),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final double fs;
  final EdgeInsets pad;
  const Pill(this.text, {super.key, this.color, this.textColor, this.fs = 14, this.pad = const EdgeInsets.symmetric(horizontal: 20, vertical: 9)});
  @override
  Widget build(BuildContext context) => Container(
        padding: pad,
        decoration: BoxDecoration(
          color: color ?? a(const Color(0xFF030824), .85),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color != null ? color! : a(Colors.white, .25)),
        ),
        child: Text(text, style: tx(fs, w: FontWeight.w700, c: textColor ?? Colors.white)),
      );
}

class FField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool plain;
  final bool obscure;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double minHeight;
  const FField({super.key, required this.icon, required this.label, this.hint = '', this.value, this.onChanged, this.plain = false, this.obscure = false, this.trailing, this.onTap, this.minHeight = 58});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a(const Color(0xFF060C30), .72), a(const Color(0xFF02061E), .82)]),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: a(Colors.white, .22)),
        ),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: plain
                ? TextFormField(
                    initialValue: value,
                    obscureText: obscure,
                    onChanged: onChanged,
                    style: tx(14),
                    decoration: InputDecoration(isDense: true, border: InputBorder.none, hintText: label, hintStyle: tx(14)),
                  )
                : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(label, style: tx(13.5, w: FontWeight.w700)),
                    onTap != null
                        ? Text(value ?? hint, style: tx(12, w: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)
                        : TextFormField(
                            initialValue: value,
                            onChanged: onChanged,
                            style: tx(12, w: FontWeight.w500),
                            decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.only(top: 2), border: InputBorder.none, hintText: hint, hintStyle: tx(12, w: FontWeight.w500, c: a(Colors.white, .85))),
                          ),
                  ]),
          ),
          if (trailing != null) trailing!,
        ]),
      ),
    );
  }
}

class YesNo extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const YesNo({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    Widget b(String t, bool on, bool v) => GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? K.blue : Colors.transparent, borderRadius: BorderRadius.circular(24)),
            child: Text(t, style: tx(13.5, w: FontWeight.w700)),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: a(const Color(0xFF030824), .8), borderRadius: BorderRadius.circular(30), border: Border.all(color: a(Colors.white, .22))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [b('Sí', value, true), b('No', !value, false)]),
    );
  }
}

class Radio2 extends StatelessWidget {
  final bool on;
  final double size;
  const Radio2(this.on, {super.key, this.size = 22});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: on ? Colors.white : a(Colors.white, .18), border: Border.all(color: on ? Colors.white : a(Colors.white, .25))),
        alignment: Alignment.center,
        child: on ? Container(width: size * .55, height: size * .55, decoration: const BoxDecoration(shape: BoxShape.circle, color: K.blue)) : null,
      );
}

class SecTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? sub;
  final Widget? trailing;
  final double top;
  const SecTitle(this.icon, this.title, {super.key, this.sub, this.trailing, this.top = 22});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: top, bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 26, color: Colors.white)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: tx(19, w: FontWeight.w700)),
              if (sub != null) Text(sub!, style: tx(13, w: FontWeight.w500)),
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

class Dashed extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  const Dashed({super.key, required this.icon, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(children: [
            Icon(icon, size: 34, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: tx(14, w: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(sub, style: tx(12.5, w: FontWeight.w500, c: a(Colors.white, .85)), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final r = RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(22));
    c.drawRRect(r, Paint()..color = a(const Color(0xFF030A2D), .55));
    final path = Path()..addRRect(r);
    final p = Paint()
      ..color = a(const Color(0xFF468CFF), .85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        c.drawPath(m.extractPath(d, d + 7), p);
        d += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VehImg extends StatelessWidget {
  final String id;
  final double? height;
  final double? width;
  const VehImg(this.id, {super.key, this.height, this.width});
  @override
  Widget build(BuildContext context) => Image.asset(vehById(id).img, height: height, width: width, fit: BoxFit.contain);
}

/// Pantalla base con fondo + contenido con scroll + botón fijo abajo.
class FScaffold extends StatelessWidget {
  final List<Widget> children;
  final Widget? bottom;
  final BgKind bg;
  final Widget? overlay;
  final EdgeInsets padding;
  const FScaffold({super.key, required this.children, this.bottom, this.bg = BgKind.blue, this.overlay, this.padding = const EdgeInsets.fromLTRB(22, 12, 22, 24)});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.navy,
      body: Stack(children: [
        Positioned.fill(child: FBg(kind: bg)),
        SafeArea(
          child: Column(children: [
            Expanded(child: ListView(padding: padding, children: children)),
            if (bottom != null)
              Container(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [a(const Color(0xFF020828), 0), a(const Color(0xFF020828), .92)])),
                child: bottom,
              ),
          ]),
        ),
        if (overlay != null) overlay!,
        const ToastLayer(),
      ]),
    );
  }
}

/// Muestra notificaciones del viaje en cualquier pantalla.
class ToastLayer extends StatefulWidget {
  const ToastLayer({super.key});
  @override
  State<ToastLayer> createState() => _ToastLayerState();
}

class _ToastLayerState extends State<ToastLayer> {
  List<String>? msg;
  StreamSubscription? sub;
  Timer? hide;
  @override
  void initState() {
    super.initState();
    sub = app.toasts.listen((m) {
      if (!mounted) return;
      setState(() => msg = m);
      hide?.cancel();
      hide = Timer(const Duration(milliseconds: 3400), () {
        if (mounted) setState(() => msg = null);
      });
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    hide?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      top: msg == null ? -140 : MediaQuery.of(context).padding.top + 8,
      left: 14,
      right: 14,
      child: IgnorePointer(
        child: FCard(
          padding: const EdgeInsets.all(12),
          radius: 20,
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Container(color: K.blue, child: Image.asset('assets/img/m_head.webp', width: 40, height: 40, fit: BoxFit.cover))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(msg?[0] ?? '', style: tx(14, w: FontWeight.w700)),
                Text(msg?[1] ?? '', style: tx(12, w: FontWeight.w500, c: a(Colors.white, .8))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

String dayLabel(int i) {
  const d = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  const m = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sept', 'oct', 'nov', 'dic'];
  final x = DateTime.now().add(Duration(days: i + 1));
  return '${i == 0 ? 'Mañana' : d[x.weekday - 1]}\n${x.day} ${m[x.month - 1]}';
}

const hours = ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM'];
