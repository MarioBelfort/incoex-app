import 'package:flutter/material.dart';

import '../core.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late final AnimationController ac = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
  bool hide = true;
  @override
  void dispose() {
    ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final cardTop = h * .38;
    return Scaffold(
      backgroundColor: K.navy,
      resizeToAvoidBottomInset: false,
      body: Stack(fit: StackFit.expand, children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(center: Alignment(.4, -.65), radius: .9, colors: [Color(0xCC285ADC), Color(0xFF05164F), Color(0xFF020A2A)], stops: [0, .55, 1]),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: cardTop,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
            child: Stack(children: [
              const Positioned.fill(child: FBg()),
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(34, h * .14, 34, 30),
                  child: Column(children: [
                    Text('Iniciar sesión', style: tx(27, w: FontWeight.w700)),
                    const SizedBox(height: 24),
                    const FField(icon: Icons.mail_outline_rounded, label: 'Correo', plain: true, minHeight: 50),
                    FField(
                      icon: Icons.lock_outline_rounded,
                      label: 'Contraseña',
                      plain: true,
                      obscure: hide,
                      minHeight: 50,
                      trailing: GestureDetector(onTap: () => setState(() => hide = !hide), child: Icon(hide ? Icons.visibility : Icons.visibility_off, color: Colors.white, size: 20)),
                    ),
                    FButton('Iniciar sesión', height: 50, onTap: () => go(context, const HomeShell(), replace: true)),
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: () => go(context, const RegistroScreen()),
                      child: Text.rich(TextSpan(text: '¿No tienes cuenta? ', style: tx(13), children: [
                        TextSpan(text: 'Regístrate aquí', style: tx(13, w: FontWeight.w700).copyWith(decoration: TextDecoration.underline, decorationColor: Colors.white)),
                      ])),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        Positioned(
          right: -2,
          top: cardTop - 290,
          child: AnimatedBuilder(
            animation: ac,
            builder: (_, child) => Transform.rotate(angle: -.02 * ac.value, alignment: const Alignment(.4, .9), child: child),
            child: Image.asset('assets/img/m_lean.webp', width: 300),
          ),
        ),
      ]),
    );
  }
}

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  bool terms = false;
  @override
  Widget build(BuildContext context) {
    const f = [
      (Icons.person, 'Nombre completo'),
      (Icons.apartment, 'Nombre de la Empresa'),
      (Icons.badge, 'Número de Cédula'),
      (Icons.badge, 'Número RUC'),
      (Icons.phone, 'Celular / WhatsApp'),
      (Icons.mail, 'Correo Electrónico'),
      (Icons.lock, 'Contraseña'),
    ];
    return FScaffold(children: [
      const FHeader('Registro de Empresa', subtitle: 'Crea tu cuenta corporativa para continuar'),
      for (final x in f) FField(icon: x.$1, label: x.$2, plain: true, obscure: x.$2 == 'Contraseña', minHeight: 50),
      const SizedBox(height: 8),
      Text('Documentos Requeridos', style: tx(19, w: FontWeight.w700)),
      Text('Formatos aceptados: JPG, PNG o PDF (Máx. 5MB)', style: tx(12.5)),
      const SizedBox(height: 12),
      const Dashed(icon: Icons.upload_rounded, title: 'Adjuntar Matrícula de la Alcaldía y Cédula RUC', sub: 'Sube la patente comercial municipal'),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () => setState(() => terms = !terms),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Radio2(terms),
          const SizedBox(width: 12),
          Expanded(child: Text('Acepto los Términos de Servicio y la Política de Privacidad de INCOEX.', style: tx(12.5))),
        ]),
      ),
      const SizedBox(height: 18),
      FButton('Crear cuenta empresa', onTap: () => go(context, const StatusScreen(approved: false))),
    ]);
  }
}

class StatusScreen extends StatelessWidget {
  final bool approved;
  const StatusScreen({super.key, required this.approved});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.navy,
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: FBg()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 10, 28, 20),
            child: Column(children: [
              Row(children: [Image.asset('assets/img/logo.webp', width: 34), const SizedBox(width: 6), Text('INCOEX', style: tx(20, w: FontWeight.w800))]),
              Expanded(
                child: ListView(children: [
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: .7, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.elasticOut,
                    builder: (_, v, c) => Transform.scale(scale: v, child: c),
                    child: Image.asset('assets/img/m_front.webp', height: 260),
                  ),
                  const SizedBox(height: 10),
                  Text(approved ? '¡Cuenta aprobada!' : '¡Registro completado!', style: tx(24, w: FontWeight.w700), textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text(
                    approved
                        ? 'Tu cuenta ha sido verificada por INCOEX. Ya puedes comenzar a utilizar la aplicación.'
                        : 'Hemos recibido tu información. Ahora nuestro equipo de INCOEX revisará tus datos.',
                    style: tx(14, w: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  if (!approved)
                    FCard(
                      padding: const EdgeInsets.all(18),
                      child: Row(children: [
                        Container(width: 46, height: 46, decoration: const BoxDecoration(color: K.blue, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('En revisión por INCOEX', style: tx(16, w: FontWeight.w700)),
                            Text('Te notificaremos en cuanto tu cuenta sea aprobada.', style: tx(13, w: FontWeight.w500)),
                          ]),
                        ),
                      ]),
                    )
                  else
                    FCard(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Column(children: [
                        for (final t in ['Solicita tus envíos', 'Realiza pedidos', 'Da seguimiento en tiempo real', 'Accede a todos los servicios'])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Row(children: [
                              Container(width: 26, height: 26, decoration: const BoxDecoration(color: K.green, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 16, color: Colors.white)),
                              const SizedBox(width: 12),
                              Text(t, style: tx(14.5)),
                            ]),
                          ),
                      ]),
                    ),
                ]),
              ),
              FButton(
                approved ? 'Comenzar ahora' : 'Entendido',
                height: 48,
                onTap: () => approved
                    ? Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false)
                    : go(context, const StatusScreen(approved: true), replace: true),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
