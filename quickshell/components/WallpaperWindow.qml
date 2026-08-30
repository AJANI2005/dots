import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "./Theme"

PanelWindow {
    id: wallpaperPopup
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

    property string wallpaperDir: "/home/ajani/dots/wallpapers"

    ListModel {
        id: wallpaperModel
    }

    property int currentIndex: 0
    property string currentWallpaper: ""

    onIsOpenChanged: {
        if (isOpen) {
            loadWallpapersProcess.running = true
            getCurrentWallpaperProcess.running = true
            focusTimer.restart()
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: {
            if (wallpaperPopup.isOpen) {
                focusItem.forceActiveFocus()
            }
        }
    }

    Process {
        id: loadWallpapersProcess
        command: ["sh", "-c", "ls -1 '" + wallpaperPopup.wallpaperDir + "' 2>/dev/null | grep -E '\\.(jpg|jpeg|png|webp|gif)$' | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                wallpaperModel.clear()
                var lines = text.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.length === 0) continue
                    wallpaperModel.append({ "fileName": line, "path": wallpaperPopup.wallpaperDir + "/" + line })
                }
                if (wallpaperModel.count > 0 && wallpaperPopup.currentIndex >= wallpaperModel.count) {
                    wallpaperPopup.currentIndex = 0
                }
            }
        }
    }

    Process {
        id: getCurrentWallpaperProcess
        command: ["sh", "-c", "awww query 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var match = text.match(/currently displaying:\s*image:\s*([^\r\n]+)/)
                if (match && match[1]) {
                    wallpaperPopup.currentWallpaper = match[1].trim()
                    for (var i = 0; i < wallpaperModel.count; i++) {
                        if (wallpaperModel.get(i).path === wallpaperPopup.currentWallpaper) {
                            wallpaperPopup.currentIndex = i
                            break
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        loadWallpapersProcess.running = true
        getCurrentWallpaperProcess.running = true
    }

    Process {
        id: setWallpaperProcess
    }

    function setWallpaper(path) {
        setWallpaperProcess.command = ["awww", "img", path, "--transition-type", "random", "--transition-fps", "144"]
        setWallpaperProcess.running = true
    }

    function nextWallpaper() {
        if (wallpaperModel.count === 0) return
        currentIndex = (currentIndex + 1) % wallpaperModel.count
    }

    function prevWallpaper() {
        if (wallpaperModel.count === 0) return
        currentIndex = (currentIndex - 1 + wallpaperModel.count) % wallpaperModel.count
    }

    function selectCurrent() {
        if (wallpaperModel.count > 0 && currentIndex >= 0 && currentIndex < wallpaperModel.count) {
            var selectedPath = wallpaperModel.get(currentIndex).path
            setWallpaper(selectedPath)
            closeRequested()
        }
    }

    // Global invisible input to catch keys reliably
    TextInput {
        id: focusItem
        anchors.fill: parent
        opacity: 0
        focus: wallpaperPopup.isOpen
        activeFocusOnTab: true

        onAccepted: wallpaperPopup.selectCurrent()

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                wallpaperPopup.closeRequested()
                event.accepted = true
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                wallpaperPopup.prevWallpaper()
                event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                wallpaperPopup.nextWallpaper()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_NumEnter) {
                wallpaperPopup.selectCurrent()
                event.accepted = true
            }
        }
    }

    // Transparent container with subtle dark vignette
    Item {
        id: container
        anchors.fill: parent

        opacity: wallpaperPopup.isOpen ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
        }

        Rectangle {
            anchors.fill: parent
            color: "#cc000000"
            opacity: wallpaperPopup.isOpen ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                focusItem.forceActiveFocus()
                wallpaperPopup.closeRequested()
            }
        }

        // Square overlapping parallelograms carousel view
        Item {
            anchors.centerIn: parent
            width: 1000
            height: 600

            Repeater {
                model: wallpaperModel

                Item {
                    id: cardItem
                    required property int index
                    required property string path
                    required property string fileName

                    property int count: wallpaperModel.count
                    property int wrappedDiff: {
                        var d = index - wallpaperPopup.currentIndex
                        if (d > count / 2) d -= count
                        if (d < -count / 2) d += count
                        return d
                    }

                    property bool isSelected: wrappedDiff === 0
                    
                    x: parent.width / 2 - width / 2 + wrappedDiff * 240
                    y: parent.height / 2 - height / 2 + Math.abs(wrappedDiff) * 30
                    
                    // Square dimensions
                    width: 450
                    height: 450
                    
                    scale: isSelected ? 1.15 : Math.max(0.7, 1.0 - Math.abs(wrappedDiff) * 0.15)
                    opacity: Math.abs(wrappedDiff) > 3 ? 0.0 : (isSelected ? 1.0 : Math.max(0.2, 1.0 - Math.abs(wrappedDiff) * 0.25))
                    z: 100 - Math.abs(wrappedDiff)

                    Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
                    Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
                    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }

                    // Parallelogram container using shear transformation
                    Item {
                        id: parallelogramContainer
                        anchors.fill: parent
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(
                                1, -0.3, 0, 0,
                                0,  1,   0, 0,
                                0,  0,   1, 0,
                                0,  0,   0, 1
                            )
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: Theme.bg
                            border.color: isSelected ? Theme.active : Theme.inactive
                            border.width: isSelected ? 4 : 1
                            radius: 12
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: "file://" + path
                                asynchronous: true
                                cache: true
                                sourceSize.width: 450
                                sourceSize.height: 450
                                fillMode: Image.PreserveAspectCrop
                                clip: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            focusItem.forceActiveFocus()
                            wallpaperPopup.currentIndex = index
                            wallpaperPopup.selectCurrent()
                        }
                    }
                }
            }
        }
    }
}