import 'package:flutter/material.dart';

import '../core.dart';
import '../map.dart';
import 'trip.dart';

// ───────────────────────── Origen / destino + vehículo ─────────────────────────
class RutaScreen extends StatefulWidget {
  const RutaScreen({super.key});
  @override
  State<RutaScreen> createState() => _RutaScreenState();
}

class _RutaScreenState extends State<RutaScreen> {
  bool programar = false;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final list = app.viajes ? vehicles.where((v) => v.id == 'auto' || v.id == 'pickup').toList() : vehicles;
        return Scaffold(
          backgroundColor: K.navy,
          body: Stack(fit: StackFit.expand, children: [
            Positioned.fill(child: TripMap(frame: const MapFrame(left: .12, top: .26, scale: .75, lake: .1), onlyAB: true, showVehicle: false, showRoute: app.dest)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GestureDetector(
                    onTap: () => programar ? setState(() => programar = false) : Navigator.pop(context),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.only(left: 12, right: 24),
                      decoration: BoxDecoration(color: a(const Color(0xFF030824), .88), borderRadius: BorderRadius.circular(30), border: Border.all(color: a(Colors.white, .15))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30), Text('Regresar al inicio', style: tx(15, w: FontWeight.w700))]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OrigenDestino(onMap: () => app.set(() => app.dest = true)),
                ]),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (c, an) => SlideTransition(position: Tween(begin: const Offset(0, .25), end: Offset.zero).animate(an), child: FadeTransition(opacity: an, child: c)),
                child: programar ? _programarSheet() : _vehSheet(list),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _sheet({required Widget child, Key? key}) => Container(
        key: key,
        padding: EdgeInsets.fromLTRB(22, 14, 22, 16 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [a(const Color(0xFF060C32), .97), a(const Color(0xFF02061E), .99)]),
          border: Border(top: BorderSide(color: a(Colors.white, .14))),
          boxShadow: [BoxShadow(color: a(Colors.black, .6), blurRadius: 40)],
        ),
        child: child,
      );

  Widget _vehSheet(List<Veh> list) {
    final ml = app.minLvl;
    return _sheet(
      key: const ValueKey('veh'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: a(Colors.white, .85), borderRadius: BorderRadius.circular(5)))),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text(app.viajes ? 'Viajes' : 'Envíos', style: tx(24, w: FontWeight.w700))),
          GestureDetector(
            onTap: () => setState(() => programar = true),
            child: Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 22), alignment: Alignment.center, decoration: BoxDecoration(color: K.blue, borderRadius: BorderRadius.circular(14)), child: Text('Programar', style: tx(15, w: FontWeight.w700))),
          ),
        ]),
        if (app.sched)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const Icon(Icons.event_available, color: K.ice, size: 18),
              const SizedBox(width: 6),
              Text('Programado: ${dayLabel(app.schedD).replaceAll('\n', ' ')} · ${hours[app.schedT]}', style: tx(12.5, w: FontWeight.w700, c: K.ice)),
            ]),
          ),
        const SizedBox(height: 12),
        Row(children: [
          for (final (i, l) in [(0, 'Envíos'), (1, 'Viajes')])
            GestureDetector(
              onTap: () => app.set(() {
                app.viajes = i == 1;
                if (app.viajes && (app.veh == 'moto' || app.veh == 'camion')) app.veh = 'auto';
              }),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (app.viajes ? 1 : 0) == i ? K.blue : a(const Color(0xFF030824), .8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (app.viajes ? 1 : 0) == i ? K.blue : a(Colors.white, .18)),
                ),
                child: Text(l, style: tx(15, w: FontWeight.w700, c: (app.viajes ? 1 : 0) == i ? Colors.white : a(Colors.white, .7))),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final v = list[i];
              final idx = vehicles.indexOf(v);
              final no = !app.viajes && idx < ml;
              final on = app.veh == v.id;
              return GestureDetector(
                onTap: () => app.set(() => app.veh = v.id),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: no ? .45 : 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 158,
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a(const Color(0xFF0A1446), .9), a(const Color(0xFF030824), .95)]),
                      border: Border.all(color: on ? const Color(0xFF3D8BFF) : a(Colors.white, .14), width: 1.5),
                      boxShadow: on ? [BoxShadow(color: a(K.blue, .5), blurRadius: 24, spreadRadius: -6)] : null,
                    ),
                    child: Stack(children: [
                      Positioned(left: 0, right: 0, top: 2, child: Center(child: VehImg(v.id, height: 82))),
                      if (!app.viajes && idx == ml && ml > 0)
                        Positioned(right: 0, top: 0, child: Pill('IDEAL', color: K.yellow, textColor: const Color(0xFF1D1400), fs: 9.5, pad: const EdgeInsets.symmetric(horizontal: 7, vertical: 3))),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(app.viajes && v.id == 'pickup' ? 'SUV' : v.name, style: tx(16, w: FontWeight.w700)),
                          Text(fmt(app.price(v.id)), style: tx(16, w: FontWeight.w700)),
                        ]),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        FButton(
          app.dest ? 'Completar formulario de ${app.viajes ? 'viaje' : 'envío'}' : 'Elige el destino en el mapa',
          onTap: () => app.dest ? go(context, const Paso2Screen()) : app.set(() => app.dest = true),
        ),
      ]),
    );
  }

  Widget _programarSheet() {
    Widget chip(String t, bool on, VoidCallback f, {bool center = false}) => Expanded(
          child: GestureDetector(
            onTap: f,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: center ? 0 : 12),
              alignment: center ? Alignment.center : Alignment.centerLeft,
              decoration: BoxDecoration(color: on ? K.blue : a(const Color(0xFF030824), .8), borderRadius: BorderRadius.circular(16), border: Border.all(color: on ? K.blue : a(Colors.white, .14))),
              child: Text(t, style: tx(13.5, w: FontWeight.w700, c: on ? Colors.white : a(Colors.white, .55)), textAlign: center ? TextAlign.center : TextAlign.left),
            ),
          ),
        );
    Widget iconChip(IconData i) => Container(width: 62, height: 70, decoration: BoxDecoration(color: a(const Color(0xFF030824), .8), borderRadius: BorderRadius.circular(16), border: Border.all(color: a(Colors.white, .14))), child: Icon(i, color: Colors.white, size: 28));
    return _sheet(
      key: const ValueKey('prog'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(onTap: () => setState(() => programar = false), child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Programa tu envío', style: tx(22, w: FontWeight.w700)),
              Text('Selecciona el momento que mejor se adapte a tu necesidad', style: tx(13.5)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [const Icon(Icons.event_note_outlined, color: Colors.white, size: 28), const SizedBox(width: 10), Text('Fecha de envío', style: tx(21, w: FontWeight.w700))]),
        const SizedBox(height: 12),
        Row(children: [for (int i = 0; i < 4; i++) chip(dayLabel(i), app.schedD == i, () => app.set(() => app.schedD = i)), iconChip(Icons.edit_calendar_outlined)]),
        const SizedBox(height: 16),
        Row(children: [const Icon(Icons.schedule, color: Colors.white, size: 28), const SizedBox(width: 10), Text('Horario de envío', style: tx(21, w: FontWeight.w700))]),
        const SizedBox(height: 12),
        Row(children: [for (int i = 0; i < 4; i++) chip(hours[i].replaceAll(' ', '\n'), app.schedT == i, () => app.set(() => app.schedT = i), center: true), iconChip(Icons.schedule)]),
        const SizedBox(height: 18),
        Row(children: [
          const Icon(Icons.info_outline, color: Color(0xFF3D8BFF)),
          const SizedBox(width: 10),
          Expanded(child: Text('La disponibilidad y precio será confirmada junto con tu selección.', style: tx(13.5))),
        ]),
        const SizedBox(height: 16),
        FButton('Confirmar horario', onTap: () {
          app.set(() => app.sched = true);
          setState(() => programar = false);
        }),
      ]),
    );
  }
}

