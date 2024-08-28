import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "common"

Column {
  id: container
  property int fontSize: root.font.pointSize * 0.75

  signal loginRequest()
  function login(session: int) {
    sddm.login(username.text, password.text, session);
  }

  function loginFailed() {
    notification.opacity = 1;
    password.text = ""
    if (notification_timeout.running) notification_timeout.stop();
    notification_timeout.start();
  }

  width: parent.width

  TextField {
    id: username
    width: parent.width * 0.5
    anchors.horizontalCenter: parent.horizontalCenter

    UserList {
      id: user_list
      height: parent.height
      width: height

      fontSize: container.fontSize

      onUserSelected: {
        username.text = currentText;
        password.forceActiveFocus();
      }
    }

    onVisibleChanged: { if (visible && text.length == 0) forceActiveFocus(); }

    text: user_list.currentText

    placeholderText: config.username || qsTr(text_const.userName)
    placeholderTextColor: Qt.lighter(root.theme.primary, 0.6)
    horizontalAlignment: Text.AlignHCenter
    selectByMouse: true

    renderType: Text.QtRendering
    font.pointSize: fontSize * 1.5
    font.bold: true
    font.capitalization: config.boolValue("capitaliseUsername") ? Font.Capitalize : Font.MixedCase
    color: root.theme.primary

    onAccepted: password.forceActiveFocus()
    KeyNavigation.down: password
    KeyNavigation.left: user_list
    KeyNavigation.backtab: user_list
    KeyNavigation.tab: password

    background: null
  }

  RowLayout {
    anchors.horizontalCenter: username.horizontalCenter
    width: username.width

    TextField {
      id: password
      Layout.fillWidth: true

      onVisibleChanged: { if (visible && username.text.length > 0) forceActiveFocus(); }

      placeholderText: config.password || qsTr(text_const.password)
      placeholderTextColor: Qt.lighter(root.theme.primary, 0.6)
      horizontalAlignment: Text.AlignHCenter
      selectByMouse: true
      echoMode: config.passwordEchoStyle == "off" ? TextInput.NoEcho : TextInput.Password

      renderType: Text.QtRendering
      font.pointSize: fontSize
      color: root.theme.primary
      passwordCharacter: "•"

      onAccepted: {focus = false; loginRequest()}
      KeyNavigation.right: login_button

      background: Rectangle {
        color: "transparent"
        radius: 8
        border.color: parent.focus ? root.theme.accent : root.theme.primary
        border.width: 1
      }

      Text {
        height: parent.height
        width: height * 1.2

        opacity: keyboard.capsLock

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        renderType: Text.QtRendering
        text: "󰪛"
        font.family: iconFont
        color: root.theme.primary
        font.pointSize: fontSize * 1.4

        Behavior on opacity {
          NumberAnimation { duration: 100 * config.boolValue("enableAnimations") }
        }
      }
    }

    Button {
      id: login_button
      visible: username.text.length > 0 && (config.boolValue("allowEmptyPassword") || (password.text.length > 0))
      implicitHeight: password.height
      Layout.fillWidth: false
      Layout.preferredWidth: implicitHeight

      Text {
        id: icon
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        renderType: Text.QtRendering
        font.pointSize: fontSize * 1.4
        font.family: iconFont
        color: login_button.focus ? root.theme.accent : root.theme.primary
        text: LayoutMirroring.enabled ? "" : ""
      }

      onClicked: loginRequest()
      KeyNavigation.left: password

      background: Rectangle {
        color: "transparent"
        radius: 8
        border.color: parent.focus? root.theme.accent : root.theme.primary
        border.width: 1
      }

      states: [
        State {
          name: "selected"
          when: login_button.pressed
          PropertyChanges {
            target: login_button.background
            color: root.theme.accent
            border.color: root.theme.primary
          }
          PropertyChanges {
            target: icon
            color: root.theme.primary
          }
        }
      ]

    }

  }

  Text {
    id: notification
    text: config.loginFailed || qsTr(text_const.loginFailed)
    opacity: 0

    renderType: Text.QtRendering
    color: root.theme.accent
    font.pointSize: fontSize
    height: fontSize * 3
    verticalAlignment: Qt.AlignVCenter

    anchors.horizontalCenter: parent.horizontalCenter

    Behavior on opacity {
      NumberAnimation { duration: 100 * config.boolValue("enableAnimations") }
    }

    Timer {
      id: notification_timeout
      running: false
      interval: 2500
      onTriggered: notification.opacity = 0
    }
  }
}
