import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./Theme"

Item {
    id: battery
    property string batteryLevel: "100%"
    property string batteryStatus: "Unknown"
    property bool hasBattery: false
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: batRow.implicitWidth
    implicitHeight: batRow.implicitHeight

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batProc.running = true
        }
    }

    Process {
        id: batProc
        command: ["sh", Qt.resolvedUrl("battery.sh").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split('\n')
                if (lines.length >= 2 && lines[0] !== "No battery") {
                    battery.hasBattery = true
                    battery.batteryLevel = lines[0].endsWith('%') ? lines[0] : (lines[0] + "%")
                    battery.batteryStatus = lines[1]
                } else if (lines.length === 1 && lines[0] !== "No battery" && lines[0] !== "") {
                    battery.hasBattery = true
                    battery.batteryLevel = lines[0].endsWith('%') ? lines[0] : (lines[0] + "%")
                } else {
                    battery.hasBattery = false
                }
            }
        }
    }

    // Only visible if battery exists
    visible: battery.hasBattery

    Row {
        id: batRow
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: {
                let lvl = parseInt(battery.batteryLevel)
                if (battery.batteryStatus === "Charging") return "󰂄"
                if (isNaN(lvl)) return "󰁹"
                if (lvl >= 90) return "󰁹"
                if (lvl >= 80) return "󰂂"
                if (lvl >= 70) return "󰂁"
                if (lvl >= 60) return "󰂀"
                if (lvl >= 50) return "󰁿"
                if (lvl >= 40) return "󰁾"
                if (lvl >= 30) return "󰁽"
                if (lvl >= 20) return "󰁼"
                if (lvl >= 10) return "󰁻"
                return "󰁺"
            }
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: battery.batteryStatus === "Charging" ? Theme.active : (parseInt(battery.batteryLevel) <= 20 ? "#ef4444" : Theme.fg)
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: battery.batteryLevel
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            color: Theme.fg
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