class _OrigenDestino extends StatelessWidget {
  final VoidCallback onMap;
  const _OrigenDestino({required this.onMap});
  @override
  Widget build(BuildContext context) {
    Widget btn(String t, IconData i, bool blue, VoidCallback f) => GestureDetector(
          onTap: f,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: blue ? K.blue : a(const Color(0xFF030824), .8), borderRadius: BorderRadius.circular(20), border: Border.all(color: blue ? K.blue : a(Colors.white, .3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 14, color: Colors.white), const SizedBox(width: 6), Text(t, style: tx(12, w: FontWeight.w700))]),
          ),
        );
    Widget circ(IconData i) => Container(width: 44, height: 44, decoration: const BoxDecoration(color: K.blue, shape: BoxShape.circle), child: Icon(i, color: Colors.white, size: 22));
    return FCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          circ(Icons.home_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Origen', style: tx(15.5, w: FontWeight.w700)),
              Text('Av. Ejemplo, del ejemplo 249', style: tx(14), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(app.from, style: tx(12.5, c: K.label), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          btn('Editar', Icons.edit_outlined, false, () {}),
        ]),
        Padding(padding: const EdgeInsets.only(left: 58, top: 10, bottom: 10), child: Container(height: 1, color: a(const Color(0xFF78A0FF), .6))),
        Row(children: [
          circ(Icons.flag_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Destino final', style: tx(15.5, w: FontWeight.w700)),
              Text(app.dest ? app.to : '¿A donde va tu pedido?', style: tx(14), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (app.dest) Text('${app.km} km · 18 min aprox.', style: tx(12.5, c: K.label)),
            ]),
          ),
          btn('Mapa', Icons.map_outlined, true, onMap),
        ]),
      ]),
    );
  }
}

