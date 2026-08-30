import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./components" as Components

Scope {
    id: rootScope
    property var theme: Components.Theme
    property bool notesOpen: false
    property bool wallpaperOpen: false
    property bool controlPanelOpen: false

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
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Components.Clock { 
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    spacing: 16

                    Components.TodoIcon {
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Components.WallpaperIcon {
                        anchors.verticalCenter: parent.verticalCenter
                    }
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

    Components.TodoWindow {
        isOpen: rootScope.notesOpen
        onCloseRequested: {
            rootScope.notesOpen = false
        }
    }

    Components.WallpaperWindow {
        isOpen: rootScope.wallpaperOpen
        onCloseRequested: {
            rootScope.wallpaperOpen = false
        }
    }


    Components.Dock {}
}
