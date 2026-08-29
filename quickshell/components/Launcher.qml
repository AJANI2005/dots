import Quickshell
import Quickshell.Io
import QtQuick
import "./Theme"

Item {
    id: launcher
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: launcherContainer.width
    implicitHeight: launcherContainer.height
    width: implicitWidth
    height: implicitHeight

    Process {
        id: fuzzelProc
        command: ["fuzzel"]
    }

    Rectangle {
        id: launcherContainer
        anchors.centerIn: parent
        width: 22
        height: 22
        radius: 4
        color: mouseArea.containsMouse ? Theme.inactive : "transparent"

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        Text {
            anchors.centerIn: parent
            text: "󰣛" // Fedora Nerd Font icon
            color: mouseArea.containsMouse ? Theme.active : Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 14

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                fuzzelProc.running = false
                fuzzelProc.running = true
            }
        }
    }
}
