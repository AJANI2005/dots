import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./components" as Components

Scope {
  property var theme: Components.Theme
	Variants {
		model: Quickshell.screens

    PanelWindow {
      id: bar
			required property var modelData
			screen: modelData

			anchors {
				top: true
				left: true
				right: true
			}

			color: theme.panelBg
			height: 26 

			Item {
				anchors.fill: parent
				anchors.leftMargin: 16
				anchors.rightMargin: 16

				Components.Workspaces {
					anchors.verticalCenter: parent.verticalCenter
					anchors.left: parent.left
				}
				Components.Clock { 
					anchors.centerIn: parent
      	}
				Components.NetworkBluetooth {
					anchors.verticalCenter: parent.verticalCenter
					anchors.right: parent.right
				}
			}
		}
	}
}
