import Quickshell
import Quickshell.Io
import QtQuick
import "./Theme"

Item {
  id: workspaces
  property string focusedWorkspace: "1"
  property var activeWorkspaces: ["1"]
  anchors.verticalCenter: parent.verticalCenter
  height: parent.height

  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      getWorkspace.running = true
      getFocusedWorkspace.running = true
    }
  }

  Process {
    id: getWorkspace
    command: [
      "sh", "-c",
      "mmsg get all-tags 2>/dev/null | jq -r '.all_tags[].tags[] | select(.client_count > 0) | .index' | tr '\n' ' ' || echo '1'"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        let res = text.trim()
        if (res !== "") {
            workspaces.activeWorkspaces = res.split(" ")
        }
      }
    }
  }
  
  Process {
    id: getFocusedWorkspace
    command: [
      "sh", "-c",
      "mmsg get all-tags 2>/dev/null | jq -r '.all_tags[].tags[] | select(.is_active) | .index' || echo '1'"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        let res = text.trim()
        if (res !== "") {
            workspaces.focusedWorkspace = res
        }
      }
    }
  }

  implicitWidth: wsRow.implicitWidth
  implicitHeight: wsRow.implicitHeight

  Row{
    id: wsRow
    spacing: 2 
    anchors.verticalCenter: parent.verticalCenter
    Repeater {
        model: 9
        Rectangle {
            id: wsRect
            property bool is_focused : String(model.index + 1) == workspaces.focusedWorkspace
            visible: true
            width: 14
            height: 14
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: model.index + 1
                color: wsRect.is_focused ? Theme.active : Theme.inactiveFg
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: wsRect.is_focused
            }
        }
    }
  }

}
