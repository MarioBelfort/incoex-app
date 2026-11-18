import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core.dart';
import 'flow.dart';
import 'trip.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const _HomeTab(), const EnviosTab(), const ResumenTab(), const _PerfilTab()];
    return Scaffold(
      backgroundColor: K.navy,
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: FBg()),
        SafeArea(bottom: false, child: IndexedStack(index: tab, children: pages)),
        Positioned(left: 12, right: 12, bottom: MediaQuery.of(context).padding.bottom + 12, child: _TabBar(tab: tab, onTap: (i) => setState(() => tab = i))),
        const ToastLayer(),
      ]),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTap;
  const _TabBar({required this.tab, required this.onTap});
  @override
  Widget build(BuildContext context) {
    Widget item(int i, String l, Widget icon) => Expanded(
          child: GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: tab == i ? LinearGradient(colors: [a(Colors.white, .2), a(Colors.white, .06)]) : null,
                border: tab == i ? Border.all(color: a(Colors.white, .35)) : null,
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [icon, const SizedBox(height: 4), Text(l, style: tx(12))]),
            ),
          ),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(colors: [a(Colors.white, .14), a(Colors.white, .04)]),
            border: Border.all(color: a(Colors.white, .28)),
          ),
          child: Row(children: [
            item(0, 'Inicio', Image.asset('assets/img/logo.webp', width: 26, color: Colors.white)),
            item(1, 'Envíos', const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 26)),
            item(2, 'Resumen', const Icon(Icons.schedule_rounded, color: Colors.white, size: 26)),
            item(3, 'Tú', const CircleAvatar(radius: 15, backgroundColor: K.blue, backgroundImage: AssetImage('assets/img/m_head.webp'))),
          ]),
        ),
      ),
    );
  }
}

void startFlow(BuildContext c, String veh, {bool viajes = false}) {
  app.set(() {
    app.veh = veh;
    app.viajes = viajes;
    app.cargo = veh == 'pickup' ? 'tv65' : veh == 'auto' ? 'flor' : 'paq';
    app.cargoSet = false;
    app.dest = false;
  });
  go(c, const RutaScreen());
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final ph = app.phase;
        return ListView(padding: const EdgeInsets.fromLTRB(22, 12, 22, 120), children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hola, Mario Belfort', style: tx(22, w: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(DateTime.now().hour < 12 ? '¡Buenos días!' : DateTime.now().hour < 18 ? '¡Buenas tardes!' : '¡Buenas noches!', style: tx(14)),
              ]),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [a(Colors.white, .18), a(Colors.white, .05)]), border: Border.all(color: a(Colors.white, .3))),
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, color: K.blue, border: Border.all(color: a(Colors.white, .6), width: 2)),
              child: ClipOval(child: Image.asset('assets/img/m_head.webp', fit: BoxFit.cover)),
            ),
          ]),
          if (ph != null && ph != Phase.done) ...[
            const SizedBox(height: 16),
            FCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () => go(context, ph == Phase.search ? const BuscandoScreen() : const SeguimientoScreen()),
              child: Row(children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: K.green, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${app.tripId} · ${vehById(app.tripVeh).name}', style: tx(13.5, w: FontWeight.w700)),
                    Text('${phaseText(ph)} · ${app.etaMin} min', style: tx(12, w: FontWeight.w500)),
                  ]),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          Text('Envíos', style: tx(21, w: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _VehCard(title: 'Moto', sub: 'Envíos pequeños', img: 'assets/img/moto.webp', imgH: 110, onTap: () => startFlow(context, 'moto'))),
            const SizedBox(width: 12),
            Expanded(child: _VehCard(title: 'Auto', sub: 'Espacios medianos', img: 'assets/img/car.webp', imgH: 70, imgTop: 34, onTap: () => startFlow(context, 'auto'))),
          ]),
          const SizedBox(height: 12),
          _VehCard(title: 'Carga', sub: 'Mayor espacio para todo tipo de envíos', img: 'assets/img/truck.webp', imgH: 122, height: 196, onTap: () => startFlow(context, 'pickup')),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => startFlow(context, 'auto', viajes: true),
            child: Container(
              height: 64,
              padding: const EdgeInsets.only(left: 22, right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(colors: [Color(0xFF1F6BFF), Color(0xFF2E7DFF)]),
                boxShadow: [BoxShadow(color: a(K.blue, .6), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -10)],
              ),
              child: Row(children: [
                const Icon(Icons.directions_walk, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('¿Necesitas movilizar a tu personal?', style: tx(14.5))),
                Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: a(Colors.white, .85)), child: const Icon(Icons.chevron_right, color: K.blue)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          FCard(
            padding: const EdgeInsets.fromLTRB(20, 22, 16, 22),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Soporte siempre\ncontigo', style: tx(21, w: FontWeight.w700, h: 1.15)),
                  const SizedBox(height: 12),
                  Text('Te ayudamos en cada paso de tu envío.', style: tx(11.5)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Contactar soporte', style: tx(12, w: FontWeight.w700, c: const Color(0xFF08133F))), const Icon(Icons.chevron_right, size: 16, color: Color(0xFF08133F))]),
                  ),
                ]),
              ),
              ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/img/support.webp', width: 118)),
            ]),
          ),
        ]);
      },
    );
  }
}

