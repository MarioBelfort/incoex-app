import 'dart:async';

import 'package:flutter/material.dart';

import '../core.dart';
import '../map.dart';
import 'home.dart';

// ───────────────────────── Asignando conductor ─────────────────────────
class BuscandoScreen extends StatefulWidget {
  const BuscandoScreen({super.key});
  @override
  State<BuscandoScreen> createState() => _BuscandoScreenState();
}

class _BuscandoScreenState extends State<BuscandoScreen> with TickerProviderStateMixin {
  late final AnimationController drive = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  late final AnimationController bob = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  late final AnimationController spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();
  bool left = false;

  @override
  void initState() {
    super.initState();
    app.addListener(_check);
  }

  void _check() {
    if (!left && mounted && app.phase != null && app.phase != Phase.search) {
      left = true;
      go(context, const SeguimientoScreen(), replace: true);
    }
  }

  @override
  void dispose() {
    app.removeListener(_check);
    drive.dispose();
    bob.dispose();
    spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = vehById(app.tripVeh);
    return Scaffold(
      backgroundColor: K.navy,
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: FBg(kind: BgKind.plain)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(children: [
              Row(children: [
                Image.asset('assets/img/logo.webp', width: 38, color: const Color(0xFF6EB4FF)),
                const SizedBox(width: 6),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('INCOEX', style: tx(22, w: FontWeight.w800, h: 1)), Text('Logistics', style: tx(10))]),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    app.cancelTrip();
                    goHome(context);
                  },
                  child: Pill('× Cancelar', color: a(Colors.white, .08), fs: 13),
                ),
              ]),
              Expanded(
                flex: 5,
                child: AnimatedBuilder(
                  animation: Listenable.merge([drive, bob]),
                  builder: (_, child) {
                    final dx = (1 - Curves.easeOutCubic.transform(drive.value)) * -400;
                    return Transform.translate(offset: Offset(dx, -4 * bob.value), child: child);
                  },
                  child: Center(child: VehImg(v.id, width: v.id == 'moto' ? 320 : 360)),
                ),
              ),
              AnimatedBuilder(
                animation: spin,
                builder: (_, __) => Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(color: a(Colors.white, .08), borderRadius: BorderRadius.circular(24), border: Border.all(color: a(Colors.white, .35))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Transform.rotate(angle: spin.value * 6.283, child: const Icon(Icons.autorenew_rounded, color: Colors.white, size: 18)),
                    const SizedBox(width: 10),
                    Text('Buscando conductor...', style: tx(14, w: FontWeight.w700)),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              Text('Asignando conductor', style: tx(22, w: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Estamos buscando un conductor disponible\ncerca de ti.', style: tx(14, w: FontWeight.w500), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              ListenableBuilder(
                listenable: app,
                builder: (_, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: LinearProgressIndicator(value: app.sp, minHeight: 7, backgroundColor: a(Colors.white, .9), valueColor: const AlwaysStoppedAnimation(K.blue)),
                ),
              ),
              const SizedBox(height: 10),
              Text('Esto puede tardar unos segundos...', style: tx(12, w: FontWeight.w500)),
              const Spacer(flex: 1),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: a(Colors.white, .07), borderRadius: BorderRadius.circular(18), border: Border.all(color: a(Colors.white, .18))),
                child: Row(children: [
                  Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Text('MARCA\nALIADA', textAlign: TextAlign.center, style: tx(8.5, w: FontWeight.w900, c: const Color(0xFF0A2378), h: 1.05))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('PATROCINADO', style: tx(10, w: FontWeight.w700, c: a(Colors.white, .7))),
                      Text('Tu ${v.name.toLowerCase()} es un ${v.model}', style: tx(12.5, w: FontWeight.w700)),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        const ToastLayer(),
      ]),
    );
  }
}

