/**
 * Pi-hole Plasma Widget - Configuration
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
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    property alias cfg_piholeHost: piholeHostField.text
    property alias cfg_piholeApiKey: apiKeyField.text
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_widgetTitle: widgetTitleField.text
    property alias cfg_showTitle: showTitleCheckbox.checked

    Kirigami.FormLayout {
        QQC2.TextField {
            id: piholeHostField
            Kirigami.FormData.label: "Pi-hole IP Address:"
            placeholderText: "e.g., 192.168.1.100"
        }

        QQC2.TextField {
            id: apiKeyField
            Kirigami.FormData.label: "App Password:"
            placeholderText: "Your Pi-hole v6 App Password"
            echoMode: TextInput.Password
        }

        QQC2.SpinBox {
            id: updateIntervalSpinBox
            Kirigami.FormData.label: "Update Interval (seconds):"
            from: 3
            to: 300
            stepSize: 1
        }

        Item {
            Kirigami.FormData.isSection: true
        }
        
        QQC2.CheckBox {
            id: showTitleCheckbox
            Kirigami.FormData.label: "Show Widget Title:"
            text: "Display title in expanded view"
        }

        QQC2.TextField {
            id: widgetTitleField
            Kirigami.FormData.label: "Widget Title:"
            placeholderText: "Pi-hole Status"
            enabled: showTitleCheckbox.checked
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "How to get App Password:"
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: "1. Go to http://your-pihole/admin and login<br>" +
                  "2. Settings → API → Application passwords<br>" +
                  "3. Enter a name and click Generate<br>" +
                  "4. Copy the generated App Password"
            wrapMode: Text.WordWrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }
    }
}