class _VehCard extends StatelessWidget {
  final String title, sub, img;
  final double imgH, imgTop, height;
  final VoidCallback onTap;
  const _VehCard({required this.title, required this.sub, required this.img, required this.onTap, this.imgH = 100, this.imgTop = 8, this.height = 184});
  @override
  Widget build(BuildContext context) {
    return FGlass(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: height,
        child: Stack(children: [
          Positioned(left: 0, right: 0, top: imgTop, child: Center(child: Image.asset(img, height: imgH))),
          Positioned(
            left: 14,
            right: 10,
            bottom: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: tx(14.5, w: FontWeight.w700)),
              Text(sub, style: tx(12.5)),
            ]),
          ),
        ]),
      ),
    );
  }
}

String phaseText(Phase? p) => switch (p) {
      Phase.search => 'Buscando conductor',
      Phase.toPickup => 'En camino a recoger',
      Phase.loading => 'Recogiendo tu paquete',
      Phase.enRoute => 'En camino a la entrega',
      Phase.done => 'Entregado',
      null => '',
    };

// ───────────────────────── Envíos ─────────────────────────
class EnviosTab extends StatefulWidget {
  const EnviosTab({super.key});
  @override
  State<EnviosTab> createState() => _EnviosTabState();
}

class _Ship {
  final String kind, veh, vehName, loc, id, extra;
  final int step;
  final bool live;
  const _Ship(this.kind, this.veh, this.vehName, this.loc, this.id, this.extra, this.step, {this.live = false});
}