// ───────────────────────── Seguimiento ─────────────────────────
class SeguimientoScreen extends StatefulWidget {
  const SeguimientoScreen({super.key});
  @override
  State<SeguimientoScreen> createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> {
  bool left = false;
  @override
  void initState() {
    super.initState();
    app.addListener(_check);
  }

  void _check() {
    if (!left && mounted && app.phase == Phase.done) {
      left = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) go(context, const TerminadoScreen(), replace: true);
      });
    }
  }

  @override
  void dispose() {
    app.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.navy,
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final v = vehById(app.tripVeh);
          final ph = app.phase;
          final on = app.stepIdx.clamp(1, 4);
          final st = switch (ph) { Phase.search => 'Buscando', Phase.toPickup => 'En camino', Phase.loading => 'Recogiendo', Phase.enRoute => 'En viaje', Phase.done => 'Entregado', null => '' };
          return Stack(fit: StackFit.expand, children: [
            Positioned.fill(child: TripMap(frame: const MapFrame(left: .14, top: .06, scale: .72, lake: .07), progress: app.p)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                child: GestureDetector(
                  onTap: () => goHome(context),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.only(left: 12, right: 26),
                    decoration: BoxDecoration(color: a(const Color(0xFF030824), .88), borderRadius: BorderRadius.circular(30), border: Border.all(color: a(Colors.white, .15))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30), Text('Inicio', style: tx(15, w: FontWeight.w700))]),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(22, 12, 22, 16 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [a(const Color(0xFF0A2350), .95), a(const Color(0xFF06163C), .98)]),
                  border: Border(top: BorderSide(color: a(Colors.white, .18))),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: a(Colors.white, .85), borderRadius: BorderRadius.circular(5)))),
                  const SizedBox(height: 16),
                  Row(children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(st, style: tx(14, w: FontWeight.w700)),
                    const Spacer(),
                    Pill('Soporte Técnico', color: K.blue, fs: 12.5, pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 6)),
                  ]),
                  const SizedBox(height: 14),
                  Text(ph == Phase.done ? '¡Entregado!' : 'Llegada en ${app.etaMin} minutos (${app.kmLeft} km)', style: tx(21, w: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ph == Phase.toPickup ? 'Aproximándose a ${app.from.split(',').first}' : ph == Phase.loading ? 'Recogiendo en ${app.from.split(',').first}' : 'Aproximándose a Rotonda El Güegüense',
                        style: tx(14, w: FontWeight.w700),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  Row(children: [
                    _driverPhoto(v, 64),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(v.driver, style: tx(18, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${v.model} (${v.color})', style: tx(13.5, w: FontWeight.w500, c: a(Colors.white, .85))),
                        const SizedBox(height: 6),
                        Pill(v.plate, color: a(Colors.white, .12), fs: 13, pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 4)),
                      ]),
                    ),
                    _round(Icons.phone, false, () => go(context, const LlamadaScreen())),
                    const SizedBox(width: 10),
                    _round(Icons.chat_bubble_outline, true, () {}),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: a(Colors.white, .06), borderRadius: BorderRadius.circular(14), border: Border.all(color: a(Colors.white, .14))),
                    child: Row(children: [
                      SizedBox(width: 64, height: 38, child: VehImg(v.id)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('¿Te gusta este ${v.model}?', style: tx(12, w: FontWeight.w700)),
                          Text('Patrocinado · Agenda una prueba de manejo', style: tx(11, w: FontWeight.w500, c: a(Colors.white, .8))),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Text('Estado del viaje', style: tx(19, w: FontWeight.w700)),
                  const SizedBox(height: 14),
                  _Steps(on: on),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(
                      child: _pillBtn(Icons.copy_rounded, 'Copiar', false, () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link copiado: incoex.app/s/${app.tripId}')));
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(flex: 1, child: _pillBtn(Icons.ios_share_rounded, 'Compartir', true, () {})),
                  ]),
                ]),
              ),
            ),
            const ToastLayer(),
          ]);
        },
      ),
    );
  }

  Widget _round(IconData i, bool blue, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(shape: BoxShape.circle, color: blue ? K.blue : a(Colors.white, .1), border: Border.all(color: blue ? K.blue : a(Colors.white, .35))),
          child: Icon(i, color: Colors.white, size: 22),
        ),
      );

  Widget _pillBtn(IconData i, String t, bool blue, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          height: 52,
          decoration: BoxDecoration(color: blue ? K.blue : a(Colors.white, .1), borderRadius: BorderRadius.circular(26), border: blue ? null : Border.all(color: a(Colors.white, .35))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, color: Colors.white, size: 20), const SizedBox(width: 8), Text(t, style: tx(15, w: FontWeight.w700))]),
        ),
      );
}

