// Phase 4 preview: an opt-in bar that can run alongside Waybar.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
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

                    Text {
                        text: "Phase 4 preview"
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
}