class _EnviosTabState extends State<EnviosTab> {
  int tab = 0, filter = 0;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final act = <_Ship>[
          if (app.phase != null && app.phase != Phase.done) _Ship('Envío', app.tripVeh, vehById(app.tripVeh).name, app.to.split(',').first, '#${app.tripId.replaceAll('-', '')}', 'Llegada en ${app.etaMin} min', app.stepIdx, live: true),
          const _Ship('Envío', 'moto', 'Moto', 'Oficinas Incoex, Edificio Pellas', '#ENV123456', 'Llegada estimada: Hoy, 14:30', 2),
          const _Ship('Viaje', 'auto', 'SUV', 'Oficinas Incoex, Edificio Pellas', '1V3TG4', 'Llegada estimada: Hoy, 14:30', 3),
        ];
        const prog = [
          _Ship('Envío', 'camion', 'Camión', 'Oficinas Incoex, Edificio Pellas', '#ENV123456', 'Mañana', 0),
          _Ship('Viaje', 'auto', 'SUV', 'Oficinas Incoex, Edificio Pellas', '3SD31S', 'Mañana', 0),
          _Ship('Envío', 'moto', 'Moto', 'Oficinas Incoex, Edificio Pellas', '#ENV123456', 'Viernes', 0),
        ];
        const hist = [
          _Ship('Envío', 'pickup', 'Pickup', 'Las Colinas, calle principal', '#ENV48170', 'Entregado hoy 18:40', 4),
          _Ship('Envío', 'moto', 'Moto', 'Galerías Santo Domingo', '#ENV48166', 'Entregado hoy 17:12', 4),
        ];
        var rows = [act, prog, hist][tab];
        if (filter == 1) rows = rows.where((r) => r.kind == 'Envío').toList();
        if (filter == 2) rows = rows.where((r) => r.kind == 'Viaje').toList();
        return ListView(padding: const EdgeInsets.fromLTRB(22, 12, 22, 120), children: [
          Text('Envíos', style: tx(22, w: FontWeight.w700)),
          Text('Consulta y administra todos tus viajes y envíos', style: tx(14, w: FontWeight.w500)),
          const SizedBox(height: 18),
          _Seg(labels: ['Activos', 'Programados', 'Historial'], counts: [act.length, 3, 2], value: tab, onChanged: (i) => setState(() => tab = i)),
          const SizedBox(height: 12),
          Row(children: [
            for (final (i, l, ic) in [(0, 'Todos', Icons.grid_view_rounded), (1, 'Envíos', Icons.inventory_2_outlined), (2, 'Viajes', Icons.directions_car)])
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => filter = i),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    height: 38,
                    decoration: BoxDecoration(color: filter == i ? K.blue : a(const Color(0xFF030824), .7), borderRadius: BorderRadius.circular(20), border: Border.all(color: filter == i ? K.blue : a(Colors.white, .18))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, size: 16, color: Colors.white), const SizedBox(width: 6), Text(l, style: tx(13, w: FontWeight.w700))]),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Pill(tab == 1 ? 'Todas las fechas' : 'Hoy', fs: 13, pad: const EdgeInsets.symmetric(horizontal: 16, vertical: 9)),
            Pill('Filtros', fs: 13, pad: const EdgeInsets.symmetric(horizontal: 16, vertical: 9)),
          ]),
          const SizedBox(height: 14),
          for (final r in rows) _shipCard(context, r, tab),
        ]);
      },
    );
  }

  Widget _shipCard(BuildContext context, _Ship r, int tab) {
    Widget tag(String t, Color c, [Color tc = Colors.white]) => Container(
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(color: c == Colors.transparent ? null : c, borderRadius: BorderRadius.circular(12), border: Border.all(color: c == Colors.transparent ? a(Colors.white, .4) : c)),
          child: Text(t, style: tx(10.5, w: FontWeight.w700, c: tc)),
        );
    final labels = ['Recogido', r.kind == 'Viaje' ? 'En viaje' : 'En camino', r.kind == 'Viaje' ? 'Finalizado' : 'Entregado'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FCard(
        padding: const EdgeInsets.fromLTRB(8, 14, 10, 14),
        onTap: r.live ? () => go(context, app.phase == Phase.search ? const BuscandoScreen() : const SeguimientoScreen()) : null,
        child: Row(children: [
          SizedBox(width: 86, height: 60, child: VehImg(r.veh)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                tag(r.kind, r.kind == 'Envío' ? K.blue : K.yellow, r.kind == 'Envío' ? Colors.white : const Color(0xFF1D1400)),
                if (tab == 1) tag('Programado', K.purple),
                tag(r.vehName, Colors.transparent),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 17, color: Colors.white),
                const SizedBox(width: 4),
                Expanded(child: Text(r.loc, style: tx(14, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 4),
              Text(tab == 1 ? '${r.extra} · 8:00 - 10:00 · ${r.id}' : r.id, style: tx(12.5, w: FontWeight.w500)),
              if (tab == 0) ...[
                const SizedBox(height: 6),
                Row(children: [
                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: K.green, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('En camino', style: tx(10.5, w: FontWeight.w700, c: K.green)),
                  const Spacer(),
                  Flexible(child: Text(r.extra, style: tx(10.5, w: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 8),
                _MiniSteps(labels: labels, on: (r.step - 1).clamp(1, 3)),
              ],
              if (tab == 2) ...[const SizedBox(height: 6), Text(r.extra, style: tx(11, w: FontWeight.w700, c: K.green))],
            ]),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ]),
      ),
    );
  }
}

class _MiniSteps extends StatelessWidget {
  final List<String> labels;
  final int on;
  const _MiniSteps({required this.labels, required this.on});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(left: 14, right: 14, top: 5, child: Container(height: 2, color: a(Colors.white, .25))),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (int i = 0; i < labels.length; i++)
          Column(children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: i < on ? const Color(0xFF3D8BFF) : Colors.white, boxShadow: [BoxShadow(color: i < on ? a(const Color(0xFF3D8BFF), .5) : const Color(0xFF0A1A4A), spreadRadius: 3)]),
            ),
            const SizedBox(height: 4),
            Text(labels[i], style: tx(10, w: FontWeight.w700, c: i < on ? Colors.white : a(Colors.white, .55))),
          ]),
      ]),
    ]);
  }
}

