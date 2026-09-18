# Cafetería Interactiva 2D

**Producción de Videojuegos (Sistemas Interactivos) 2026-2** · Universidad Antonio Nariño

Proyecto integrador desarrollado en Godot 4. El usuario atiende el mostrador de
una cafetería: cada cliente pide productos con un tamaño exacto, el usuario
arma el pedido y lo entrega. El sistema valida la entrega, cobra y pasa al
siguiente cliente.

Esta versión corresponde a la **Actividad 5 – Interacción y Mecánicas
Básicas**, construida sobre la arquitectura del Sprint 1 sin eliminar ninguna
funcionalidad.

## Requisitos

| Componente | Versión / configuración |
| --- | --- |
| Godot Engine | 4.x Standard (sin .NET) |
| Renderizador | `Compatibility` |
| Lenguaje | GDScript 2.0 con tipado estático |

## Ejecución

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/JolmanGamboa/Lab5-Videojuegos-2026.git
   ```
2. Abrir Godot, pulsar **Import** y seleccionar `project.godot`.
3. Ejecutar con `F5`. La escena principal es `res://src/core/main_app.tscn`.

## Cómo se juega

1. En el menú, pulsa **Atender el mostrador**. Arriba verás qué pide el
   cliente en turno.
2. Selecciona un producto y luego su tamaño para agregarlo al pedido.
3. Ve a **Pedido actual**, revisa la lista (puedes quitar productos) y pulsa
   **Entregar pedido al cliente**.
4. Si el pedido coincide, el cliente paga y llega el siguiente; si no, se
   explica el motivo.

## Mecánica principal (Actividad 5)

| Requisito | Implementación |
| --- | --- |
| Entrada del usuario | Botones de producto, tamaño, quitar y entregar |
| Mecánica principal | Atender clientes: armar y entregar el pedido correcto |
| Interacción con el entorno | La entrega se valida contra el cliente en turno; el resultado llega por eventos (`delivery_result`, `customer_changed`) |
| Organización del código | La regla vive solo en `GlobalManager`; los paneles emiten intenciones y reaccionan |

```gdscript
# GlobalManager: regla central de la mecánica
if pedido != cliente["pide"]:
    EventBus.delivery_result.emit(false, "Eso no es lo que pidió ...")
    return
```

## Arquitectura

```
GUI ──intención──▶ EventBus ──▶ GlobalManager (único dueño del pedido)
                      │                 │
                      │                 └──▶ total_changed / order_updated
                      │                      customer_changed / delivery_result ──▶ GUI
                      └──▶ MainApp (única autoridad sobre el árbol)
```

| Pantalla | Escena | Función |
| --- | --- | --- |
| Menú | `main/menu_panel.tscn` | Navega con `ButtonNav`; sale con `get_tree().quit()` |
| Mostrador | `simulation/step_1_base.tscn` | Cliente en turno; selección de producto y tamaño |
| Pedido actual | `order/order_panel.tscn` | Lista dinámica del pedido; quitar productos y entregar al cliente |
| Configuración | `config/config_panel.tscn` | Parámetros del local; sin script |
| Créditos | `credits/credits_panel.tscn` | Datos del autor; sin script |

## Estructura

```
res://
├── doc/adr/                       # Decisiones de arquitectura
├── src/
│   ├── assets/ui/
│   ├── components/navigation/     # button_nav.tscn / .gd
│   ├── core/                      # event_bus, global_manager, main_app
│   └── scenes/
│       ├── main/                  # menu_panel
│       ├── simulation/            # step_1_base (mostrador)
│       ├── order/                 # order_panel
│       ├── config/
│       └── credits/
├── BACKLOG.md
├── CHANGELOG.md
├── DEVLOG.md
├── README.md
└── project.godot
```

## Señales del bus

```gdscript
signal navigation_requested(target_scene: String, discard_previous: bool)
signal base_selected(base_name: String)
signal item_added(item_id: String)
signal item_removed(item_id: String)
signal total_changed(new_total: int)
signal order_updated(order: Dictionary)
# Actividad 5
signal order_delivered()
signal customer_changed(customer: Dictionary)
signal delivery_result(success: bool, message: String)
```

## Convenciones

Commits en *Conventional Commits* (`init`, `config`, `feat`, `refactor`,
`doc`, `chore`). Archivos y carpetas en `snake_case`.

## Autor

- **Nombre:** Jolman Harley Gamboa Salamanca
- **Código estudiantil:** 12242525509
- **Programa:** Ingeniería de Software
