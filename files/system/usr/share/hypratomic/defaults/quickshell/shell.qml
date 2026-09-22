// Hypratomic's default Quickshell bar.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

ShellRoot {
    property var activeNotification: null

    Loader {
        id: notificationLoader
        active: Quickshell.env("HYPRATOMIC_QUICKSHELL_NOTIFICATIONS") === "1"
        sourceComponent: NotificationServer {
            bodySupported: true
            actionsSupported: false
            keepOnReload: false
            onNotification: notification => {
                notification.tracked = true
                activeNotification = notification
                notificationTimer.restart()
            }
        }
    }

    Timer {
        id: notificationTimer
        interval: 6000
        repeat: false
        onTriggered: {
            if (activeNotification !== null) {
                activeNotification.dismiss()
                activeNotification = null
            }
        }
    }

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
            implicitHeight: 34
            color: "transparent"
            exclusionMode: ExclusionMode.Normal

            Rectangle {
                anchors.fill: parent
                color: "#1e1e2e"
                border.color: "#45475a"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    Text {
                        text: "HYPRATOMIC"
                        color: "#89b4fa"
                        font.family: "JetBrains Mono"
                        font.bold: true
                        font.pixelSize: 12
                    }

                    Rectangle {
                        implicitWidth: 62
                        implicitHeight: 24
                        radius: 4
                        color: menuMouse.containsMouse ? "#313244" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "Menu"
                            color: "#cdd6f4"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: menuMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Quickshell.execDetached(["hypratomic-launcher"])
                        }
                    }

                    Rectangle {
                        implicitWidth: 72
                        implicitHeight: 24
                        radius: 4
                        color: powerMouse.containsMouse ? "#313244" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "Power"
                            color: "#cdd6f4"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: powerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Quickshell.execDetached(["hypratomic-power-menu"])
                        }
                    }

                    Text {
                        text: "Hypratomic"
                        color: "#6c7086"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }

                    Text {
                        id: clock
                        color: "#cdd6f4"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                    }

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd MMM d  HH:mm")
                    }

                    Component.onCompleted: clock.text = Qt.formatDateTime(new Date(), "ddd MMM d  HH:mm")
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: activeNotification !== null
            anchors {
                top: true
                right: true
            }
            margins {
                top: 48
                right: 16
            }
            implicitWidth: 360
            implicitHeight: 104
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: "#1e1e2e"
                border.color: "#89b4fa"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 5

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: activeNotification === null ? "" : activeNotification.summary
                        color: "#cdd6f4"
                        font.family: "JetBrains Mono"
                        font.bold: true
                        font.pixelSize: 13
                    }

                    Text {
                        width: parent.width
                        height: 48
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        text: activeNotification === null ? "" : activeNotification.body
                        color: "#bac2de"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (activeNotification !== null) {
                            activeNotification.dismiss()
                            activeNotification = null
                        }
                    }
                }
            }
        }
    }
}
