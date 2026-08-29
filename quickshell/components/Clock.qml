import Quickshell
import Quickshell.Io
import QtQuick
import "./Theme"

Item {
  id: clock
  property string text: "Loading..."
  anchors.verticalCenter: parent.verticalCenter
  implicitWidth: clockRow.implicitWidth
  implicitHeight: clockRow.implicitHeight

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      getDate.running = true
    }
  }

  Process {
    id: getDate
    command: [
      "sh", "-c",
      "date '+%a %b %d  %H:%M'"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        clock.text = text.trim()
      }
    }
  }

  Row {
    id: clockRow
    spacing: 8
    anchors.centerIn: parent
    Rectangle {
      width: clockTextRow.implicitWidth + 12
      height: 18
      radius: 9
      color: "transparent"
      anchors.verticalCenter: parent.verticalCenter

      Row {
        id: clockTextRow
        spacing: 6
        anchors.centerIn: parent
        Text {
          text: "󰥔"
          color: Theme.active
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
          anchors.verticalCenter: parent.verticalCenter
        }
        Text {
          text: clock.text 
          color: Theme.fg
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
          anchors.verticalCenter: parent.verticalCenter
        }
      }
    }
  }
}
