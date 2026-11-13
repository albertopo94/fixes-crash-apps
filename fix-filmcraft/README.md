# Fix para FilmCraft y ArtCraft Apps en macOS Sequoia (OCLP / GPUs Legacy)

Este fix resuelve el problema de choque (`SIGABRT` / `abort trap: 6` / `Parent device is lost`) al abrir **FilmCraft.app**, **ArtCraft Launcher.app** y demás aplicaciones de la suite de ArtCraft en Macs no soportados oficialmente que corren **macOS Sequoia** mediante **OpenCore Legacy Patcher (OCLP)** (como MacBooks con gráficos Intel Iris Pro o NVIDIA GeForce GT 750M / Kepler).

---

## Causa del error

Las aplicaciones de ArtCraft están escritas en Rust y utilizan el motor gráfico `wgpu` para sus interfaces (`egui`). En macOS 15 (Sequoia), `wgpu` asume por defecto soporte para el estándar **Metal 3.2** (`-std=metal3.2`). En GPUs con drivers legacy parcheados por OCLP, el compilador de Metal rechaza ese estándar, provocando que la aplicación aborte de inmediato al inicializar la ventana gráfica (`egui_pipeline` o `ComputePipeline`).

---

## ¿Qué hace este script?

Para cada aplicación instalada (**FilmCraft**, **ArtCraft Launcher**, **PhotoCraft**, etc.):
1. **Limpia la cuarentena:** Quita los atributos `com.apple.quarantine` de Gatekeeper que macOS le asigna a las descargas web.
2. **Inyecta `SYSTEM_VERSION_COMPAT=1`:** Agrega la clave `LSEnvironment` en `Contents/Info.plist`, lo que indica a macOS que informe una versión de API compatible sin solicitar Metal 3.2.
3. **Refresca LaunchServices:** Notifica al sistema para que registre inmediatamente los cambios.

---

## Cómo usarlo tras una actualización o nueva instalación

Cada vez que descargues una nueva versión o una nueva app de ArtCraft y la copies en `/Applications`, simplemente ejecutás en tu terminal:

```bash
cd "/Users/albertmac11/Downloads/fixes-crash-apps/fix-filmcraft"
./fix-filmcraft.sh
```

O directamente ejecutando la ruta completa:

```bash
/Users/albertmac11/Downloads/fixes-crash-apps/fix-filmcraft/fix-filmcraft.sh
```

---

## Opcional: Tener el comando siempre a mano en tu terminal

Si querés poder ejecutar `fix-filmcraft` desde cualquier lugar:

```bash
cp fix-filmcraft.sh ~/.local/bin/fix-filmcraft
```
