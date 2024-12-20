# Reglas de Desarrollo para Flutter en Cursor

## Arquitectura y Patrones
- Implementar el patrón BLoC o Provider para la gestión del estado
- Mantener una arquitectura limpia con separación clara de responsabilidades
- Seguir el principio de responsabilidad única en todas las clases
- Organizar el código en capas: presentación, dominio y datos

## Estructura de Base de Datos Firebase
### Colecciones Principales:
- users: Perfiles de usuarios (admin, docente, estudiante)
- courses: Cursos y módulos educativos
- projects: Proyectos y tableros Kanban
- social: Posts y sistema de seguimiento
- achievements: Sistema de logros y XP
- statistics: Métricas y análisis de usuario
- notifications: Sistema de notificaciones
- groups: Gestión de grupos y horarios

### Estructura de Documentos:
1. Users:
   ```json
   {
     "profile": {
       "email": "",
       "username": "",
       "fullName": "",
       "role": "",
       "bio": "",
       "avatarUrl": "",
       "xpTotal": 0,
       "level": 1
     },
     "schedule": {
       "days": [],
       "shift": ""
     },
     "stats": {
       "postsCount": 0,
       "completedCourses": 0
     }
   }
   ```

2. Courses:
   ```json
   {
     "name": "",
     "description": "",
     "modules": [],
     "comments": [],
     "mentor": {
       "id": "",
       "name": ""
     }
   }
   ```

3. Projects:
   ```json
   {
     "name": "",
     "description": "",
     "kanban": {
       "columns": [],
       "tasks": []
     },
     "members": {}
   }
   ```

## Convenciones de Código
- Usar nombres descriptivos que reflejen la estructura de Firebase
- Mantener consistencia en los tipos de datos
- Documentar todas las interacciones con Firebase
- Implementar manejo de errores para operaciones de Firebase

## Seguridad y Validación
- Validar roles de usuario antes de operaciones críticas
- Implementar reglas de seguridad en Firebase
- Verificar permisos de grupo antes de acceder a datos
- Mantener consistencia en las actualizaciones de datos

## Optimización
- Usar consultas compuestas para reducir llamadas a Firebase
- Implementar caché local cuando sea apropiado
- Paginar resultados en listas largas
- Optimizar consultas de Firebase usando índices

## Testing
- Probar todas las operaciones CRUD con Firebase
- Simular diferentes roles de usuario en pruebas
- Verificar manejo de errores de red
- Validar integridad de datos en operaciones complejas

## Estructura de Código
- Mantener archivos pequeños y enfocados (<300 líneas)
- Usar nombres descriptivos para clases, métodos y variables
- Seguir las convenciones de nomenclatura de Dart/Flutter
- Agrupar el código relacionado en directorios temáticos

## Componentes y Widgets
- Preferir widgets const cuando sea posible
- Crear widgets reutilizables para patrones comunes de UI
- Implementar widgets stateless siempre que sea posible
- Mantener la lógica de UI separada de la lógica de negocio

## Rendimiento
- Minimizar el uso de setState()
- Implementar lazy loading cuando sea apropiado
- Optimizar el uso de recursos y memoria
- Usar cached_network_image para imágenes de red

## Multiplataforma
- Asegurar compatibilidad con iOS y Android
- Usar configuraciones específicas por plataforma cuando sea necesario
- Probar en ambas plataformas antes de commits importantes
- Mantener consistencia visual entre plataformas

## Accesibilidad
- Implementar etiquetas semantics en todos los widgets interactivos
- Asegurar contraste de color adecuado
- Soportar diferentes tamaños de texto
- Implementar navegación accesible

## Control de Versiones
- Commits atómicos y descriptivos
- Seguir conventional commits (feat:, fix:, docs:, etc.)
- Mantener ramas feature/ para nuevas características
- Realizar code reviews antes de merge a main

## Dependencias
- Mantener las dependencias actualizadas
- Documentar el propósito de cada dependencia
- Preferir paquetes oficiales o bien mantenidos
- Especificar versiones exactas en pubspec.yaml

## Documentación
- Documentar todas las clases y métodos públicos
- Mantener un README actualizado
- Incluir ejemplos de uso en la documentación
- Documentar decisiones de arquitectura importantes 