/**
 * Pi-hole Plasma Widget
 * Copyright (C) 2024-2025 Bryan Greenaway
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/pihole.js" as PiHole

PlasmoidItem {
    id: root

    property string status: "unknown"
    property int timeRemaining: 0
    property bool isEnabled: false
    property string errorMessage: ""
    property bool showDisableOptions: false

    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 10
    hideOnWindowDeactivate: true
    
    onExpandedChanged: {
        if (!expanded) {
            showDisableOptions = false
        }
    }

    Timer {
        id: refreshTimer
        interval: plasmoid.configuration.updateInterval * 1000
        running: true
        repeat: true
        onTriggered: updateStatus()
    }

    Timer {
        id: countdownTimer
        interval: 1000
        running: !isEnabled && timeRemaining > 0
        repeat: true
        onTriggered: {
            if (timeRemaining > 0) {
                timeRemaining--
                if (timeRemaining === 0) updateStatus()
            }
        }
    }

    Component.onCompleted: updateStatus()

    Connections {
        target: plasmoid.configuration
        function onPiholeHostChanged() { updateStatus() }
        function onPiholeApiKeyChanged() { updateStatus() }
    }

    function updateStatus() {
        if (!plasmoid.configuration.piholeHost || !plasmoid.configuration.piholeApiKey) {
            if (status !== "unconfigured") {
                status = "unconfigured"
                errorMessage = "Please configure Pi-hole settings"
            }
            return
        }

        PiHole.getStatus(
            plasmoid.configuration.piholeHost,
            plasmoid.configuration.piholeApiKey,
            function(success, response) {
                if (success) {
                    var newStatus = response.status
                    var newEnabled = (newStatus === "enabled")
                    var newTimeRemaining = response.timer || 0
                    
                    if (status !== newStatus || isEnabled !== newEnabled || timeRemaining !== newTimeRemaining) {
                        status = newStatus
                        isEnabled = newEnabled
                        timeRemaining = newTimeRemaining
                        errorMessage = ""
                    }
                } else {
                    var newError = response.error || "Connection failed"
                    if (status !== "error" || errorMessage !== newError) {
                        status = "error"
                        errorMessage = newError
                    }
                }
            }
        )
    }

    function togglePiHole() {
        if (isEnabled) {
            showDisableOptions = true
        } else {
            PiHole.enable(
                plasmoid.configuration.piholeHost,
                plasmoid.configuration.piholeApiKey,
                function(success) { if (success) updateStatus() }
            )
        }
    }

    function disablePiHole(seconds) {
        showDisableOptions = false
        PiHole.disable(
            plasmoid.configuration.piholeHost,
            plasmoid.configuration.piholeApiKey,
            seconds,
            function(success) { if (success) updateStatus() }
        )
    }

    compactRepresentation: Item {
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        RowLayout {
            anchors.centerIn: parent
            width: Math.min(implicitWidth, parent.width)
            spacing: Kirigami.Units.smallSpacing

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                radius: width / 2
                color: {
                    if (status === "error") return Kirigami.Theme.negativeTextColor
                    if (status === "unconfigured") return Kirigami.Theme.neutralTextColor
                    return isEnabled ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                }

                PlasmaComponents3.Label {
                    anchors.centerIn: parent
                    text: {
                        if (status === "unconfigured") return "?"
                        if (status === "error") return "!"
                        return isEnabled ? "✓" : "✗"
                    }
                    color: Kirigami.Theme.backgroundColor
                    font.pixelSize: parent.height * 0.6
                    font.bold: true
                }
            }

            Text {
                Layout.fillWidth: true
                text: {
                    if (status === "unconfigured") return "Config"
                    if (status === "error") return "Error"
                    if (!isEnabled && timeRemaining > 0) return "Paused " + PiHole.formatTime(timeRemaining)
                    return isEnabled ? "Active" : "Disabled"
                }
                color: Kirigami.Theme.textColor
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                fontSizeMode: Text.HorizontalFit
                minimumPointSize: Math.round(Kirigami.Theme.smallFont.pointSize * 0.6)
            }
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredHeight: Kirigami.Units.gridUnit * 20
        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Kirigami.Units.gridUnit * 16

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: plasmoid.configuration.widgetTitle || "Pi-hole Status"
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.4
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                visible: plasmoid.configuration.showTitle
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.largeSpacing

                Rectangle {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.large
                    Layout.preferredHeight: Kirigami.Units.iconSizes.large
                    radius: width / 2
                    color: isEnabled ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor

                    PlasmaComponents3.Label {
                        anchors.centerIn: parent
                        text: isEnabled ? "✓" : "✗"
                        color: Kirigami.Theme.backgroundColor
                        font.pixelSize: parent.height * 0.6
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    PlasmaComponents3.Label {
                        text: {
                            if (status === "unconfigured") return "Not Configured"
                            if (status === "error") return "Connection Error"
                            return isEnabled ? "Protection Active" : "Protection Disabled"
                        }
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                        font.bold: true
                    }

                    PlasmaComponents3.Label {
                        text: errorMessage
                        visible: errorMessage !== ""
                        wrapMode: Text.Wrap
                        color: Kirigami.Theme.negativeTextColor
                    }

                    PlasmaComponents3.Label {
                        text: "Time remaining: " + PiHole.formatTime(timeRemaining)
                        visible: !isEnabled && timeRemaining > 0
                    }
                }
            }

            PlasmaComponents3.Button {
                Layout.fillWidth: true
                text: {
                    if (status === "unconfigured") return "Configure Widget"
                    return isEnabled ? "Disable Pi-hole" : "Enable Pi-hole"
                }
                icon.name: {
                    if (status === "unconfigured") return "configure"
                    return isEnabled ? "security-low" : "security-high"
                }
                enabled: status !== "unconfigured"
                visible: !showDisableOptions
                onClicked: {
                    if (status === "unconfigured") {
                        plasmoid.internalAction("configure").trigger()
                    } else {
                        togglePiHole()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: showDisableOptions

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: "Choose duration:"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2

                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "10 seconds"
                        onClicked: disablePiHole(10)
                    }
                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "30 seconds"
                        onClicked: disablePiHole(30)
                    }
                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "5 minutes"
                        onClicked: disablePiHole(300)
                    }
                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "10 minutes"
                        onClicked: disablePiHole(600)
                    }
                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "30 minutes"
                        onClicked: disablePiHole(1800)
                    }
                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "Indefinitely"
                        onClicked: disablePiHole(0)
                    }
                }

                PlasmaComponents3.Button {
                    Layout.fillWidth: true
                    text: "Cancel"
                    icon.name: "dialog-cancel"
                    onClicked: showDisableOptions = false
                }
            }

            PlasmaComponents3.Button {
                Layout.fillWidth: true
                text: "Refresh Status"
                icon.name: "view-refresh"
                enabled: status !== "unconfigured"
                visible: !showDisableOptions
                onClicked: updateStatus()
            }

            Item { Layout.fillHeight: true }
        }
    }
}
