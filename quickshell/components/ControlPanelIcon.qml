import Quickshell
import QtQuick
import "./Theme"

Item {
    id: controlPanelIcon
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: container.width
    implicitHeight: container.height
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: container
        anchors.centerIn: parent
        width: 22
        height: 22
        radius: 4
        color: (mouseArea.containsMouse || rootScope.controlPanelOpen) ? Theme.inactive : "transparent"

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        Text {
            anchors.centerIn: parent
            text: "󱃖"
            color: (mouseArea.containsMouse || rootScope.controlPanelOpen) ? Theme.active : Theme.fg
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
                rootScope.controlPanelOpen = !rootScope.controlPanelOpen
            }
        }
    }
}
