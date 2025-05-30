# 📅 Días de Oficina

Aplicación Flutter para organizar de forma eficiente los días laborales de oficina, ideal para personas que trabajan en modalidad híbrida. Permite preseleccionar días respetando restricciones semanales y guardar esa información de forma local.

---

## 🚀 Funcionalidades principales

- 📆 Calendario visual para cada mes del año.
- 🟡 Días preseleccionados en amarillo, 🟢 días confirmados en verde.
- ✅ Validación para que ninguna semana tenga más de 3 días laborales (aunque compartan meses).
- 👤 Persistencia del nombre del usuario (recordado automáticamente).
- 🔁 Cierre de sesión para cambiar de usuario.
- 🧠 Detección de meses con días ya seleccionados (marcados en la pantalla de selección).
- 🗓️ Vista por meses del año 2025, pensada para expandirse a más años.
- 📱 Optimizada para Android (formato APK funcional).

---

## 🛠️ Tecnologías utilizadas

- Flutter 3.x
- Dart
- SQLite (con `sqflite`)
- SharedPreferences
- TableCalendar

---

## 🧪 Instalación local

### 1. Clona el repositorio:

bash
git clone https://github.com/tu_usuario/dias-de-oficina.git
cd dias-de-oficina

### 2. Instala dependencias:
flutter pub get

### 3. Ejecuta la app:
flutter run

### 4. Compilar APK:
flutter build apk --release
ruta: build/app/outputs/flutter-apk/app-release.apk 

## 🧩 Estructura general

📂 lib
 ┣ 📂 screens              # Pantallas principales (bienvenida, meses, generador, etc.)
 ┣ 📂 data                 # Configuración SQLite
 ┣ main.dart              # Punto de entrada de la app

🤝 Contribuciones

Este proyecto es personal, pero si deseas colaborar puedes abrir un Pull Request o crear un Issue.
📄 Licencia
MIT