Widget _driverPhoto(Veh v, double s) => Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFFD8C1A4), Color(0xFF8A6B52)]),
        border: Border.all(color: a(Colors.white, .4), width: 2),
      ),
      child: Text(v.driver.split(' ').map((w) => w[0]).join(), style: tx(s * .32, w: FontWeight.w800, c: const Color(0xFF3A2A1D))),
    );

class _Steps extends StatelessWidget {
  final int on;
  const _Steps({required this.on});
  @override
  Widget build(BuildContext context) {
    const l = ['En camino', 'Recogido', 'En viaje', 'Entregado'];
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth - 76;
      return Stack(children: [
        Positioned(left: 38, top: 16, child: Container(width: w, height: 3, color: a(Colors.white, .25))),
        Positioned(left: 38, top: 16, child: AnimatedContainer(duration: const Duration(milliseconds: 600), width: w * (on - 1) / 3, height: 3, color: K.blue)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          for (int i = 0; i < 4; i++)
            SizedBox(
              width: 76,
              child: Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: i < on ? K.blue : const Color(0xFF0A1A4A), border: Border.all(color: i < on ? K.blue : a(Colors.white, .4), width: 2)),
                  child: Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
                ),
                const SizedBox(height: 8),
                Text(l[i], style: tx(12.5)),
              ]),
            ),
        ]),
      ]);
    });
  }
}

// ───────────────────────── Llamada ─────────────────────────
class LlamadaScreen extends StatefulWidget {
  const LlamadaScreen({super.key});
  @override
  State<LlamadaScreen> createState() => _LlamadaScreenState();
}

class _LlamadaScreenState extends State<LlamadaScreen> {
  final start = DateTime.now();
  Timer? t;
  bool mute = false, spk = false;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = vehById(app.tripVeh);
    final s = DateTime.now().difference(start).inSeconds;
    Widget b(IconData i, String l, bool on, VoidCallback f) => Expanded(
          child: GestureDetector(
            onTap: f,
            child: Container(
              height: 62,
              decoration: BoxDecoration(color: on ? K.blue : a(const Color(0xFF030824), .8), borderRadius: BorderRadius.circular(30), border: Border.all(color: on ? K.blue : a(Colors.white, .22))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, color: Colors.white), const SizedBox(width: 10), Text(l, style: tx(14.5, w: FontWeight.w700))]),
            ),
          ),
        );
    return FScaffold(bg: BgKind.dark, children: [
      FCard(
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          _driverPhoto(v, 90),
          const SizedBox(height: 12),
          Text(v.driver, style: tx(18, w: FontWeight.w700)),
          const SizedBox(height: 8),
          Pill('Conductor asignado', fs: 11.5, pad: const EdgeInsets.symmetric(horizontal: 12, vertical: 5)),
          const SizedBox(height: 6),
          Text('${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}', style: tx(13, w: FontWeight.w700, c: K.ice)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: a(const Color(0xFF14286E), .45), borderRadius: BorderRadius.circular(16), border: Border.all(color: a(const Color(0xFF78A0FF), .25))),
            child: Column(children: [
              Text('Llamada en curso con el conductor', style: tx(13, w: FontWeight.w700)),
              Text('Si presentas algún inconveniente durante la llamada, contacta a soporte técnico.', style: tx(12, w: FontWeight.w500), textAlign: TextAlign.center),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      FCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pedido #${app.tripId.replaceAll('ENV-', '')}', style: tx(13.5, w: FontWeight.w700)), Text(phaseText(app.phase), style: tx(13, w: FontWeight.w500))])),
          Divider(color: a(Colors.white, .18), height: 1),
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${v.name} asignad${v.id == 'moto' ? 'a' : 'o'}', style: tx(13.5, w: FontWeight.w700)), Text('${v.model} (${v.color}) - Placa ${v.plate}', style: tx(13, w: FontWeight.w500))])),
          Divider(color: a(Colors.white, .18), height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              Container(width: 32, height: 32, decoration: const BoxDecoration(color: K.blue, shape: BoxShape.circle), child: const Icon(Icons.help_outline, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Text('Soporte técnico', style: tx(13.5, w: FontWeight.w700))),
              const Icon(Icons.chevron_right, color: Colors.white),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 22),
      Row(children: [b(Icons.mic_off_outlined, 'Silenciar', mute, () => setState(() => mute = !mute)), const SizedBox(width: 12), b(Icons.volume_up_outlined, 'Altavoz', spk, () => setState(() => spk = !spk))]),
      const SizedBox(height: 12),
      Row(children: [b(Icons.chat_bubble_outline, 'Mensaje', false, () {}), const SizedBox(width: 12), b(Icons.my_location, 'Ver ubicación', false, () => Navigator.pop(context))]),
      const SizedBox(height: 22),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFFD5334F), Color(0xFFB8203D)])),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.call_end, color: K.red, size: 20)),
            Expanded(child: Text('Finalizar llamada', style: tx(15, w: FontWeight.w700), textAlign: TextAlign.center)),
            const Icon(Icons.chevron_right, color: Colors.white),
          ]),
        ),
      ),
    ]);
  }
}

