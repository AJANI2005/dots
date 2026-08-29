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

				Row {
					anchors.verticalCenter: parent.verticalCenter
					anchors.left: parent.left
					spacing: 8

					Components.Launcher {
						anchors.verticalCenter: parent.verticalCenter
					}
					Components.Workspaces {
						anchors.verticalCenter: parent.verticalCenter
					}
				}
				Components.Clock { 
					anchors.centerIn: parent
      	}
				Row {
					anchors.verticalCenter: parent.verticalCenter
					anchors.right: parent.right
					spacing: 16

					Components.Battery {
						anchors.verticalCenter: parent.verticalCenter
					}
					Components.NetworkBluetooth {
						anchors.verticalCenter: parent.verticalCenter
					}
				}
			}
		}
	}
}
