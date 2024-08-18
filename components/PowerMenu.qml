import QtQuick 2.15
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.15

import "common"

ComboBox {
  id: container
  property int fontSize: root.font.pointSize * 0.875
  property int screenPadding: parent.Layout.margins
  background: null

  indicator: Button {
    anchors.fill: parent
    Text {
      anchors.centerIn: parent
      renderType: Text.QtRendering
      text: "󰐥"
      font.family: iconFont
      color: container.focus ? root.theme.accent : root.theme.primary
      font.pointSize: fontSize * 1.5
    }

    background: Rectangle {
      color: "transparent"
    }

    onPressed: {
      container.popup.open()
    }

  }

  function actionPressed() {
    if (currentIndex == 0) sddm.suspend();
    else if (currentIndex == 1) sddm.hibernate();
    else if (currentIndex == 2) sddm.reboot();
    else if (currentIndex == 3) sddm.powerOff();
  }

  property bool forcePowerOptions: false
  readonly property var action_poweroff:  {'icon': "", 'label': config.poweroff  || qsTr(text_const.shutdown ), 'enabled': sddm.canPowerOff }
  readonly property var action_reboot:    {'icon': "", 'label': config.reboot    || qsTr(text_const.reboot   ), 'enabled': sddm.canReboot   }
  readonly property var action_suspend:   {'icon': "", 'label': config.suspend   || qsTr(text_const.suspend  ), 'enabled': sddm.canSuspend  }
  readonly property var action_hibernate: {'icon': "󰍷", 'label': config.hibernate || qsTr(text_const.hibernate), 'enabled': sddm.canHibernate}

  model: [action_suspend, action_hibernate, action_reboot, action_poweroff]
  onActivated: {
    currentIndex = highlightedIndex;
    actionPressed();
  }

  delegate: ItemDelegate {
    id: power_option
    visible: forcePowerOptions || modelData['enabled']

    implicitHeight: fontSize * 3
    implicitWidth: content_item.width
    Layout.fillWidth: true

    Row {
      id: content_item
      spacing: fontSize
      anchors.verticalCenter: power_option.verticalCenter
      leftPadding: 10
      rightPadding: 10
      Text {
        visible: config.boolValue("iconsInMenus")
        renderType: Text.QtRendering
        text: modelData['icon']
        font.family: iconFont
        font.pointSize: fontSize
        color: root.theme.foreground
      }
      Text {
        id: label
        renderType: Text.QtRendering
        text: modelData['label']
        font.pointSize: fontSize
        color: root.theme.foreground
      }
    }
    onClicked: {
      currentIndex = index;
    }

    background: Rectangle {
      color: "transparent"
    }

    states: [
      State {
        name: "selected"
        when: power_option.activeFocus
        PropertyChanges {
          target: power_option.background
          color: root.theme.accent
        }
      },
      State {
        name: "highlighted"
        when: container.highlightedIndex === index
        PropertyChanges {
          target: power_option.background
          color: "#777777"
          opacity: 0.4
        }
      }
    ]

  }

  popup: PopupPanel {
    y: -(height + screenPadding)
    x: root.LayoutMirroring.enabled ? -screenPadding * 0.5 : (parent.width - width + screenPadding * 0.5)
    interactive: false

    model: container.delegateModel
  }

}
