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