// ───────────────────────── Paso 2 ─────────────────────────
class Paso2Screen extends StatefulWidget {
  const Paso2Screen({super.key});
  @override
  State<Paso2Screen> createState() => _Paso2ScreenState();
}

class _Paso2ScreenState extends State<Paso2Screen> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final v = vehById(app.veh);
        final c = app.cargoObj;
        final ml = app.minLvl;
        final fits = vehicles.indexOf(v) >= ml;
        return FScaffold(
          bottom: FButton('Siguiente', onTap: () => app.cargoSet ? go(context, const Paso3Screen()) : setState(() => open = true)),
          children: [
            FHeader(app.viajes ? 'Viajes' : 'Envíos', paso: 'Paso 2'),
            FCard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 290,
                child: Stack(children: [
                  Positioned(left: 26, top: 18, child: Text(v.name, style: tx(21, w: FontWeight.w700))),
                  Positioned(right: 20, top: 14, child: Pill('Seleccionado', color: K.blue, fs: 13)),
                  Positioned(left: 10, right: 10, top: 58, bottom: 14, child: Hero(tag: 'veh', child: VehImg(v.id))),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.inventory_2_outlined, color: Colors.white, size: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('¿Qué vamos a transportar?', style: tx(21, w: FontWeight.w700)),
                  Text('Esta información nos ayudará a preparar correctamente el recojo y despacho', style: tx(14, w: FontWeight.w500)),
                ]),
              ),
            ]),
            const SizedBox(height: 16),
            FField(
              icon: Icons.view_in_ar_rounded,
              label: 'Tipo de paquete',
              hint: 'Ej. Muebles, cajas, mercadería, electrodomésticos',
              value: app.cargoSet ? c.name : null,
              minHeight: 70,
              onTap: () => setState(() => open = !open),
              trailing: Icon(open ? Icons.expand_less : Icons.chevron_right, color: Colors.white),
            ),
            if (open)
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final k in cargos)
                  GestureDetector(
                    onTap: () {
                      app.set(() {
                        app.cargo = k.id;
                        app.cargoSet = true;
                      });
                      setState(() => open = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                      decoration: BoxDecoration(
                        color: app.cargoSet && app.cargo == k.id ? K.blue : a(const Color(0xFF030824), .8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: app.cargoSet && app.cargo == k.id ? K.blue : a(Colors.white, .2)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(k.icon, size: 16, color: Colors.white), const SizedBox(width: 6), Text(k.name, style: tx(12.5, w: FontWeight.w700))]),
                    ),
                  ),
              ]),
            if (app.cargoSet && !fits)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: a(K.yellow, .1), borderRadius: BorderRadius.circular(16), border: Border.all(color: a(K.yellow, .45))),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: K.yellow),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(TextSpan(style: tx(12.5), children: [
                      TextSpan(text: '${c.note.isEmpty ? 'Esta carga no cabe en ${v.name.toLowerCase()}.' : c.note}\n'),
                      TextSpan(text: '${vehicles[ml].name}: ${fmt(app.price(vehicles[ml].id))}', style: tx(12.5, w: FontWeight.w800)),
                      TextSpan(text: ' · ${v.name}: ${fmt(app.price(v.id))}'),
                    ])),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => app.set(() => app.veh = vehicles[ml].id),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: K.yellow, borderRadius: BorderRadius.circular(12)), child: Text('Cambiar', style: tx(12, w: FontWeight.w800, c: const Color(0xFF1D1400)))),
                  ),
                ]),
              ),
            const SizedBox(height: 12),
            FCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _boxHead(Icons.shopping_cart_outlined, '¿Este envío corresponde a una venta?', 'Indica si este envío tiene un producto asociado a la venta.'),
                const SizedBox(height: 12),
                Row(children: [
                  for (final (on, l) in [(true, 'Sí'), (false, 'No')])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => app.set(() => app.venta = on),
                        child: Container(
                          margin: EdgeInsets.only(right: on ? 8 : 0),
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: app.venta == on ? K.blue : a(const Color(0xFF0A1E64), .45),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: app.venta == on ? const Color(0xFF4D8FFF) : a(const Color(0xFF78A0FF), .3)),
                          ),
                          child: Row(children: [Radio2(app.venta == on, size: 18), const SizedBox(width: 10), Text(l, style: tx(14, w: FontWeight.w700))]),
                        ),
                      ),
                    ),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            FCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _boxHead(Icons.view_in_ar_rounded, 'Valor aproximado del producto', 'Ingresa un valor aproximado del costo de tu producto'),
                const SizedBox(height: 12),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: a(const Color(0xFF02061E), .9), borderRadius: BorderRadius.circular(12), border: Border.all(color: a(Colors.white, .2))),
                  child: Row(children: [
                    Text('C\$ ', style: tx(16, w: FontWeight.w800)),
                    Expanded(
                      child: TextFormField(
                        initialValue: '${app.valor}',
                        keyboardType: TextInputType.number,
                        style: tx(16, w: FontWeight.w800),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        onChanged: (s) => app.valor = int.tryParse(s.replaceAll(RegExp(r'\D'), '')) ?? 0,
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            Row(children: [const Icon(Icons.add_photo_alternate_outlined, color: Colors.white), const SizedBox(width: 10), Text('Fotos del producto', style: tx(17, w: FontWeight.w700))]),
            Padding(padding: const EdgeInsets.only(left: 34, top: 2, bottom: 12), child: Text('Ayúdanos a verificar el espacio y la manipulación', style: tx(12))),
            const Dashed(icon: Icons.add_photo_alternate_outlined, title: 'Subir fotos del producto', sub: 'Formatos soportados: JPG, PNG (Max 5MB)'),
            const SizedBox(height: 18),
            Row(children: [
              const Icon(Icons.wine_bar, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text('¿El producto es frágil?', style: tx(17, w: FontWeight.w700))),
              YesNo(value: app.fragil, onChanged: (v) => app.set(() => app.fragil = v)),
            ]),
          ],
        );
      },
    );
  }
}

