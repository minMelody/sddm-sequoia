import QtQuick 2.15
import QtQuick.Controls 2.15

Column {
  property int fontSize: root.font.pointSize * 2
  property date value: new Date()

  spacing: -fontSize / 2

  Label {
    id: time_label
    visible: true

    anchors.right: parent.right

    renderType: Text.QtRendering
    color: config.clockStyle == "outline" ? "transparent" : root.theme.primary
    style: config.clockStyle == "outline" ? Text.Outline  : Text.Normal
    styleColor: root.theme.primary
    font.pointSize: fontSize * 2.5

    function update() {
      text = Qt.formatTime(value, config.clockFormat)
    }
  }

  Label {
    id: date_label

    anchors.right: parent.right

    renderType: Text.QtRendering
    color: root.theme.primary
    font.pointSize: fontSize

    function update() {
      text = Qt.formatDateTime(value, config.dateFormat)
    }
  }

  Timer {
    interval: 1000
    repeat: true
    running: true
    onTriggered: {
      value = new Date()
      time_label.update()
      date_label.update()
    }
  }

  Component.onCompleted: {
    time_label.update()
    date_label.update()
  }
}
