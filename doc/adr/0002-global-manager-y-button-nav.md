# ADR 0002 — Estado global con GlobalManager y navegación con ButtonNav

| Campo | Valor |
| --- | --- |
| **Estado** | Aceptada |
| **Autor** | Jolman Harley Gamboa Salamanca |
| **Contexto del curso** | Producción de Videojuegos 2026-2 — Sprint 1 |

## Contexto

Si cada panel guarda sus propios datos, el pedido se pierde cuando `MainApp`
libera la escena con `queue_free()`. Además, cada botón de navegación repetía el
mismo código de emisión.

## Decisión

1. **GlobalManager** (Autoload): único dueño del estado (`estado: Dictionary`) y
   único que calcula precios. Escucha intenciones del bus (`base_selected`,
   `item_added`, `item_removed`) y responde con notificaciones
   (`total_changed`, `order_updated`).
2. **ButtonNav** (`src/components/navigation/`): botón reutilizable que se
   configura desde el Inspector con `@export_file("*.tscn") var target_scene` y
   `@export var discard_previous`. Configuración y Créditos no necesitan script.

## Consecuencias

- El pedido sobrevive al cambio de pantallas.
- La interfaz no contiene reglas de negocio; solo emite y reacciona.
- No hay código de navegación duplicado.
