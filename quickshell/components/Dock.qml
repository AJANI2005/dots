import Quickshell
import Quickshell.Io
import QtQuick
import "./Theme"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: dockWindow
            required property var modelData
            screen: modelData

            anchors {
                bottom: true
                left: true
                right: true
            }

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            implicitHeight: (dockWindow.clientList.length > 0 && (dockWindow.isHovered || animState.active)) ? 80 : 0
            height: implicitHeight
            visible: dockWindow.clientList.length > 0

            property bool isHovered: false
            property var clientList: []

            Timer {
                id: inactivityTimer
                interval: 1000
                running: dockWindow.isHovered
                repeat: false
                onTriggered: {
                    if (!bottomTrigger.containsMouse && !dockArea.containsMouse) {
                        dockWindow.isHovered = false
                    }
                }
            }

            Timer {
                interval: 250
                running: true
                repeat: true
                onTriggered: getClients.running = true
            }

            Process {
                id: getClients
                command: ["sh", "-c", "mmsg get all-clients 2>/dev/null || echo '{\"clients\":[]}'"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            let json = JSON.parse(text)
                            if (json && json.clients) {
                                dockWindow.clientList = json.clients
                            }
                        } catch(e) {}
                    }
                }
            }

            Process {
                id: focusClientProc
                command: ["sh", "-c", "mmsg dispatch focusid client," + focusId]
                property string focusId: ""
            }

            MouseArea {
                id: bottomTrigger
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: dockWindow.isHovered ? parent.height : 5
                hoverEnabled: true
                onEntered: dockWindow.isHovered = true
                onPositionChanged: {
                    if (dockWindow.isHovered) {
                        inactivityTimer.restart()
                    }
                }
            }

            Item {
                id: dockContainer
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40
                width: Math.max(row.width + 24, 60)
                y: dockWindow.isHovered ? 40 : 80

                Behavior on y {
                    NumberAnimation {
                        id: yAnim
                        duration: 250
                        easing.type: Easing.OutCubic
                        onRunningChanged: {
                            if (!running && !dockWindow.isHovered) {
                                animState.active = false
                            }
                        }
                    }
                }

                QtObject {
                    id: animState
                    property bool active: false
                }

                Connections {
                    target: dockWindow
                    function onIsHoveredChanged() {
                        if (dockWindow.isHovered) {
                            animState.active = true
                            inactivityTimer.restart()
                        } else {
                            inactivityTimer.stop()
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Theme.panelBg
                    radius: 8
                    border.color: Theme.inactive
                    border.width: 1
                }

                MouseArea {
                    id: dockArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    onPositionChanged: {
                        inactivityTimer.restart()
                    }
                    onExited: {
                        if (!bottomTrigger.containsMouse) {
                            dockWindow.isHovered = false
                        }
                    }

                    Row {
                        id: row
                        anchors.centerIn: parent
                        spacing: 8

                        Repeater {
                            model: dockWindow.clientList
                            delegate: Rectangle {
                                id: clientItem
                                implicitWidth: 32
                                height: 32
                                radius: 6
                                color: clientMouseArea.containsMouse ? Theme.inactive : "transparent"

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }

                                property string appId: {
                                    if (modelData.appid) return modelData.appid.toString()
                                    if (modelData.app_id) return modelData.app_id.toString()
                                    if (modelData.class) return modelData.class.toString()
                                    if (modelData.title) return modelData.title.toString()
                                    if (modelData.name) return modelData.name.toString()
                                    return modelData.id !== undefined ? String(modelData.id) : "?"
                                }

                                property string appIcon: ""

                                Component.onCompleted: {
                                    getIconProc.running = true
                                }

                                Process {
                                    id: getIconProc
                                    command: ["sh", Qt.resolvedUrl("../scripts/dock-icons.sh").toString().replace("file://", ""), clientItem.appId]
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            clientItem.appIcon = text.trim()
                                        }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: clientItem.appIcon
                                    color: clientMouseArea.containsMouse ? Theme.active : Theme.fg
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 15

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }

                                Item {
                                    z: 100
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    y: -36
                                    width: tooltipRect.width
                                    height: tooltipRect.height
                                    visible: clientMouseArea.containsMouse
                                    opacity: visible ? 1 : 0

                                    Behavior on opacity {
                                        NumberAnimation { duration: 150 }
                                    }

                                    Rectangle {
                                        id: tooltipRect
                                        implicitWidth: tooltipText.width + 12
                                        height: 24
                                        color: Theme.panelBg
                                        radius: 4
                                        border.color: Theme.inactive
                                        border.width: 1

                                        Text {
                                            id: tooltipText
                                            anchors.centerIn: parent
                                            text: appId
                                            color: Theme.fg
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 11
                                        }
                                    }
                                }

                                MouseArea {
                                    id: clientMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        focusClientProc.focusId = modelData.id
                                        focusClientProc.running = false
                                        focusClientProc.running = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}