class _Seg extends StatelessWidget {
  final List<String> labels;
  final List<int>? counts;
  final int value;
  final ValueChanged<int> onChanged;
  const _Seg({required this.labels, this.counts, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: a(const Color(0xFF030824), .7), borderRadius: BorderRadius.circular(30), border: Border.all(color: a(Colors.white, .25))),
      child: Row(children: [
        for (int i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 40,
                decoration: BoxDecoration(color: value == i ? K.blue : Colors.transparent, borderRadius: BorderRadius.circular(24)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Flexible(child: Text(labels[i], style: tx(13.5, w: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                  if (counts != null) ...[
                    const SizedBox(width: 6),
                    Container(width: 20, height: 20, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: a(Colors.white, .18)), child: Text('${counts![i]}', style: tx(11))),
                  ],
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

// ───────────────────────── Resumen ─────────────────────────
class ResumenTab extends StatefulWidget {
  const ResumenTab({super.key});
  @override
  State<ResumenTab> createState() => _ResumenTabState();
}

class _ResumenTabState extends State<ResumenTab> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    Widget pct(String t) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(12)), child: Text(t, style: tx(11, w: FontWeight.w700)));
    Widget kpi(String t, String vs, String v, String p) => FCard(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(t, style: tx(14.5, w: FontWeight.w700))), Text(vs, style: tx(11, w: FontWeight.w500))]),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: Text(v, style: tx(14, w: FontWeight.w700))), pct(p)]),
          ]),
        );
    const bars = [22.0, 38.0, 32.0, 90.0, 52.0, 26.0, 18.0];
    return ListView(padding: const EdgeInsets.fromLTRB(22, 12, 22, 120), children: [
      Text('Resumen', style: tx(22, w: FontWeight.w700)),
      Text('Todo lo que necesitas saber', style: tx(14, w: FontWeight.w500)),
      const SizedBox(height: 16),
      _Seg(labels: const ['Envíos', 'Viajes', 'Facturas'], value: tab, onChanged: (i) => setState(() => tab = i)),
      const SizedBox(height: 14),
      FCard(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 112,
          child: Stack(children: [
            Positioned(right: 30, top: 0, child: Image.asset('assets/img/truck.webp', width: 120)),
            Positioned(right: -8, top: 46, child: Image.asset('assets/img/car.webp', width: 96)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total de ${tab == 1 ? 'viajes' : 'envíos'} realizados', style: tx(14, w: FontWeight.w700)),
              Text(tab == 1 ? '2,140' : '8,400', style: tx(50, w: FontWeight.w800, h: 1.1)),
              Row(children: [pct('+15%'), const SizedBox(width: 6), Text('vs. mes anterior', style: tx(11, w: FontWeight.w500))]),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: kpi('Hoy', 'vs Ayer', '45 envío', '+15%')), const SizedBox(width: 10), Expanded(child: kpi('Esta semana', 'vs Pasada', '286 envío', '+18%'))]),
      const SizedBox(height: 10),
      kpi('Este mes', 'vs Mes pasado', '1,024 envío', '+24%'),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF1F6BFF), Color(0xFF2E7DFF)])),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: a(Colors.white, .9)), child: const Icon(Icons.trending_up, color: K.blue)),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tu mejor día fue el jueves', style: tx(15, w: FontWeight.w700)), Text('Realizaste 1,250 envío', style: tx(12.5, w: FontWeight.w500))]),
        ]),
      ),
      const SizedBox(height: 10),
      FCard(
        child: Column(children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: K.blue, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.bar_chart_rounded, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Rendimiento semanal', style: tx(14, w: FontWeight.w700)), Text('Comparativa de viajes realizados', style: tx(11, w: FontWeight.w500))])),
            pct('+15% vs sem. ant.'),
          ]),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              for (int i = 0; i < 7; i++)
                Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (i == 3)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(color: a(Colors.white, .12), borderRadius: BorderRadius.circular(10), border: Border.all(color: a(Colors.white, .3))),
                      child: Text('Jueves\n1,250', style: tx(11, w: FontWeight.w700), textAlign: TextAlign.center),
                    ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: bars[i]),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Container(
                      width: 12,
                      height: v,
                      decoration: BoxDecoration(color: i == 3 ? K.blue : a(Colors.white, .3), borderRadius: BorderRadius.circular(8), boxShadow: i == 3 ? [BoxShadow(color: a(K.blue, .8), blurRadius: 14)] : null),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('LMMJVSD'[i], style: tx(12)),
                ]),
            ]),
          ),
        ]),
      ),
    ]);
  }
}

class _PerfilTab extends StatelessWidget {
  const _PerfilTab();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(22, 12, 22, 120), children: [
      Text('Tú', style: tx(22, w: FontWeight.w700)),
      const SizedBox(height: 18),
      FCard(
        child: Row(children: [
          const CircleAvatar(radius: 30, backgroundColor: K.blue, backgroundImage: AssetImage('assets/img/m_head.webp')),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mario Belfort', style: tx(18, w: FontWeight.w700)),
              Text('Floristería Bella Rosa · Plan Empresa', style: tx(12.5, w: FontWeight.w500)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      for (final (i, t) in [(Icons.receipt_long, 'Historial de facturas'), (Icons.location_on_outlined, 'Direcciones guardadas'), (Icons.credit_card, 'Métodos de pago'), (Icons.support_agent, 'Soporte'), (Icons.logout, 'Cerrar sesión')])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [Icon(i, color: Colors.white), const SizedBox(width: 14), Expanded(child: Text(t, style: tx(14.5))), const Icon(Icons.chevron_right, color: Colors.white)]),
          ),
        ),
    ]);
  }
}
