import Quickshell
import Quickshell.Io
import QtQuick
import "./components"

Scope {
  // no more time object
  property color bgCol: "#aa1b1b1b"

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      color: bgCol
      implicitHeight: 15

      Workspaces {}


    }
  }
}
