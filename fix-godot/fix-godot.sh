#!/bin/bash
set -e

APP_PATH="/Applications/Godot.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: No se encontró Godot en $APP_PATH"
    echo "Asegurate de que Godot.app esté copiado en /Applications."
    exit 1
fi

echo "=== Aplicando fix a Godot para macOS Sequoia (OCLP) ==="

# 1. Quitar cuarentena
echo "1. Quitando cuarentena de Gatekeeper..."
xattr -cr "$APP_PATH" 2>/dev/null || true

# 2. Configurar LSEnvironment
PLIST="$APP_PATH/Contents/Info.plist"
if ! /usr/libexec/PlistBuddy -c "Print :LSEnvironment:SYSTEM_VERSION_COMPAT" "$PLIST" >/dev/null 2>&1; then
    echo "2. Configurando SYSTEM_VERSION_COMPAT=1 en Info.plist..."
    if /usr/libexec/PlistBuddy -c "Print :LSEnvironment" "$PLIST" >/dev/null 2>&1; then
        /usr/libexec/PlistBuddy -c "Add :LSEnvironment:SYSTEM_VERSION_COMPAT string 1" "$PLIST"
    else
        plutil -insert LSEnvironment -xml '<dict><key>SYSTEM_VERSION_COMPAT</key><string>1</string></dict>' "$PLIST"
    fi
    plutil -lint "$PLIST" >/dev/null
fi

# 3. Configurar wrapper --single-window
MACOS_DIR="$APP_PATH/Contents/MacOS"
cd "$MACOS_DIR"
if [ ! -f "Godot.bin" ]; then
    echo "3. Configurando wrapper con --single-window..."
    mv Godot Godot.bin
    cat << 'WRAPPER' > Godot
#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
export SYSTEM_VERSION_COMPAT=1
exec "$DIR/Godot.bin" --single-window "$@"
WRAPPER
    chmod +x Godot
fi

# 4. Asegurar que las preferencias de usuario tengan single_window_mode = true
echo "4. Asegurando single_window_mode en configuraciones de usuario..."
for f in "$HOME/Library/Application Support/Godot/"*.tres; do
    if [ -f "$f" ]; then
        sed -i '' 's/single_window_mode = false/single_window_mode = true/g' "$f"
    fi
done

# 5. Re-firmar ad-hoc
echo "5. Re-firmando ad-hoc..."
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || true

# 6. Refrescar LaunchServices
echo "6. Actualizando LaunchServices..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_PATH" 2>/dev/null || true

echo ""
echo "✅ ¡Listo! Godot quedó reparado y configurado en modo de ventana única."
echo "Ya podés abrir Godot normalmente desde el Finder, Dock o Spotlight."
