import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./components" as Components
//import "./panels" as Panels

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
			implicitHeight: 16 

			Components.Workspaces {}
			Components.Clock { 
				anchors.horizontalCenter: parent.horizontalCenter
			}


		}
	}
}
