# ADR 0001 — Navegación desacoplada mediante un Event Bus global

| Campo | Valor |
| --- | --- |
| **Estado** | Aceptada |
| **Autor** | Jolman Harley Gamboa Salamanca |
| **Contexto del curso** | Producción de Videojuegos 2026-2 — Sprint 1 |

## Contexto

Navegar con `get_tree().change_scene_to_file()` obliga a cada pantalla a
conocer la ruta de las demás. Con cinco pantallas (menú, mostrador, pedido,
configuración y créditos) eso crea dependencias cruzadas y no deja un punto
único donde liberar memoria ni conservar el estado.

## Decisión

Se usa un **Event Bus** como Autoload (`res://src/core/event_bus.gd`,
identificador `EventBus`), que combina los patrones **Singleton** y
**Observer**:

- El bus solo declara señales tipadas y las rutas de escena como constantes.
- Los paneles solo **emiten** intenciones.
- `MainApp` es el **único suscriptor** con autoridad sobre el árbol: instancia el
  panel entrante y libera el anterior con `queue_free()`.
- La suscripción a `navigation_requested` usa `CONNECT_DEFERRED` para que el
  panel emisor termine su evento antes de ser destruido.

## Consecuencias

- Agregar un panel nuevo no obliga a modificar los existentes.
- La liberación de memoria queda en un solo método (`_cargar_escena`).
- Todo cambio de pantalla pasa por el bus, lo que facilita depurar con la
  consola.
