import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

ColumnLayout {
    id: configGeneral
    
    property alias cfg_piholeHost: piholeHostField.text
    property alias cfg_piholeApiKey: apiKeyField.text
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_widgetTitle: widgetTitleField.text
    property alias cfg_showTitle: showTitleCheckbox.checked

    Kirigami.FormLayout {
        Layout.fillWidth: true
        
        QQC2.TextField {
            id: piholeHostField
            Kirigami.FormData.label: "Pi-hole IP Address:"
            placeholderText: "e.g., 192.168.1.100"
        }

        QQC2.TextField {
            id: apiKeyField
            Kirigami.FormData.label: "App Password / API Key:"
            placeholderText: "Your Pi-hole App Password"
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
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            QQC2.Label {
                text: "How to get your App Password / API Key:"
                font.bold: true
            }
            
            QQC2.Label {
                text: "<b>For Pi-hole v6.0+:</b><br>" +
                      "1. Open http://your-pi-hole/admin and login<br>" +
                      "2. Go to <b>Settings</b><br>" +
                      "3. Scroll to <b>API</b> section<br>" +
                      "4. Under 'Application passwords', enter a name (e.g., 'Plasma Widget')<br>" +
                      "5. Click <b>Generate</b> or <b>Add</b><br>" +
                      "6. Copy the generated App Password<br><br>" +
                      "<b>For Pi-hole v5.x:</b><br>" +
                      "1. Open http://your-pi-hole/admin<br>" +
                      "2. Go to <b>Settings → API</b><br>" +
                      "3. Click <b>Show API token</b><br>" +
                      "4. Copy the API token"
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }
        }
    }
    
    Item {
        Layout.fillHeight: true
    }
}
