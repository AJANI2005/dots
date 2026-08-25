import Quickshell
import Quickshell.Io
import QtQuick
import "Theme"

Item {
  id: workspaces
  property string focusedWorkspace: "1"
  property string activeWorkspaces: ["1"]

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
      "mmsg get all-tags | jq -r '.all_tags[].tags[] | select(.client_count > 0) | .index' | tr '\n' ' '"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        workspaces.activeWorkspaces = text.trim().split(" ")
      }
    }
  }
  
  Process {
    id: getFocusedWorkspace
    command: [
      "sh", "-c",
      "mmsg get all-tags | jq -r '.all_tags[].tags[] | select(.is_active) | .index'"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        workspaces.focusedWorkspace = text.trim()
      }
    }
  }

  Row{
    spacing: 15 
    Repeater {
        model: 9
        Text {
          property bool is_focused : String(model.index) == workspaces.focusedWorkspace
          visible: workspaces.activeWorkspaces.includes(model.index)
          text: model.index 
          color: is_focused ? Theme.active : Theme.inactive
          font.family: Theme.fontFamily
          font.bold: is_focused 
        }
    }
  }

}