// ───────────────────────── Viaje terminado ─────────────────────────
class TerminadoScreen extends StatelessWidget {
  const TerminadoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => FScaffold(bg: BgKind.dark, children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutBack,
          builder: (_, v, c) => Transform.translate(offset: Offset(0, 40 * (1 - v)), child: Opacity(opacity: v.clamp(0, 1), child: c)),
          child: Center(child: VehImg(app.tripVeh, height: 270)),
        ),
        Transform.translate(
          offset: const Offset(0, -20),
          child: FCard(
            padding: const EdgeInsets.all(22),
            child: Column(children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(center: Alignment(-.2, -.3), colors: [Color(0xFF45E07F), Color(0xFF16A34A)]),
                  boxShadow: [BoxShadow(color: a(K.green, .55), blurRadius: 40), BoxShadow(color: a(K.green, .18), spreadRadius: 6)],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 14),
              Text('¡Viaje terminado!', style: tx(22, w: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Tu paquete ha llegado a su destino con éxito.\nGracias por usar INCOEX.', style: tx(13, w: FontWeight.w500), textAlign: TextAlign.center),
              Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Container(height: 1, color: a(const Color(0xFF78A0FF), .4))),
              Text('Destino final', style: tx(13, w: FontWeight.w500, c: a(Colors.white, .85))),
              Text(app.to, style: tx(15, w: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                height: 44,
                decoration: BoxDecoration(color: a(const Color(0xFF0A1E64), .45), borderRadius: BorderRadius.circular(24), border: Border.all(color: a(const Color(0xFF78A0FF), .3))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 20),
                  Container(width: 1, height: 20, margin: const EdgeInsets.symmetric(horizontal: 12), color: a(Colors.white, .4)),
                  Text('Viaje hecho hoy, ${now.hour}:${now.minute.toString().padLeft(2, '0')} hrs', style: tx(13, w: FontWeight.w500)),
                ]),
              ),
              Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Container(height: 1, color: a(const Color(0xFF78A0FF), .4))),
              Text('¿Cómo fue tu experiencia?', style: tx(13, w: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (int n = 1; n <= 5; n++)
                  GestureDetector(
                    onTap: () => app.set(() => app.rating = n),
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Icon(app.rating >= n ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.white, size: 32)),
                  ),
              ]),
            ]),
          ),
        ),
        FButton('Ver cobros y liquidación', onTap: () => go(context, const CobrosScreen())),
        const SizedBox(height: 10),
        FButton('Regresar al inicio', ghost: true, height: 46, onTap: () => goHome(context)),
      ]),
    );
  }
}

