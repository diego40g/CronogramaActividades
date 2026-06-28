# CronogramaActividades

Gestión de actividades con línea de tiempo estilo _Structured_ + tareas estilo _TickTick_, sincronización con Google Calendar y dashboard web en Angular, usando Firebase como backend.

## Estructura del monorepo

```
CronogramaActividades/
├── flutter_app/          # App móvil Flutter (Android / iOS)
├── angular_app/          # Dashboard web Angular
├── firebase/             # Rules, indexes, Cloud Functions
├── shared/               # Interfaces TypeScript y esquema Firestore
└── flake.nix             # Entorno de desarrollo Nix reproducible
```

## Inicio rápido

### Entorno Nix

```bash
nix develop
```

### Flutter

```bash
cd flutter_app
flutter pub get
flutter run
```

### Angular

```bash
cd angular_app
npm install
ng serve
```

### Firebase

```bash
cd firebase/functions
npm install
firebase emulators:start
```

## Modelo de datos Firestore

```
users/{uid}
  └─ tasks/{taskId}
       └─ subtasks/{subtaskId}
  └─ tags/{tagId}
  └─ timeBlocks/{blockId}
```

Ver `shared/schema/` para las interfaces TypeScript completas.

## Variables de entorno

Copia `firebase/env.example` y configura tus claves Firebase y Google Calendar API en cada subcarpeta.
