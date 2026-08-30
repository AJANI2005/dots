import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "./Theme"

PanelWindow {
    id: notesPopup
    property bool isOpen: false
    signal closeRequested()
    visible: isOpen || popupContainer.opacity > 0.01
    color: "transparent"

    // Ignore exclusion so it does not push the bar or other windows
    exclusionMode: ExclusionMode.Ignore
    
    // Set layer to Overlay so it floats above everything
    WlrLayershell.layer: WlrLayer.Overlay
    
    // Manage keyboard focus dynamically: exclusive when open, none when closed
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Set layout/anchors - position below the todo icon on the right side
    anchors {
        top: true
        right: true
    }

    margins {
        top: 32 // Just below the 26px bar
        right: 16 // Align with panel right margin
    }

    width: 380
    height: 480

    property string dataFilePath: Quickshell.env("HOME") + "/.config/quickshell/data/todos.txt"

    ListModel {
        id: todoModel
    }

    onIsOpenChanged: {
        if (isOpen) {
            loadTodosProcess.running = true
            focusTimer.restart()
        }
    }

    Timer {
        id: focusTimer
        interval: 60
        onTriggered: {
            if (notesPopup.isOpen) {
                newTodoInput.forceActiveFocus()
            }
        }
    }

    Process {
        id: loadTodosProcess
        command: ["sh", "-c", "mkdir -p $(dirname '" + notesPopup.dataFilePath + "') && touch '" + notesPopup.dataFilePath + "' && cat '" + notesPopup.dataFilePath + "'"]
        stdout: StdioCollector {
            onStreamFinished: {
                todoModel.clear()
                var lines = text.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.length === 0) continue
                    var parts = line.split("|")
                    var isDone = parts[0] === "1"
                    var tText = parts.slice(1).join("|")
                    todoModel.append({ "todoText": tText, "completed": isDone })
                }
            }
        }
    }

    Component.onCompleted: {
        loadTodosProcess.running = true
    }

    function saveTodos() {
        var content = ""
        for (var i = 0; i < todoModel.count; i++) {
            var item = todoModel.get(i)
            var flag = item.completed ? "1" : "0"
            content += flag + "|" + item.todoText + "\n"
        }
        writerProcess.writeContent = content
        writerProcess.running = true
    }

    Process {
        id: writerProcess
        property string writeContent: ""
        command: [
            "sh", "-c",
            "file='" + notesPopup.dataFilePath + "'; " +
            "mkdir -p $(dirname \"$file\"); " +
            "echo -n '" + Qt.btoa(writerProcess.writeContent) + "' | base64 -d > \"$file\""
        ]
    }

    Rectangle {
        id: popupContainer
        anchors.fill: parent
        color: Theme.bg
        border.color: Theme.inactive
        border.width: 1
        radius: 8

        opacity: notesPopup.isOpen ? 1.0 : 0.0
        scale: notesPopup.isOpen ? 1.0 : 0.94
        transformOrigin: Item.Top

        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Header
            Item {
                width: parent.width
                height: 26

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        text: "󰆉"
                        color: Theme.active
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 1
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Todo"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    // Clear done button
                    Rectangle {
                        width: 72
                        height: 22
                        radius: 4
                        color: Theme.inactive
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "Clear"
                            color: Theme.inactiveFg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                for (var i = todoModel.count - 1; i >= 0; i--) {
                                    if (todoModel.get(i).completed) {
                                        todoModel.remove(i)
                                    }
                                }
                                notesPopup.saveTodos()
                            }
                        }
                    }

                    // Close button
                    Rectangle {
                        width: 22
                        height: 22
                        radius: 4
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "󰅖"
                            color: Theme.inactiveFg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                notesPopup.closeRequested()
                            }
                        }
                    }
                }
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.inactive
            }

            // Tasks List
            ListView {
                id: listView
                width: parent.width
                height: 350
                model: todoModel
                clip: true
                spacing: 6

                Text {
                    anchors.centerIn: parent
                    text: "No tasks yet. Add one below!"
                    color: Theme.inactiveFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    visible: todoModel.count === 0
                }

                delegate: Rectangle {
                    width: listView.width
                    height: 34
                    color: completed ? Theme.inactive : "#141417"
                    radius: 5
                    border.color: Theme.inactive
                    border.width: 1

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        // Checkbox
                        Rectangle {
                            id: checkRect
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            color: "transparent"

                            Text {
                                text: completed ? "󰱒" : "󰄱"
                                color: completed ? Theme.active : Theme.inactiveFg
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 1
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    todoModel.setProperty(index, "completed", !completed)
                                    notesPopup.saveTodos()
                                }
                            }
                        }

                        // Delete button
                        Rectangle {
                            id: delRect
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            color: "transparent"

                            Text {
                                text: "󰅖"
                                color: Theme.inactiveFg
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    todoModel.remove(index)
                                    notesPopup.saveTodos()
                                }
                            }
                        }

                        // Task Text
                        TextInput {
                            id: taskInput
                            anchors.left: checkRect.right
                            anchors.leftMargin: 8
                            anchors.right: delRect.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: todoText
                            color: completed ? Theme.inactiveFg : Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            font.strikeout: completed
                            selectByMouse: true
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true

                            onTextChanged: {
                                if (text !== todoText) {
                                    todoModel.setProperty(index, "todoText", text)
                                    notesPopup.saveTodos()
                                }
                            }

                            Keys.onEscapePressed: {
                                notesPopup.closeRequested()
                            }
                        }
                    }
                }
            }

            // Add Task / Note Input Bar
            Item {
                width: parent.width
                height: 32

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: addBtn.left
                    anchors.rightMargin: 8
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: Theme.inactive
                    radius: 5

                    TextInput {
                        id: newTodoInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1

                        Text {
                            text: "Add a note or task..."
                            color: Theme.inactiveFg
                            font: parent.font
                            visible: parent.text.length === 0 && !parent.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Keys.onReturnPressed: {
                            addTodo()
                        }

                            Keys.onEscapePressed: {
                                notesPopup.closeRequested()
                            }
                    }
                }

                Rectangle {
                    id: addBtn
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 50
                    color: Theme.active
                    radius: 5

                    Text {
                        text: "Add"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            addTodo()
                        }
                    }
                }
            }
        }
    }

    function addTodo() {
        var val = newTodoInput.text.trim()
        if (val.length > 0) {
            todoModel.append({ "todoText": val, "completed": false })
            newTodoInput.text = ""
            notesPopup.saveTodos()
        }
    }
}
