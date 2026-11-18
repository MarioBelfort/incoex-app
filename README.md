# INCOEX Logistics · App

App de envíos para empresas (Flutter), basada en el diseño de Figma «Propuestas».

## Cómo obtener el APK
Cada cambio que se sube a `main` compila la app automáticamente (GitHub Actions).
El APK queda en **Releases** → `INCOEX.apk`. Descárgalo desde un teléfono Android y ábrelo para instalarlo
(Android pedirá permitir «instalar apps de origen desconocido» la primera vez).

## Estructura
- `lib/core.dart` – colores, tipografía, componentes visuales, datos y estado (simulación del viaje).
- `lib/map.dart` – mapa estilo satelital, ruta y vehículo en movimiento.
- `lib/screens/` – pantallas: login y registro, inicio, envíos, resumen, origen/destino, pasos 2–4, servicios adicionales, asignando conductor, seguimiento, llamada, viaje terminado, cobros.
- `assets/img/` – mascota, vehículos y logo.

Versión 1: datos simulados (sin servidor). Fase 2: backend (Firebase/Supabase), app del conductor con GPS y Google Maps.