Widget _boxHead(IconData i, String t, String s) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(i, color: Colors.white, size: 26),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: tx(14.5, w: FontWeight.w700)), Text(s, style: tx(11.5, w: FontWeight.w500))])),
    ]);

// ───────────────────────── Paso 3 ─────────────────────────
class Paso3Screen extends StatefulWidget {
  const Paso3Screen({super.key});
  @override
  State<Paso3Screen> createState() => _Paso3ScreenState();
}

class _Paso3ScreenState extends State<Paso3Screen> {
  bool sheet = false;

  List<(String, IconData, String, String, Widget)> get svcs {
    final v = vehById(app.veh);
    final plural = {'moto': 'motos', 'auto': 'autos', 'pickup': 'pickups', 'camion': 'camiones'}[v.id]!;
    return [
      ('ida', Icons.local_shipping_outlined, 'Ida y vuelta', 'Regreso al origen', const SvcIdaScreen()),
      ('mas', v.id == 'moto' ? Icons.moped : Icons.directions_car, '¿Más $plural?', 'Más a una misma ruta', const SvcMasScreen()),
      ('multi', Icons.call_split_rounded, 'Varios destinos', 'Múltiples destinos', const SvcMultiScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => FScaffold(
        bottom: FButton('Siguiente', onTap: () => go(context, const Paso4Screen())),
        overlay: sheet ? _svcSheet() : null,
        children: [
          FHeader(app.viajes ? 'Viajes' : 'Envíos', paso: 'Paso 3'),
          const SecTitle(Icons.local_shipping_outlined, 'Detalles de recojo', sub: 'Persona que entrega el paquete', top: 0),
          const Row(children: [
            Expanded(child: FField(icon: Icons.person, label: 'Nombre', hint: 'Ej. Juan Hernandez', value: 'Mario Belfort')),
            SizedBox(width: 10),
            Expanded(child: FField(icon: Icons.phone, label: 'Teléfono', hint: 'Ej. 43243 12312', value: '8888 1234')),
          ]),
          FField(icon: Icons.location_on, label: 'Referencia del lugar', hint: 'Ej. Jiron Gabriel de los Santos', value: app.from),
          const FField(icon: Icons.info_outline, label: 'Indicaciones adicionales', hint: 'Ej. Muebles, cajas, mercadería, electrodomésticos'),
          const SecTitle(Icons.local_shipping_outlined, 'Detalles de envío', sub: 'Persona a la que se entrega el paquete'),
          Row(children: [
            Expanded(child: FField(icon: Icons.person, label: 'Nombre', hint: 'Ej. Juan Hernandez', value: app.recip, onChanged: (s) => app.recip = s)),
            const SizedBox(width: 10),
            Expanded(child: FField(icon: Icons.phone, label: 'Teléfono', hint: 'Ej. 43243 12312', value: app.recipTel, onChanged: (s) => app.recipTel = s)),
          ]),
          FField(icon: Icons.location_on, label: 'Referencia del lugar', hint: 'Ej. Jiron Gabriel de los Santos', value: app.to),
          const FField(icon: Icons.info_outline, label: 'Indicaciones adicionales', hint: 'Ej. Muebles, cajas, mercadería, electrodomésticos'),
          SecTitle(
            Icons.settings_outlined,
            'Servicios adicionales',
            sub: 'Añade servicios extra si los necesitas',
            trailing: GestureDetector(
              onTap: () => setState(() => sheet = true),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: K.blue, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Ver todos', style: tx(13, w: FontWeight.w700)), const Icon(Icons.chevron_right, color: Colors.white, size: 18)]),
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.9,
            children: [
              for (final s in svcs) _svcTile(s),
              Container(
                padding: const EdgeInsets.all(14),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(color: a(const Color(0xFF02061E), .8), borderRadius: BorderRadius.circular(18), border: Border.all(color: a(Colors.white, .14))),
                child: Text('Proximamente...', style: tx(13, w: FontWeight.w700, c: a(Colors.white, .55))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _svcTile((String, IconData, String, String, Widget) s) {
    final on = app.svc[s.$1]!;
    final c = on ? Colors.white : a(Colors.white, .55);
    return GestureDetector(
      onTap: () => on ? app.set(() => app.svc[s.$1] = false) : go(context, s.$5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: on ? [a(const Color(0xFF143CB4), .55), a(const Color(0xFF061046), .85)] : [a(const Color(0xFF060C30), .7), a(const Color(0xFF02061E), .85)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? const Color(0xFF3D8BFF) : a(Colors.white, .14)),
        ),
        child: Row(children: [
          Icon(s.$2, color: c, size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.$3, style: tx(12.5, w: FontWeight.w700, c: c), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(s.$4, style: tx(10, w: FontWeight.w500, c: c), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('C\$ 1,440', style: tx(10, w: FontWeight.w700, c: c)),
            ]),
          ),
          Radio2(on, size: 20),
        ]),
      ),
    );
  }

  Widget _svcSheet() {
    return GestureDetector(
      onTap: () => setState(() => sheet = false),
      child: Container(
        color: a(Colors.black, .55),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.fromLTRB(22, 14, 22, 18 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [a(const Color(0xFF060C32), .98), const Color(0xFF02061E)]),
              border: Border(top: BorderSide(color: a(Colors.white, .14))),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: a(Colors.white, .85), borderRadius: BorderRadius.circular(5)))),
              const SecTitle(Icons.settings_outlined, 'Servicios adicionales', sub: 'Añade servicios extra si los necesitas', top: 18),
              for (final s in svcs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => sheet = false);
                      go(context, s.$5);
                    },
                    child: FCard(
                      radius: 18,
                      border: app.svc[s.$1]! ? const Color(0xFF3D8BFF) : null,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(children: [
                        Icon(s.$2, color: a(Colors.white, .8), size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.$3, style: tx(14, w: FontWeight.w700, c: a(Colors.white, .85))),
                            Text(s.$4, style: tx(11.5, w: FontWeight.w500, c: a(Colors.white, .65))),
                            Text('C\$ 1,440', style: tx(11.5, w: FontWeight.w700, c: a(Colors.white, .65))),
                          ]),
                        ),
                        Radio2(app.svc[s.$1]!),
                      ]),
                    ),
                  ),
                ),
              FButton('Completar formulario de envío', onTap: () => setState(() => sheet = false)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Servicios ─────────────────────────
Widget _svcHead(IconData i, String t, String s) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFF06123F), borderRadius: BorderRadius.circular(16), border: Border.all(color: a(Colors.white, .2))), child: Icon(i, color: Colors.white, size: 30)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: tx(18, w: FontWeight.w700)), Text(s, style: tx(12.5, w: FontWeight.w500))])),
      ]),
    );

