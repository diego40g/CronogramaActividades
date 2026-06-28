# Shared Firestore Schema

This folder documents the Firestore data model shared by the Flutter app and Angular dashboard.

## Collection tree

```
users/{uid}
├── displayName: string
├── email: string
├── photoURL: string | null
├── googleCalendarId: string | null
├── fcmToken: string | null
├── settings:
│   ├── defaultView: "timeline" | "calendar"
│   ├── theme: "light" | "dark" | "system"
│   ├── timezone: string (IANA, e.g. "America/Bogota")
│   ├── syncWithGoogleCalendar: boolean
│   ├── enableNotifications: boolean
│   └── reminderMinutesBefore: number
└── createdAt: Timestamp

users/{uid}/tasks/{taskId}
├── title: string (max 200)
├── description: string
├── status: "todo" | "inProgress" | "done"
├── priority: 0 | 1 | 2 | 3   (0=none, 1=low, 2=medium, 3=high)
├── tags: string[]
├── startTime: Timestamp
├── endTime: Timestamp
├── isAllDay: boolean
├── googleEventId: string | null
├── googleCalendarId: string | null
├── recurrence:
│   ├── rule: "none" | "daily" | "weekly" | "monthly"
│   └── until: Timestamp | null
├── createdAt: Timestamp
└── updatedAt: Timestamp

users/{uid}/tasks/{taskId}/subtasks/{subtaskId}
├── taskId: string
├── title: string
├── isCompleted: boolean
├── order: number
└── createdAt: Timestamp

users/{uid}/tags/{tagId}
├── name: string
├── color: string (hex)
└── createdAt: Timestamp

users/{uid}/timeBlocks/{blockId}
├── date: string (YYYY-MM-DD)
├── taskId: string
├── startMinute: number (0–1439)
└── durationMinutes: number
```

## Firestore indexes (see ../firestore.indexes.json)

- `tasks` by `(startTime ASC, status ASC)`
- `tasks` by `(tags ARRAY_CONTAINS, startTime ASC)`
- `tasks` by `(priority DESC, startTime ASC)`
- `tasks` by `(status ASC, startTime ASC)`

## Security rules (see ../firestore.rules)

All collections are scoped to `request.auth.uid == userId`.
