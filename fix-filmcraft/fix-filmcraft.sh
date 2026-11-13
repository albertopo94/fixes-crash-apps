#!/bin/bash
set -e

echo "=== Fix de compatibilidad ArtCraft Suite (macOS Sequoia + OCLP) ==="
echo ""

patch_app() {
    local APP_PATH="$1"
    local APP_NAME
    APP_NAME=$(basename "$APP_PATH")
    local PLIST_PATH="$APP_PATH/Contents/Info.plist"

    if [ ! -d "$APP_PATH" ]; then
        return 0
    fi

    echo "▶ Procesando: $APP_NAME"

    # 1. Remover cuarentena
    echo "  - Quitando atributos de cuarentena de Gatekeeper..."
    xattr -cr "$APP_PATH" 2>/dev/null || true

    # 2. Inyectar o actualizar SYSTEM_VERSION_COMPAT=1 en Info.plist
    if [ -f "$PLIST_PATH" ]; then
        if /usr/libexec/PlistBuddy -c "Print :LSEnvironment:SYSTEM_VERSION_COMPAT" "$PLIST_PATH" >/dev/null 2>&1; then
            echo "  - LSEnvironment:SYSTEM_VERSION_COMPAT ya estaba configurado."
        else
            echo "  - Inyectando SYSTEM_VERSION_COMPAT=1 en LSEnvironment..."
            cp "$PLIST_PATH" "$PLIST_PATH.bak"
            if /usr/libexec/PlistBuddy -c "Print :LSEnvironment" "$PLIST_PATH" >/dev/null 2>&1; then
                /usr/libexec/PlistBuddy -c "Add :LSEnvironment:SYSTEM_VERSION_COMPAT string 1" "$PLIST_PATH"
            else
                plutil -insert LSEnvironment -xml '<dict><key>SYSTEM_VERSION_COMPAT</key><string>1</string></dict>' "$PLIST_PATH"
            fi
            plutil -lint "$PLIST_PATH" >/dev/null
        fi
    fi

    # 3. Re-firmar ad-hoc (para evitar que AMFI mate el proceso por Info.plist modificado)
    echo "  - Re-firmando ad-hoc el bundle..."
    codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || true

    # 4. Refrescar LaunchServices
    echo "  - Actualizando LaunchServices..."
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_PATH" 2>/dev/null || true

    echo "  ✔ $APP_NAME lista."
    echo ""
}

FOUND=0
for app in /Applications/*.app; do
    id=$(defaults read "$app/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || true)
    if [[ "$id" == ai.storyteller.* || "$app" == *Craft*.app ]]; then
        patch_app "$app"
        FOUND=$((FOUND + 1))
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "No se encontraron aplicaciones de ArtCraft en /Applications."
else
    echo "✅ Todas las aplicaciones de ArtCraft encontradas ($FOUND) fueron configuradas con éxito."
    echo "Ya podés abrirlas normalmente con doble clic desde Finder, Launchpad o Spotlight."
fi
