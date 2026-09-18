# DEVLOG — Diario de desarrollo

Registro de decisiones técnicas, dificultades y aprendizajes del proyecto
integrador **Cafetería Interactiva 2D**.

---

## Entrada 001 — Base del Sprint 1

| Categoría | Detalles |
| --- | --- |
| **Actividad** | Sprint 1 – Arquitectura base |
| **Funcionalidades implementadas** | Event Bus (Autoload), `MainApp` con pila de historial y liberación con `queue_free()`, `GlobalManager` con el estado del pedido, componente `ButtonNav`, paneles de menú, mostrador, pedido, configuración y créditos. |
| **Dificultades encontradas** | Evitar que la interfaz calculara precios; se resolvió moviendo el catálogo y los recargos a `GlobalManager`. |
| **Decisiones de diseño** | Paneles co-localizados (`.tscn` junto a su `.gd`), señales tipadas, `bind()` para un único callback por tipo de acción. Ver ADR 0001 y 0002. |
| **Próximos pasos** | Incorporar la mecánica principal de atención de clientes (Actividad 5). |

---

## Entrada 002 — Actividad 5: Interacción y mecánicas básicas

| Categoría | Detalles |
| --- | --- |
| **Actividad** | Actividad 5 – Interacción y Mecánicas Básicas |
| **Fecha** | 18/09/2026 |
| **Funcionalidades implementadas** | Mecánica principal de **atención de clientes**: cada cliente pide productos con un tamaño exacto; el usuario arma el pedido en el mostrador y lo entrega desde el panel de pedido. `GlobalManager` valida la entrega, suma ganancias, cuenta clientes atendidos y avanza al siguiente cliente. Retroalimentación en pantalla (mensaje verde o rojo) y botón de entrega desactivado cuando el pedido está vacío. |
| **Dificultades encontradas** | Decidir dónde validar la entrega. Validar en el panel habría duplicado reglas del negocio en la interfaz; se dejó en `GlobalManager`, que ya era el dueño del pedido. También se verificó que la comparación de diccionarios no depende del orden en que se agregan los productos. |
| **Decisiones de diseño** | Tres señales nuevas en el bus: `order_delivered` (intención), `customer_changed` y `delivery_result` (notificaciones). La fila de clientes es una constante `CLIENTES` y el turno se guarda en `estado`, así sobrevive al `queue_free()` de los paneles. No se eliminó ninguna funcionalidad del Sprint 1. |
| **Retroalimentación aplicada del Sprint anterior** | Se mantuvo la regla de que la interfaz solo emite y reacciona: ningún panel calcula ni compara pedidos. Se reutilizaron `ButtonNav`, `bind()` y la construcción dinámica de filas. |
| **Próximos pasos** | Modelar el ciclo del cliente (esperando → atendido → siguiente) con una Máquina de Estados; agregar retroalimentación sonora. |

### Retrospectiva

- **¿La interacción resulta intuitiva para un usuario nuevo?** Sí: el cliente y
  lo que pide se ven en el mostrador y en el pedido, y el resultado de la
  entrega se explica con un mensaje.
- **¿Qué código podría reutilizar?** `ButtonNav`, el patrón intención →
  `GlobalManager` → notificación, y la construcción dinámica de filas del
  panel de pedido.
- **¿Qué debería automatizar con una Máquina de Estados?** El turno del
  cliente: esperando pedido, pedido rechazado, pedido entregado y cambio de
  cliente.
- **¿Qué aprendí sobre el diseño de interacciones?** Que toda acción debe
  tener una respuesta visible (mensaje, color, botón desactivado) para que el
  usuario entienda qué pasó.
