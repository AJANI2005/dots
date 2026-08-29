pragma Singleton
import QtQuick

QtObject {
    readonly property string fontFamily: "0xProto Nerd Font"
    readonly property int fontSize: 13

    readonly property color fg: "#ffffff"          // Crisp pure white text
    readonly property color bg: "#09090b"          // Deep zinc-950 background
    readonly property color panelBg: "#cc09090b"     // Sleek semi-transparent dark zinc panel / surface
    readonly property color active: "#3b82f6"        // Vibrant modern blue-500 accent
    readonly property color inactive: "#27272a"      // Dark zinc pill background
    readonly property color inactiveFg: "#a1a1aa"    // Zinc-400 text for inactive
    readonly property color accentGlow: "#2563eb"    // Accent border/glow
}
