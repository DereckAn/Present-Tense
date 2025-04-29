# Present-Tense

## Descripción

Present-Tense es una aplicación iOS desarrollada con SwiftUI que te ayuda a registrar y visualizar tus actividades diarias en tiempo real. Diseñada con un enfoque en la simplicidad y la experiencia de usuario, esta aplicación te permite mantener un registro detallado de tus actividades cotidianas, visualizarlas en una línea de tiempo y reflexionar sobre cómo inviertes tu tiempo.

## Características

- **Registro de Actividades**: Añade fácilmente nuevas actividades con descripción y hora.
- **Línea de Tiempo**: Visualiza tus actividades organizadas cronológicamente.
- **Navegación Semanal**: Navega entre días de la semana con un selector intuitivo.
- **Edición y Eliminación**: Modifica o elimina actividades existentes.
- **Personalización Visual**: Cambia entre modo claro, oscuro o automático según tus preferencias.
- **Interfaz Intuitiva**: Diseño centrado en el usuario con navegación por pestañas.

## Tecnologías Utilizadas

- **SwiftUI**: Framework declarativo para construir interfaces de usuario.
- **Combine**: Para manejo reactivo de datos (en el ViewModel).
- **Swift 5**: Lenguaje de programación principal.
- **Arquitectura MVVM**: Separación clara de responsabilidades.
- **UserDefaults**: Para almacenar preferencias del usuario.
- **SF Symbols**: Iconografía consistente con el diseño de iOS.

## Arquitectura del Proyecto (MVVM)

El proyecto sigue la arquitectura Modelo-Vista-ViewModel (MVVM), que proporciona una separación clara de responsabilidades:

### Modelos

- `ActivityLog`: Representa una actividad con propiedades como id, timestamp, descripción, icono y color.

### Vistas

- `ContentView`: Vista principal que gestiona la navegación por pestañas.
- `TimelineView`: Muestra las actividades en formato cronológico.
- `AddEditActivityView`: Formulario para añadir o editar actividades.
- `SettingsView`: Configuración de preferencias de la aplicación.
- `CustomTabView`: Barra de navegación personalizada.
- `ActivityRowView`: Representación visual de una actividad individual.
- `WeekDayView`: Componente para la selección de días de la semana.

### ViewModels

- `DayLogViewModel`: Gestiona la lógica de negocio relacionada con las actividades, incluyendo:
  - Filtrado de actividades por fecha
  - Operaciones CRUD (Crear, Leer, Actualizar, Eliminar)
  - Formateo de fechas
  - Generación de datos para la vista semanal

### Schemas

- `ColorSchemeOption`: Enum para gestionar las preferencias de tema visual (claro/oscuro/sistema).

## Estructura de Directorios

```
present-tense/
├── Assets.xcassets/       # Recursos gráficos
├── Controllers/           # Controladores (si se necesitan)
├── Models/                # Modelos de datos
│   └── ActivityLog.swift  # Modelo de actividad
├── Schemas/               # Esquemas y enumeraciones
│   └── ColorSchemeOption.swift
├── Services/              # Servicios (para futuras implementaciones)
├── Utilities/             # Utilidades y helpers
├── ViewModels/           # ViewModels
│   └── DayLogViewModel.swift
├── Views/                 # Componentes de UI
│   ├── ActivityRowView.swift
│   ├── AddEditActivityView.swift
│   ├── ContentView.swift
│   ├── CustomTabView.swift
│   ├── SettingsView.swift
│   ├── TimelineView.swift
│   └── WeekDayView.swift
└── present_tenseApp.swift # Punto de entrada de la aplicación
```

## Flujo de Datos

1. El usuario interactúa con las vistas (Views)
2. Las vistas notifican al ViewModel sobre las acciones del usuario
3. El ViewModel actualiza los modelos según sea necesario
4. El ViewModel notifica a las vistas sobre los cambios en los datos
5. Las vistas se actualizan automáticamente gracias a los bindings de SwiftUI

## Cómo Contribuir

1. **Clona el repositorio**:

   ```bash
   git clone https://github.com/tuusuario/present-tense.git
   cd present-tense
   ```

2. **Abre el proyecto en Xcode**:

   ```bash
   open present-tense.xcodeproj
   ```

3. **Crea una nueva rama para tu contribución**:

   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```

4. **Realiza tus cambios siguiendo estas pautas**:

   - Mantén la arquitectura MVVM
   - Sigue las convenciones de nomenclatura existentes
   - Añade comentarios cuando sea necesario
   - Asegúrate de que la UI sea consistente con el diseño actual

5. **Prueba tus cambios**:

   - Ejecuta la aplicación en el simulador
   - Verifica que no hay errores ni warnings

6. **Envía un Pull Request**:
   - Describe claramente los cambios realizados
   - Menciona cualquier dependencia nueva

## Próximas Funcionalidades

- Vista de Calendario completa
- Vista de Diario para reflexiones diarias
- Planificador de actividades
- Estadísticas y análisis de tiempo
- Sincronización con iCloud
- Notificaciones y recordatorios

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.

---

Desarrollado con ❤️ por Dereck Ángeles
