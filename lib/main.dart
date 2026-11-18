import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core.dart';
import 'screens/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF020A2A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const IncoexApp());
}

class IncoexApp extends StatelessWidget {
  const IncoexApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INCOEX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Figtree',
        scaffoldBackgroundColor: K.navy,
        colorScheme: ColorScheme.fromSeed(seedColor: K.blue, brightness: Brightness.dark),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      builder: (context, child) => ResponsiveFrame(child: child!),
    );
  }
}

/// Hace que la app se adapte a cualquier pantalla:
/// - Celulares: ocupa toda la pantalla.
/// - Tablets y computadoras: la app se muestra centrada con un ancho cómodo de lectura
///   y el fondo de marca alrededor, sin estirar los componentes.
class ResponsiveFrame extends StatelessWidget {
  final Widget child;
  const ResponsiveFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Evita que tamaños de letra del sistema muy grandes rompan el diseño.
    final scaled = MediaQuery(
      data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: .85, maxScaleFactor: 1.15)),
      child: child,
    );
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 600) return scaled;
      final wide = c.maxWidth >= 1000;
      final appW = wide ? 460.0 : 520.0;
      final appH = wide ? (c.maxHeight - 48).clamp(600.0, 960.0) : c.maxHeight;
      return Stack(children: [
        const Positioned.fill(child: FBg()),
        if (wide)
          Positioned(
            left: 48,
            top: 0,
            bottom: 0,
            width: (c.maxWidth - appW) / 2 - 72,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.asset('assets/img/logo.webp', width: 64, color: Colors.white),
              const SizedBox(height: 18),
              Text('INCOEX Logistics', style: tx(34, w: FontWeight.w800)),
              const SizedBox(height: 10),
              Text('Envía en moto, auto, pickup o camión y sigue cada entrega en tiempo real.', style: tx(16, w: FontWeight.w500, c: a(Colors.white, .85))),
            ]),
          ),
        if (wide)
          Positioned(
            right: 24,
            bottom: 0,
            width: (c.maxWidth - appW) / 2 - 40,
            child: Image.asset('assets/img/m_front.webp', height: (c.maxHeight * .6).clamp(200, 520), alignment: Alignment.bottomRight),
          ),
        Center(
          child: Container(
            width: appW,
            height: appH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(wide ? 36 : 0),
              boxShadow: [BoxShadow(color: a(Colors.black, .5), blurRadius: 60, offset: const Offset(0, 20))],
              border: wide ? Border.all(color: a(Colors.white, .14)) : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery(
              data: mq.copyWith(size: Size(appW, appH), padding: wide ? EdgeInsets.zero : mq.padding, textScaler: mq.textScaler.clamp(minScaleFactor: .85, maxScaleFactor: 1.15)),
              child: child,
            ),
          ),
        ),
      ]);
    });
  }
}
