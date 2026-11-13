# Fix para Godot en macOS Sequoia (OCLP / GPUs Legacy)

Este fix resuelve el problema de las **subventanas, popups y diálogos que se muestran completamente en negro** al abrir o utilizar **Godot 4** en Macs con gráficos legacy (Intel Iris Pro / NVIDIA Kepler) corriendo **macOS Sequoia** mediante **OpenCore Legacy Patcher (OCLP)**.

---

## Causa del error

1. **Bug de composición multi-ventana en macOS Sequoia + OCLP:**  
   Por defecto, Godot 4 intenta abrir cada diálogo (como "Importar", "Escanear", "Nuevo Proyecto", configuración o menús flotantes) como una **ventana nativa separada (`NSWindow`)**. El compositor de ventanas de macOS falla al sincronizar los contextos OpenGL secundarios de las GPUs legacy, provocando que la ventana secundaria se dibuje como un rectángulo negro sólido.
2. **Incompatibilidad de MoltenVK (Metal 3.2):**  
   Al intentar inicializar Vulkan/MoltenVK, el motor solicita estándares de Metal que las GPUs anteriores a 2016 no soportan.

---

## ¿Qué hace este script?

1. **Inyecta `--single-window`:** Configura un wrapper dentro de `Godot.app/Contents/MacOS/Godot` para que el Administrador de Proyectos y el Editor siempre arranquen con `--single-window`, forzando a que todos los diálogos se dibujen incrustados en el lienzo de la ventana principal y nunca creen ventanas secundarias negras.
2. **Habilita `single_window_mode` en la configuración de usuario:** Actualiza los archivos `editor_settings-*.tres` en `~/Library/Application Support/Godot/`.
3. **Inyecta `SYSTEM_VERSION_COMPAT=1`:** Evita los errores de validación de shaders de Metal 3.2 en MoltenVK.
4. **Remueve cuarentena de Gatekeeper y re-firma ad-hoc:** Garantiza que macOS abra la aplicación sin advertencias ni bloqueos de AMFI.

---

## Cómo usarlo tras actualizar Godot

Cada vez que descargues una nueva versión de Godot (por ejemplo Godot 4.8 o una actualización de mantenimiento) y la reemplaces en `/Applications/Godot.app`:

### Opción A (desde la terminal en cualquier lugar):
```bash
fix-godot
```

### Opción B (desde esta carpeta):
```bash
cd "/Users/albertmac11/Downloads/filmcraft-cli-0.6.0-macos-universal/fix-godot"
./fix-godot.sh
```
