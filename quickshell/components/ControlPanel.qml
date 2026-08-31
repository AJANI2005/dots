import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "./Theme"

PanelWindow {
    id: controlPanel
    property bool isOpen: false
    signal closeRequested()
    visible: isOpen || container.opacity > 0.01
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    property string cpuUsage: "0%"
    property string memUsage: "0%"
    property string diskUsage: "0%"
    property string uptimeStr: ""
    property int selectedIndex: 0
    property real wheelPosition: 0.0

    Behavior on wheelPosition {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    function selectIndex(targetIndex) {
        var count = wheelModel.count
        if (count <= 0) return

        var currentMod = wheelPosition % count
        if (currentMod < 0) currentMod += count

        var diff = targetIndex - currentMod
        if (diff > count / 2) diff -= count
        if (diff < -count / 2) diff += count

        wheelPosition += diff
        selectedIndex = targetIndex
    }

    Timer {
        id: focusTimer
        interval: 60
        onTriggered: {
            if (controlPanel.isOpen) {
                focusItem.forceActiveFocus()
            }
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            statsProc.running = true
            focusTimer.restart()
        }
    }

    Timer {
        interval: 2000
        running: controlPanel.isOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statsProc.running = true
        }
    }

    Process {
        id: statsProc
        command: ["sh", "-c", "
            cpu=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else cpu=int(100*(u-u1)/(t-t1)); } END {print cpu}' <(grep 'cpu ' /proc/stat) <(sleep 0.2; grep 'cpu ' /proc/stat) 2>/dev/null || echo '0')
            mem=$(free | grep Mem | awk '{printf \"%.0f%%\", $3/$2 * 100}')
            disk=$(df / | tail -1 | awk '{print $5}')
            uptime=$(uptime -p | sed 's/up //')
            echo \"$cpu|$mem|$disk|$uptime\"
        "]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split('|')
                if (parts.length >= 4) {
                    controlPanel.cpuUsage = (parts[0].endsWith('%') ? parts[0] : (parts[0] + "%"))
                    controlPanel.memUsage = parts[1]
                    controlPanel.diskUsage = parts[2]
                    controlPanel.uptimeStr = parts[3]
                }
            }
        }
    }

    Process {
        id: actionProc
        command: ["sh", "-c", "echo 'action'"]
    }

    function runAction(cmd) {
        actionProc.command = ["sh", "-c", cmd]
        actionProc.running = true
    }

    ListModel {
        id: wheelModel
        ListElement {
            title: "CPU PROCESSOR"
            category: "TELEMETRY"
            icon: "󰻠"
            detailValue: ""
            detailSub: "SYNAPSE DENSITY: OPTIMAL"
            actionCmd: ""
        }
        ListElement {
            title: "MEMORY STREAM"
            category: "TELEMETRY"
            icon: "󰍛"
            detailValue: ""
            detailSub: "BUFFER STABILITY: 99.8%"
            actionCmd: ""
        }
        ListElement {
            title: "STORAGE GRID"
            category: "TELEMETRY"
            icon: "󰋊"
            detailValue: ""
            detailSub: ""
            actionCmd: ""
        }
        ListElement {
            title: "NETWORK LINK"
            category: "COMMS"
            icon: "󰤨 "
            detailValue: "ACTIVE"
            detailSub: "LAUNCH NMTUI CONFIG"
            actionCmd: "foot --app-id=nmtui nmtui"
        }
        ListElement {
            title: "BLUETOOTH FREQ"
            category: "COMMS"
            icon: "󰂯"
            detailValue: "LINKED"
            detailSub: "LAUNCH BLUEMAN"
            actionCmd: "setsid gtk-launch blueman-manager.desktop || setsid blueman-manager || blueman-manager"
        }
        ListElement {
            title: "LOCK SESSION"
            category: "OVERRIDE"
            icon: "󰌾"
            detailValue: "SECURE"
            detailSub: "LOCK WORKSTATION"
            actionCmd: "pgrep -x swaylock >/dev/null || swaylock"
        }
        ListElement {
            title: "STANDBY MODE"
            category: "OVERRIDE"
            icon: "󰤄"
            detailValue: "SLEEP"
            detailSub: "SUSPEND SYSTEM"
            actionCmd: "systemctl suspend"
        }
        ListElement {
            title: "SYSTEM REBOOT"
            category: "OVERRIDE"
            icon: "󰜉"
            detailValue: "RESTART"
            detailSub: "REBOOT KERNEL"
            actionCmd: "systemctl reboot"
        }
        ListElement {
            title: "POWER OFF"
            category: "OVERRIDE"
            icon: "󰐥"
            detailValue: "HALT"
            detailSub: "SHUTDOWN SYSTEM"
            actionCmd: "systemctl poweroff"
        }
    }

    FocusScope {
        id: focusItem
        anchors.fill: parent
        focus: controlPanel.isOpen

        Keys.onPressed: function(event) {
            var count = wheelModel.count
            if (event.key === Qt.Key_Escape) {
                controlPanel.closeRequested()
                event.accepted = true
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                var prev = (controlPanel.selectedIndex - 1 + count) % count
                controlPanel.selectIndex(prev)
                event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                var next = (controlPanel.selectedIndex + 1) % count
                controlPanel.selectIndex(next)
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                triggerSelected()
                event.accepted = true
            }
        }
    }

    function triggerSelected() {
        var item = wheelModel.get(selectedIndex)
        if (item.category === "TELEMETRY") {
            // Telemetry item
        } else if (item.actionCmd !== "") {
            controlPanel.closeRequested()
            controlPanel.runAction(item.actionCmd)
        }
    }

    Item {
        id: container
        anchors.fill: parent

        opacity: controlPanel.isOpen ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
        }

        Rectangle {
            anchors.fill: parent
            color: "#cc000000"
            opacity: controlPanel.isOpen ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                focusItem.forceActiveFocus()
                controlPanel.closeRequested()
            }
        }

        Item {
            anchors.centerIn: parent
            width: 780
            height: 780

            scale: controlPanel.isOpen ? 1.0 : 0.7
            opacity: controlPanel.isOpen ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation { duration: 250; easing.type: Easing.OutBack }
            }
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }

            // Center Info Hub
            Rectangle {
                anchors.centerIn: parent
                width: 300
                height: 300
                radius: 150
                color: "#111111"
                z: 10

                Rectangle {
                    anchors.centerIn: parent
                    width: 280
                    height: 280
                    radius: 140
                    color: "transparent"
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    width: 240

                    Text {
                        text: wheelModel.get(selectedIndex).category
                        color: "#ffffff"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    Text {
                        text: wheelModel.get(selectedIndex).icon
                        color: "#ffffff"
                        font.family: Theme.fontFamily
                        font.pixelSize: 34
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: wheelModel.get(selectedIndex).title
                        color: "#ffffff"
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    Text {
                        text: {
                            var item = wheelModel.get(selectedIndex)
                            if (item.title === "CPU PROCESSOR") return controlPanel.cpuUsage
                            if (item.title === "MEMORY STREAM") return controlPanel.memUsage
                            if (item.title === "STORAGE GRID") return controlPanel.diskUsage
                            return item.detailValue
                        }
                        color: "#ffffff"
                        font.family: Theme.fontFamily
                        font.pixelSize: 24
                        font.bold: true
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    Text {
                        text: {
                            var item = wheelModel.get(selectedIndex)
                            if (item.title === "STORAGE GRID") return (controlPanel.uptimeStr !== "" ? ("UPTIME: " + controlPanel.uptimeStr) : "UPTIME: SYNCING")
                            return item.detailSub
                        }
                        color: "#888888"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: triggerSelected()
                }
            }

            // Outer Circular Wheel (Direct trigonometric positioning)
            Item {
                anchors.centerIn: parent
                width: 0
                height: 0

                Repeater {
                    model: wheelModel

                    Item {
                        id: wheelItem
                        required property int index
                        required property string title
                        required property string icon
                        required property string category

                        property real itemAngle: ((index - controlPanel.wheelPosition) / wheelModel.count) * Math.PI * 2 - Math.PI / 2
                        property bool isSelected: index === controlPanel.selectedIndex

                        x: 260 * Math.cos(itemAngle) - width / 2
                        y: 260 * Math.sin(itemAngle) - height / 2
                        width: 96
                        height: 96

                        Rectangle {
                            anchors.fill: parent
                            radius: 48
                            color: isSelected ? "#ffffff" : "#111111"

                            Column {
                                anchors.centerIn: parent
                                width: parent.width - 16
                                spacing: 2

                                Text {
                                    text: icon
                                    color: isSelected ? "#111111" : "#ffffff"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 26
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: title.split(" ")[0]
                                    color: isSelected ? "#111111" : "#ffffff"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: controlPanel.selectIndex(index)
                        }
                    }
                }
            }

            // Disengage / Close button
            Item {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: -20
                width: 140
                height: 36

                Rectangle {
                    anchors.fill: parent
                    color: closeBottomMouse.containsMouse ? "#ffffff" : "#111111"
                    border.color: "#ffffff"
                    border.width: 1.5
                    radius: 8
                }

                Text {
                    text: "DISENGAGE [ESC]"
                    color: closeBottomMouse.containsMouse ? "#111111" : "#ffffff"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: closeBottomMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: controlPanel.closeRequested()
                }
            }
        }
    }
}
