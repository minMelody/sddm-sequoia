import QtQuick 2.15
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.15

import "common"

ComboBox {
  id: container
  property int fontSize: root.font.pointSize * 0.875
  property int screenPadding: parent.Layout.margins
  background: null

  property bool vkbd_enabled: false
  function keyboardStatusChanged(state: int) {
    vkbd_enabled = state == Loader.Ready
  }

  indicator: Button {
    anchors.fill: parent
    Text {
      anchors.centerIn: parent
      renderType: Text.QtRendering
      text: ""
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
    if (currentIndex == 0) root.activateVirtualKeyboard = !root.activateVirtualKeyboard;
  }

  readonly property var vkbd_toggle: {'icon': "", 'label': config.virtualKeyboard || "Virtual keyboard", 'enabled': vkbd_enabled}

  model: [vkbd_toggle]
  onActivated: {
    currentIndex = highlightedIndex;
    actionPressed();
  }
  delegate: RowLayout {
    Layout.fillWidth: true
    Layout.preferredHeight: fontSize * 3

    spacing: fontSize
    Layout.leftMargin: 10
    Layout.rightMargin: 10

    Text {
      visible: config.boolValue("iconsInMenus")
      renderType: Text.QtRendering
      text: modelData['icon']
      font.pointSize: fontSize
      font.family: config.iconFont
      color: root.theme.foreground
    }

    Text {
      id: label
      renderType: Text.QtRendering
      text: modelData['label']
      font.pointSize: fontSize
      color: root.theme.foreground
      Layout.fillWidth: true
    }

    Switch {
      id: toggle
      state: enabled ? "" : "disabled"
      Layout.preferredHeight: indicator.implicitHeight + 10
      Layout.preferredWidth: indicator.implicitWidth + 10
      Layout.fillWidth: false

      checked: root.activateVirtualKeyboard
      onClicked: {
        container.currentIndex = index
        container.actionPressed()
      }

      background: Rectangle {
        color: "transparent"
        radius: 8
      }

      indicator: Rectangle {
        anchors.centerIn: parent
        implicitHeight: fontSize * 1.5
        implicitWidth: fontSize * 3
        radius: implicitHeight / 2
        color: parent.checked ? root.theme.accent : Qt.darker(root.theme.background, 1.3)
        border.color: parent.checked ? root.theme.accent : "#cccccc"

        Rectangle {
          id: knob
          x: toggle.checked ? parent.width - width : 0
          height: parent.implicitHeight
          width: height
          radius: height / 2
          color: toggle.down ? "#cccccc" : root.theme.foreground
          border.color: toggle.checked ? root.theme.accent : "#999999"
        }
      }
      states: [
        State {
          name: "disabled"
          when: !container.vkbd_enabled
          PropertyChanges {
            target: toggle.indicator
            color: "#555555"
            border.color: "#333333"
            opacity: 0.3
          }
          PropertyChanges {
            target: knob
            x: 0
            color: "#cccccc"
            border.color: Qt.lighter(toggle.indicator.color, 1.5)
          }
        }
      ]

    }

  }

  popup: PopupPanel {
    y: -height
    x: root.LayoutMirroring.enabled ? -parent.width : (2 * parent.width - width)

    model: container.delegateModel
  }

}
