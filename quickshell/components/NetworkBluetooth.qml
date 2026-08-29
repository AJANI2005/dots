import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./Theme"

Item {
    id: networkBluetooth
    property string wifiStatus: "Disconnected"
    property string bluetoothStatus: "Off"
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: nbRow.implicitWidth
    implicitHeight: nbRow.implicitHeight

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            wifiProc.running = true
            btProc.running = true
        }
    }

    Process {
        id: wifiProc
        command: ["sh", "-c", "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2 || echo 'Disconnected'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let res = text.trim()
                networkBluetooth.wifiStatus = res !== "" ? res : "Disconnected"
            }
        }
    }

    Process {
        id: btProc
        command: ["sh", "-c", "bluetoothctl show | grep 'Powered: yes' >/dev/null && echo 'On' || echo 'Off'"]
        stdout: StdioCollector {
            onStreamFinished: {
                networkBluetooth.bluetoothStatus = text.trim()
            }
        }
    }

    Row {
        id: nbRow
        spacing: 12
        anchors.verticalCenter: parent.verticalCenter

        // WiFi
        Item {
            width: wifiRow.implicitWidth + 8
            height: 18
            anchors.verticalCenter: parent.verticalCenter

            Row {
                id: wifiRow
                spacing: 6
                anchors.centerIn: parent
                Text {
                    text: "󰤨" // Nerd font wifi icon
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: networkBluetooth.wifiStatus !== "Disconnected" ? Theme.active : Theme.inactiveFg
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: networkBluetooth.wifiStatus
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    color: Theme.fg
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Bluetooth
        Item {
            width: btRow.implicitWidth + 8
            height: 18
            anchors.verticalCenter: parent.verticalCenter

            Row {
                id: btRow
                spacing: 6
                anchors.centerIn: parent
                Text {
                    text: "󰂯" // Nerd font bluetooth icon
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: networkBluetooth.bluetoothStatus === "On" ? Theme.active : Theme.inactiveFg
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: networkBluetooth.bluetoothStatus === "On" ? "BT" : "Off"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    color: Theme.fg
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