// ───────────────────────── Cobros y liquidación ─────────────────────────
class CobrosScreen extends StatelessWidget {
  const CobrosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final tf = app.tripPrice > 0 ? app.tripPrice : app.tarifa;
    final prod = app.venta ? app.valor : 0;
    Widget badge(String t, Color c) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(color: a(c, .18), borderRadius: BorderRadius.circular(14), border: Border.all(color: c)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check, size: 12, color: Colors.white), const SizedBox(width: 4), Text(t, style: tx(10.5, w: FontWeight.w700))]),
        );
    Widget row(IconData i, String t, num v, Widget? b) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
          child: Row(children: [
            Icon(i, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(t, style: tx(12.5, w: FontWeight.w500))),
            Text(fmt(v), style: tx(12.5, w: FontWeight.w700)),
            const SizedBox(width: 8),
            SizedBox(width: 98, child: Align(alignment: Alignment.centerRight, child: b ?? Text('–', style: tx(13)))),
          ]),
        );
    return FScaffold(bg: BgKind.dark, children: [
      Center(child: Image.asset('assets/img/m_front.webp', height: 210)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [a(const Color(0xFF143CA0), .8), a(const Color(0xFF061046), .9)]),
          border: Border.all(color: a(const Color(0xFF78AAFF), .4)),
        ),
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFF45E07F), Color(0xFF16A34A)]), boxShadow: [BoxShadow(color: a(K.green, .5), blurRadius: 30)]),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('¡Entrega completada!', style: tx(19, w: FontWeight.w700)), Text('El paquete fue entregado correctamente.', style: tx(12.5, w: FontWeight.w500))])),
        ]),
      ),
      const SizedBox(height: 12),
      FCard(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [const Icon(Icons.local_shipping, color: Colors.white), const SizedBox(width: 10), Expanded(child: Text('Cobros realizados', style: tx(15, w: FontWeight.w700))), const Icon(Icons.chevron_right, color: Colors.white)]),
          const SizedBox(height: 6),
          row(Icons.view_in_ar_rounded, 'Producto cobrado al destinatario', prod, badge('Recibido', K.green)),
          Divider(color: a(Colors.white, .1), height: 1),
          row(Icons.local_shipping_outlined, 'Envío pagado por ${app.payerRem ? 'remitente' : 'destinatario'}', tf, badge('Confirmado', const Color(0xFF3D8BFF))),
          Divider(color: a(Colors.white, .1), height: 1),
          row(Icons.shield, 'Seguro', 0, null),
        ]),
      ),
      const SizedBox(height: 12),
      FCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.bar_chart_rounded, color: Colors.white), const SizedBox(width: 10), Text('Liquidación', style: tx(15, w: FontWeight.w700))]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: a(const Color(0xFFF59E0B), .06), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF59E0B))),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF1A2550), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.storefront, color: Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pendiente de liquidar al comercio:', style: tx(11.5, w: FontWeight.w500)), Text(fmt(prod), style: tx(20, w: FontWeight.w800))]),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      FCard(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(TextSpan(style: tx(11, w: FontWeight.w500), children: [
              TextSpan(text: 'INCOEX separa el dinero del producto del ingreso por transporte.\n', style: tx(11.5, w: FontWeight.w700)),
              const TextSpan(text: 'El monto del producto se mantiene separado y será liquidado al comercio según el acuerdo establecido.'),
            ])),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      FButton('Finalizar servicio', onTap: () => goHome(context)),
      const SizedBox(height: 10),
      FButton('Ver factura', ghost: true, height: 44, leading: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 18)),
    ]);
  }
}
