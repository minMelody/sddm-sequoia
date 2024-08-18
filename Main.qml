import QtQuick 2.15
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12
import SddmComponents 2.0 as SDDM

import "components"
import "components/common"

Pane {
  id: root
  SDDM.TextConstants {id: text_const}

  readonly property ColourPalette theme: ColourPalette {
    primary: config.primaryColour || "white"
    background: config.popupsBackgroundColour || "#2a2a2a"
    foreground: config.popupsForegroundColour || "white"
    accent: config.accentColour
  }

  height: config.height
  width: config.width
  padding: 0

  readonly property int verticalThird: height * 0.33
  readonly property int horizontalThird: width * 0.33

  LayoutMirroring.enabled: config.mirrorLayout == "auto" ? Qt.locale().textDirection == Qt.RightToLeft : config.boolValue("mirrorLayout")
  LayoutMirroring.childrenInherit: true

  property bool activateVirtualKeyboard: config.boolValue("virtualKeyboardStartActive")

  font.family: config.fontFamily
  font.pointSize: config.fontSize || (height / 65)
  property string iconFont: config.iconFont || config.fontFamily

  background: Rectangle {
    height: root.height
    width: root.width
    color: config.backgroundColour

    Image {
      id: wallpaper

      height: root.height
      width: root.width

      source: config.wallpaper
      fillMode: config.boolValue("fitWallpaper") ? Image.PreserveAspectFit : Image.PreserveAspectCrop

      asynchronous: true
      cache: true
      clip: true

      RecursiveBlur {
        visible: false
        id: blur_wallpaper
        anchors.fill: wallpaper
        source: wallpaper
        radius: config.blurRadius
        loops: config.blurRecursiveLoops
      }
    }
    Rectangle {
      id: darken_wallpaper
      anchors.fill: parent
      color: "black"
      opacity: 0
    }
  }

  Item {
    id: greeter
    visible: true
    anchors.fill: parent
    anchors.rightMargin: -anchors.leftMargin

    Clock {
      id: datetime

      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: 55
    }

    Label {
      anchors.centerIn: parent

      color: root.theme.primary
      font.pointSize: datetime.fontSize

      renderType: Text.QtRendering
      text: config.greeting
      textFormat: Text.MarkdownText
      horizontalAlignment: Text.AlignHCenter
    }

    TapHandler {
      id: tap_handler
      enabled: parent.visible
      onTapped: gotoLogin()
    }
  }

  ColumnLayout {
    id: login_page
    visible: false

    anchors.fill: parent
    width: parent.width

    spacing: 0

    Item {
      id: login_container
      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.leftMargin: horizontalThird * 0.75
      Layout.rightMargin: horizontalThird * 0.75
      Layout.topMargin: 16

      LoginForm {
        id: login_form

        anchors.centerIn: parent

        onLoginRequest: login_form.login(session.currentIndex);
        KeyNavigation.down: session
      }
    }

    RowLayout {
      id: footer

      Layout.margins: root.font.pointSize
      Layout.fillHeight: false
      Layout.preferredHeight: 36
      Layout.preferredWidth: root.width

      spacing: Layout.margins * 0.5

      SessionSelection {
        id: session
        Layout.preferredHeight: parent.Layout.preferredHeight
        Layout.preferredWidth: Layout.preferredHeight

        KeyNavigation.right: layout
        KeyNavigation.tab: KeyNavigation.right
      }

      Rectangle { // spacer
        Layout.fillWidth: true
      }

      LayoutSelection {
        id: layout
        Layout.preferredHeight: parent.Layout.preferredHeight
        Layout.preferredWidth: Layout.preferredHeight

        KeyNavigation.left: session
        KeyNavigation.right: accessibility
        KeyNavigation.tab: KeyNavigation.right
      }

      AccessibilityMenu {
        id: accessibility
        Layout.preferredHeight: parent.Layout.preferredHeight
        Layout.preferredWidth: Layout.preferredHeight

        KeyNavigation.left: layout
        KeyNavigation.right: power
        KeyNavigation.tab: KeyNavigation.right
      }

      PowerMenu {
        id: power
        Layout.preferredHeight: parent.Layout.preferredHeight
        Layout.preferredWidth: Layout.preferredHeight

        forcePowerOptions: true
        KeyNavigation.left: accessibility
      }
    }

    Rectangle {
      width: parent.width
      implicitHeight: virtual_keyboard.implicitHeight
      color: "transparent"

      Loader {
        id: virtual_keyboard

        width: parent.width
        z: 1

        source: "components/VirtualKeyboard.qml"
        asynchronous: true

        onStatusChanged: accessibility.keyboardStatusChanged(status)
      }
    }
  }

  focus: true
  Keys.onReleased: {
    if (state == "") gotoLogin()
  }
  function gotoLogin() {
    root.state = "loginForm"
  }

  states: State {
    name: "loginForm"
    when: config.boolValue("skipToLogin")
    PropertyChanges {
      target: darken_wallpaper
      opacity: config.darkenWallpaper
    }
    PropertyChanges {
      target: blur_wallpaper
      visible: true
    }
  }

  transitions: Transition {
    to: "loginForm"
    SequentialAnimation {
      ParallelAnimation {
        NumberAnimation {
          target: greeter
          property: "opacity"
          from: 1; to: 0
          duration: 100 * config.boolValue("enableAnimations")
        }
        NumberAnimation {
          target: greeter
          property: "anchors.leftMargin"
          from: 0; to: root.horizontalThird
          duration: 100 * config.boolValue("enableAnimations")
        }
      }

      ScriptAction {
        script: {
          greeter.visible = false;
          login_page.visible = true;
        }
      }
      NumberAnimation {
        target: login_page
        property: "opacity"
        from: 0; to: 1
        duration: 50 * config.boolValue("enableAnimations")
      }
    }
  }

  Connections {
    target: sddm
    function onLoginSucceeded() {}
    function onLoginFailed() {
      login_form.loginFailed();
    }
  }
}
