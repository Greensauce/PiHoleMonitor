import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import "../code/pihole.js" as PiHole

PlasmoidItem {
    id: root

    property string status: "unknown"
    property int timeRemaining: 0
    property bool isEnabled: false
    property bool isLoading: false
    property string errorMessage: ""
    property string debugMessage: ""
    property string lastAction: ""
    property bool showDisableOptions: false

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground

    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 10

    preferredRepresentation: compactRepresentation

    Timer {
        id: updateTimer
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
                timeRemaining--;
            }
            if (timeRemaining === 0) {
                updateStatus();
            }
        }
    }

    Component.onCompleted: {
        updateStatus();
    }

    // Monitor configuration changes
    Connections {
        target: plasmoid.configuration
        
        function onPiholeHostChanged() {
            debugMessage = "Pi-hole IP changed";
            lastAction = "IP changed at " + new Date().toLocaleTimeString();
            updateStatus();
        }
        
        function onPiholeApiKeyChanged() {
            debugMessage = "App Password changed";
            lastAction = "Password changed at " + new Date().toLocaleTimeString();
            updateStatus();
        }
    }

    function updateStatus() {
        if (!plasmoid.configuration.piholeHost || !plasmoid.configuration.piholeApiKey) {
            status = "unconfigured";
            errorMessage = "Please configure Pi-hole IP and App Password";
            return;
        }

        isLoading = true;
        errorMessage = "";
        PiHole.getStatus(
            plasmoid.configuration.piholeHost,
            plasmoid.configuration.piholeApiKey,
            function(success, response) {
                isLoading = false;
                if (success) {
                    status = response.status;
                    isEnabled = (status === "enabled");
                    errorMessage = "";
                    
                    // Extract timer from response if present (v6 API)
                    if (!isEnabled && response.timer !== undefined && response.timer > 0) {
                        timeRemaining = Math.ceil(response.timer);
                        console.log("[Pi-hole Widget] Status update: disabled with timer =", timeRemaining);
                    } else if (isEnabled) {
                        timeRemaining = 0;
                    }
                } else {
                    status = "error";
                    // Show detailed error message
                    errorMessage = response.error || "Connection failed";
                    console.log("Pi-hole API Error:", errorMessage);
                    console.log("Response:", JSON.stringify(response));
                }
            }
        );
    }

    function togglePiHole() {
        if (!plasmoid.configuration.piholeHost || !plasmoid.configuration.piholeApiKey) {
            console.log("[Pi-hole Widget] Cannot toggle - missing configuration");
            debugMessage = "Missing configuration";
            return;
        }

        var timestamp = new Date().toLocaleTimeString();
        console.log("[Pi-hole Widget] Toggle clicked at " + timestamp + ", current state:", isEnabled ? "enabled" : "disabled");
        lastAction = "Toggle clicked at " + timestamp;
        
        if (isEnabled) {
            // Show inline disable options
            console.log("[Pi-hole Widget] Showing disable options");
            debugMessage = "Choose disable duration...";
            lastAction = "Showing options at " + timestamp;
            showDisableOptions = true;
        } else {
            // Enable Pi-hole
            console.log("[Pi-hole Widget] Enabling Pi-hole");
            debugMessage = "Enabling Pi-hole...";
            lastAction = "Enabling at " + timestamp;
            showDisableOptions = false;
            isLoading = true;
            errorMessage = "";
            PiHole.enable(
                plasmoid.configuration.piholeHost,
                plasmoid.configuration.piholeApiKey,
                function(success, response) {
                    isLoading = false;
                    if (success) {
                        console.log("[Pi-hole Widget] Enable succeeded");
                        debugMessage = "Enabled successfully";
                        lastAction = "Enabled at " + timestamp;
                        timeRemaining = 0;
                        updateStatus();
                    } else {
                        errorMessage = response.error || "Failed to enable";
                        debugMessage = "Enable failed: " + errorMessage;
                        lastAction = "Enable failed at " + timestamp;
                        console.log("[Pi-hole Widget] Enable failed:", errorMessage);
                    }
                }
            );
        }
    }

    function disablePiHole(seconds) {
        var timestamp = new Date().toLocaleTimeString();
        console.log("[Pi-hole Widget] Disabling Pi-hole for", seconds, "seconds at", timestamp);
        debugMessage = "Disabling for " + seconds + " seconds...";
        lastAction = "Disabling at " + timestamp + " for " + seconds + "s";
        showDisableOptions = false;
        isLoading = true;
        errorMessage = "";
        PiHole.disable(
            plasmoid.configuration.piholeHost,
            plasmoid.configuration.piholeApiKey,
            seconds,
            function(success, response) {
                isLoading = false;
                if (success) {
                    console.log("[Pi-hole Widget] Disable succeeded");
                    debugMessage = "Disabled for " + seconds + " seconds";
                    lastAction = "Disabled at " + timestamp;
                    
                    // Immediately update state based on successful disable
                    isEnabled = false;
                    status = "disabled";
                    timeRemaining = seconds;
                    
                    // Don't call updateStatus() - it might return cached/delayed data
                    // The auto-refresh timer will update it on the next cycle
                } else {
                    errorMessage = response.error || "Failed to disable";
                    debugMessage = "Disable failed: " + errorMessage;
                    lastAction = "Disable failed at " + timestamp;
                    status = "error";
                    console.log("[Pi-hole Widget] Disable failed:", errorMessage);
                }
            }
        );
    }

    compactRepresentation: Item {
        id: compact

        Layout.minimumWidth: compactLayout.implicitWidth
        Layout.minimumHeight: compactLayout.implicitHeight
        Layout.preferredWidth: compactLayout.implicitWidth
        Layout.preferredHeight: compactLayout.implicitHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        ColumnLayout {
            id: compactLayout
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            // Title (optional)
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignHCenter
                text: plasmoid.configuration.widgetTitle || "Pi-hole"
                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                font.bold: true
                visible: plasmoid.configuration.showTitle
                horizontalAlignment: Text.AlignHCenter
            }

            // Status row (icon + text)
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    id: statusIndicator
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    radius: width / 2
                    color: {
                        if (status === "error") return Kirigami.Theme.negativeTextColor;
                        if (status === "unconfigured") return Kirigami.Theme.neutralTextColor;
                        if (isLoading) return Kirigami.Theme.highlightColor;
                        return isEnabled ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor;
                    }
                    
                    PlasmaComponents3.Label {
                        anchors.centerIn: parent
                        text: {
                            if (status === "unconfigured") return "?";
                            if (status === "error") return "!";
                            if (isLoading) return "⟳";
                            return isEnabled ? "✓" : "✗";
                        }
                        color: Kirigami.Theme.backgroundColor
                        font.bold: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.8
                    }

                    RotationAnimation on rotation {
                        running: isLoading
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 1000
                    }
                }

                PlasmaComponents3.Label {
                    text: {
                        if (status === "unconfigured") return "Config";
                        if (status === "error") return "Error";
                        if (isLoading) return "...";
                        if (!isEnabled && timeRemaining > 0) return "Paused " + PiHole.formatTime(timeRemaining);
                        return isEnabled ? "On" : "Off";
                    }
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Kirigami.Units.gridUnit * 18
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredHeight: Kirigami.Units.gridUnit * 22

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            // Title (optional)
            PlasmaComponents3.Label {
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width - Kirigami.Units.largeSpacing * 2
                text: plasmoid.configuration.widgetTitle || "Pi-hole Status"
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.4
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                elide: Text.ElideNone
                visible: plasmoid.configuration.showTitle
            }

            // Header
            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.large
                    Layout.preferredHeight: Kirigami.Units.iconSizes.large
                    radius: width / 2
                    color: isEnabled ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                    
                    PlasmaComponents3.Label {
                        anchors.centerIn: parent
                        text: isEnabled ? "✓" : "✗"
                        color: Kirigami.Theme.backgroundColor
                        font.bold: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 2
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    PlasmaComponents3.Label {
                        text: "Pi-hole"
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.3
                        font.bold: true
                    }

                    PlasmaComponents3.Label {
                        text: {
                            if (status === "unconfigured") return "Not configured";
                            if (status === "error") return errorMessage || "Connection error";
                            return isEnabled ? "Enabled" : "Disabled";
                        }
                        opacity: 0.7
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                    }
                }
            }

            // Status info
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: statusColumn.implicitHeight + Kirigami.Units.largeSpacing * 2
                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.smallSpacing
                border.color: Kirigami.Theme.highlightColor
                border.width: 1
                opacity: 0.3

                ColumnLayout {
                    id: statusColumn
                    anchors.centerIn: parent
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents3.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: isEnabled ? "Protection Active" : "Protection Disabled"
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                        font.bold: true
                    }

                    PlasmaComponents3.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            if (!isEnabled && timeRemaining > 0) {
                                return "Time remaining: " + PiHole.formatTime(timeRemaining);
                            }
                            return "";
                        }
                        visible: !isEnabled && timeRemaining > 0
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    }
                }
            }

            // Debug info section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: debugColumn.implicitHeight + Kirigami.Units.largeSpacing * 2
                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.smallSpacing
                border.color: Kirigami.Theme.highlightColor
                border.width: 1
                opacity: 0.5
                visible: debugMessage !== "" || lastAction !== ""

                ColumnLayout {
                    id: debugColumn
                    anchors.centerIn: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing
                    width: parent.width - Kirigami.Units.largeSpacing * 2

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: "Debug Info:"
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        font.bold: true
                        visible: debugMessage !== ""
                    }

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: debugMessage
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        wrapMode: Text.Wrap
                        visible: debugMessage !== ""
                    }

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: "Last action: " + lastAction
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        wrapMode: Text.Wrap
                        visible: lastAction !== ""
                        opacity: 0.7
                    }
                }
            }

            // Toggle button
            PlasmaComponents3.Button {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2.5
                text: {
                    if (status === "unconfigured") return "Configure Widget";
                    if (isLoading) return "Loading...";
                    return isEnabled ? "Disable Pi-hole" : "Enable Pi-hole";
                }
                icon.name: isEnabled ? "dialog-cancel" : "dialog-ok-apply"
                enabled: !isLoading && status !== "unconfigured"
                visible: !showDisableOptions
                onClicked: {
                    if (status === "unconfigured") {
                        plasmoid.internalAction("configure").trigger();
                    } else {
                        togglePiHole();
                    }
                }
            }

            // Disable duration options (shown when user clicks Disable)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
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
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.smallSpacing

                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "10 sec"
                        onClicked: disablePiHole(10)
                    }

                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "30 sec"
                        onClicked: disablePiHole(30)
                    }

                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "5 min"
                        onClicked: disablePiHole(300)
                    }

                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "10 min"
                        onClicked: disablePiHole(600)
                    }

                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "30 min"
                        onClicked: disablePiHole(1800)
                    }

                    PlasmaComponents3.Button {
                        Layout.fillWidth: true
                        text: "Forever"
                        onClicked: disablePiHole(0)
                    }
                }

                PlasmaComponents3.Button {
                    Layout.fillWidth: true
                    text: "Cancel"
                    icon.name: "dialog-cancel"
                    onClicked: {
                        showDisableOptions = false;
                        debugMessage = "Cancelled";
                    }
                }
            }

            // Refresh button
            PlasmaComponents3.Button {
                Layout.fillWidth: true
                text: "Refresh Status"
                icon.name: "view-refresh"
                enabled: !isLoading && status !== "unconfigured"
                visible: !showDisableOptions
                onClicked: updateStatus()
            }

            Item { Layout.fillHeight: true }
        }
    }
}