class SvcMultiScreen extends StatelessWidget {
  const SvcMultiScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const names = ['Oficinas Incoex, Edificio Pellas', 'Galerías Santo Domingo', 'Hotel Barceló'];
    Widget stop(Widget n, String t, String b, String? s, {bool edit = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: const BoxDecoration(color: K.blue, shape: BoxShape.circle), alignment: Alignment.center, child: n),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: tx(14.5, w: FontWeight.w700)),
                Text(b, style: tx(14, w: FontWeight.w500)),
                if (s != null) Text(s, style: tx(12, c: K.label)),
              ]),
            ),
            if (edit) Pill('Editar', fs: 12, pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 6)),
          ]),
        );
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => FScaffold(
        bottom: FButton('Confirmar destinos', onTap: () {
          app.set(() => app.svc['multi'] = true);
          Navigator.pop(context);
        }),
        children: [
          const FHeader('Servicios adicionales'),
          _svcHead(Icons.call_split_rounded, 'Varios destinos', 'Agrega paradas y ordénalas según el recorrido que necesitas.'),
          const SizedBox(height: 12),
          FCard(
            child: Column(children: [
              stop(const Icon(Icons.home_rounded, color: Colors.white, size: 20), 'Origen', 'Av. Ejemplo, del ejemplo 249', 'Floristería Bella Rosa', edit: true),
              for (int i = 0; i < app.stops; i++) ...[
                Divider(color: a(const Color(0xFF78A0FF), .45), indent: 54, height: 1),
                stop(Text('${i + 1}', style: tx(15, w: FontWeight.w800)), 'Parada ${i + 1}', names[i % 3], 'Av. Ejemplo, del ejemplo 249'),
              ],
              Divider(color: a(const Color(0xFF78A0FF), .45), indent: 54, height: 1),
              stop(const Icon(Icons.flag_rounded, color: Colors.white, size: 20), 'Destino final', app.to, null, edit: true),
            ]),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => app.set(() => app.stops++),
            child: CustomPaint(
              painter: _DashBorder(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                child: Row(children: [
                  Container(width: 46, height: 46, decoration: const BoxDecoration(color: K.blue, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 28)),
                  const SizedBox(width: 18),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Agregar parada adicional', style: tx(16, w: FontWeight.w700)), Text('Puedes agregar más paradas si lo necesitas.', style: tx(12.5, w: FontWeight.w500))])),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashBorder extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final r = RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(20));
    c.drawRRect(r, Paint()..color = a(const Color(0xFF030A2D), .55));
    final p = Paint()
      ..color = a(const Color(0xFF468CFF), .85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in (Path()..addRRect(r)).computeMetrics()) {
      for (double d = 0; d < m.length; d += 12) {
        c.drawPath(m.extractPath(d, d + 7), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SvcIdaScreen extends StatefulWidget {
  const SvcIdaScreen({super.key});
  @override
  State<SvcIdaScreen> createState() => _SvcIdaScreenState();
}

class _SvcIdaScreenState extends State<SvcIdaScreen> {
  bool fragil = true;
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      bottom: FButton('Confirmar ida y vuelta', onTap: () {
        app.set(() => app.svc['ida'] = true);
        Navigator.pop(context);
      }),
      children: [
        const FHeader('Servicios adicionales'),
        _svcHead(Icons.local_shipping_outlined, 'Ida y vuelta', 'Indícanos cómo deseas el recorrido del viaje.'),
        const SecTitle(Icons.settings_outlined, '¿Qué vamos a transportar devuelta?', sub: 'Esta información nos ayudará a preparar correctamente la vuelta del servicio'),
        const FField(icon: Icons.view_in_ar_rounded, label: 'Tipo de carga', hint: 'Ej. Muebles, cajas, mercadería, electrodomésticos'),
        const FField(icon: Icons.scale_outlined, label: 'Peso aproximado', hint: 'Ej. 20 kg', value: '20 kg'),
        const SizedBox(height: 6),
        Row(children: [const Icon(Icons.add_photo_alternate_outlined, color: Colors.white), const SizedBox(width: 10), Text('Fotos del cargamento', style: tx(17, w: FontWeight.w700))]),
        const SizedBox(height: 12),
        const Dashed(icon: Icons.add_photo_alternate_outlined, title: 'Subir fotos del paquete', sub: 'Formatos soportados: JPG, PNG (Max 5MB)'),
        const SizedBox(height: 18),
        Row(children: [
          const Icon(Icons.wine_bar, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text('¿El producto es frágil?', style: tx(17, w: FontWeight.w700))),
          YesNo(value: fragil, onChanged: (v) => setState(() => fragil = v)),
        ]),
        const SizedBox(height: 14),
        FCard(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.lightbulb_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('El servicio de ida y vuelta te permite utilizar el mismo vehículo para el regreso, ahorrando tiempo y costos.', style: tx(12, w: FontWeight.w500))),
          ]),
        ),
      ],
    );
  }
}

class SvcMasScreen extends StatelessWidget {
  const SvcMasScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final v = vehById(app.veh);
        final plural = {'moto': 'motos', 'auto': 'autos', 'pickup': 'pickups', 'camion': 'camiones'}[v.id]!;
        Widget round(String t, Color c, VoidCallback f) => GestureDetector(
              onTap: f,
              child: Container(width: 50, height: 50, alignment: Alignment.center, decoration: BoxDecoration(color: c, shape: BoxShape.circle), child: Text(t, style: tx(26, w: FontWeight.w300))),
            );
        return FScaffold(
          bottom: FButton('Añadir $plural', onTap: () {
            app.set(() => app.svc['mas'] = true);
            Navigator.pop(context);
          }),
          children: [
            const FHeader('Servicios adicionales'),
            _svcHead(v.id == 'moto' ? Icons.moped : Icons.directions_car, '¿Deseas añadir más $plural?', 'Agrega $plural para recoger tu mercadería'),
            SecTitle(Icons.settings_outlined, '¿Cuántos $plural adicionales quieres?', sub: 'Selecciona la cantidad de $plural'),
            FCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(children: [
                round('−', a(Colors.white, .18), () => app.set(() => app.masN = (app.masN - 1).clamp(1, 10))),
                Expanded(child: Column(children: [Text('${app.masN}', style: tx(28, w: FontWeight.w800)), Text(v.name, style: tx(12))])),
                round('+', K.blue, () => app.set(() => app.masN = (app.masN + 1).clamp(1, 10))),
              ]),
            ),
            const SizedBox(height: 14),
            FCard(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                const Icon(Icons.lightbulb_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(TextSpan(style: tx(12, w: FontWeight.w500), children: [
                    const TextSpan(text: 'Recuerda, los vehículos que agregues son del mismo tipo que seleccionaste previamente.\n'),
                    TextSpan(text: 'Ejemplo: ${v.name} + ${v.name}\n', style: tx(12, w: FontWeight.w800)),
                    TextSpan(text: 'Total adicional: ${fmt(app.price(v.id) * app.masN)}', style: tx(12, w: FontWeight.w800)),
                  ])),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}

// ───────────────────────── Paso 4 ─────────────────────────
class Paso4Screen extends StatelessWidget {
  const Paso4Screen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final tf = app.tarifa;
        final prod = app.venta ? app.valor : 0;
        Widget opt(bool on, Widget lead, String t, VoidCallback f) => Expanded(
              child: GestureDetector(
                onTap: f,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 46,
                  decoration: BoxDecoration(
                    color: on ? K.blue : a(const Color(0xFF0A1E64), .4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: on ? const Color(0xFF6AA5FF) : a(const Color(0xFF78A0FF), .3)),
                    boxShadow: on ? [BoxShadow(color: a(const Color(0xFF3C8CFF), .7), blurRadius: 16, spreadRadius: -4)] : null,
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [lead, const SizedBox(width: 6), Flexible(child: Text(t, style: tx(12, w: FontWeight.w700), overflow: TextOverflow.ellipsis))]),
                ),
              ),
            );
        Widget row(IconData i, String t, int v, String? badge) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Icon(i, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(t, style: tx(13.5, w: FontWeight.w500))),
                SizedBox(width: 70, child: Text(fmt(v), style: tx(13, w: FontWeight.w700), textAlign: TextAlign.right)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 96,
                  child: badge == null
                      ? Center(child: Text('—', style: tx(13)))
                      : Pill(badge, color: K.blue, fs: 10.5, pad: const EdgeInsets.symmetric(horizontal: 8, vertical: 5)),
                ),
              ]),
            );
        return FScaffold(
          children: [
            const FHeader('Detalles', paso: 'Paso 4'),
            Text('Detalles de facturación', style: tx(21, w: FontWeight.w700)),
            const SizedBox(height: 14),
            FCard(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                _boxHead(Icons.local_shipping_outlined, '¿Quién paga el envío?', 'Selecciona quién cubrirá la tarifa del transporte.'),
                const SizedBox(height: 12),
                Row(children: [
                  opt(app.payerRem, Radio2(app.payerRem, size: 18), 'Remitente / Comercio', () => app.set(() => app.payerRem = true)),
                  opt(!app.payerRem, Radio2(!app.payerRem, size: 18), 'Destinatario', () => app.set(() => app.payerRem = false)),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            FCard(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: _boxHead(Icons.person, 'Pago del ${app.payerRem ? 'remitente' : 'destinatario'}', '${app.payerRem ? 'Tú pagas' : 'El destinatario paga'} la tarifa de envío')),
                  Text(fmt(tf), style: tx(19, w: FontWeight.w800)),
                ]),
                const SizedBox(height: 12),
                Text('Método de pago', style: tx(12, w: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(children: [
                  for (final (k, i, l) in [('efectivo', Icons.payments_outlined, 'Efectivo'), ('transf', Icons.swap_horiz, 'Transferencia'), ('tarjeta', Icons.credit_card, 'Tarjeta')])
                    opt(app.method == k, Icon(i, color: Colors.white, size: 17), l, () => app.set(() => app.method = k)),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            FCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [const Icon(Icons.receipt_long_outlined, color: Colors.white), const SizedBox(width: 12), Text('Resumen del pedido', style: tx(15, w: FontWeight.w700))]),
                ),
                Divider(color: a(Colors.white, .12), height: 1),
                row(Icons.view_in_ar_rounded, 'Valor del producto', prod, app.venta ? 'Cobrar al entregar' : null),
                row(Icons.local_shipping_outlined, 'Tarifa de envío', tf, app.payerRem ? 'Paga remitente' : 'Paga destinatario'),
                row(Icons.shield, 'Seguro', 0, null),
              ]),
            ),
            const SizedBox(height: 12),
            FCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [Expanded(child: Text('Total a gestionar:', style: tx(13.5, w: FontWeight.w700))), Text(fmt(prod + tf), style: tx(20, w: FontWeight.w800))]),
            ),
            const SizedBox(height: 14),
            const Dashed(icon: Icons.add_photo_alternate_outlined, title: 'Adjuntar factura del producto', sub: 'Todos los formatos'),
            const SizedBox(height: 16),
            FButton('Siguiente', onTap: () {
              app.startTrip();
              go(context, const BuscandoScreen());
            }),
          ],
        );
      },
    );
  }
}
