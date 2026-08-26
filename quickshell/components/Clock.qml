import Quickshell
import Quickshell.Io
import QtQuick
import "Theme"

Item {
  id: clock
  property string text: "1"
  property string activeWorkspaces: ["1"]

  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      getDate.running = true
    }
  }

  Process {
    id: getDate
    command: [
      "sh", "-c",
      "date '+%a %I:%M'"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        clock.text = text.trim()
      }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    text: clock.text 
    color: Theme.fg
    font.family: Theme.fontFamily
  }

}
