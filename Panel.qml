import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.cytracon.tilix"
  ipcTarget: "io.github.cytracon.tilix"
  manageIpc: false

  readonly property string shippedVersion: "1.9.8-cytracon.12"
  readonly property string sourceUrl: "https://github.com/cytracon/tilix"
  readonly property string tilixBin: Quickshell.env("HOME") + "/.local/bin/tilix"
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  property bool installed: false
  property string liveVersion: ""
  property string liveVte: ""
  property string liveGtk: ""
  property int actionIndex: 0
  property bool cursorActive: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    cursorActive = false
    actionIndex = 0
    refreshVersion()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function refreshVersion() {
    versionProc.running = false
    versionProc.running = true
  }

  function parseVersion(raw) {
    var text = String(raw || "")
    root.installed = text.indexOf("Tilix version:") >= 0
    root.liveVersion = capture(text, /Tilix version:\s*(.+)/)
    root.liveVte = capture(text, /VTE version:\s*(.+)/)
    root.liveGtk = capture(text, /GTK Version:\s*(.+)/)
  }

  function capture(text, re) {
    var m = String(text || "").match(re)
    return m ? String(m[1]).trim() : ""
  }

  function launchTilix() {
    if (!root.installed) {
      installApp()
      return
    }
    Quickshell.execDetached([root.tilixBin])
    root.close()
  }

  function installApp() {
    Quickshell.execDetached([
      "omarchy-launch-floating-terminal-with-presentation",
      "omarchy", "install", "tilix"
    ])
    root.close()
  }

  function openSource() {
    Quickshell.execDetached(["omarchy-launch-browser", root.sourceUrl])
    root.close()
  }

  function activateCursor() {
    if (actionIndex === 0) launchTilix()
    else openSource()
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function launch(): void { root.launchTilix() }
  }

  Process {
    id: versionProc
    command: [root.tilixBin, "--version"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseVersion(text)
    }
    onExited: function(code) {
      if (code !== 0) {
        root.installed = false
        root.liveVersion = ""
        root.liveVte = ""
        root.liveGtk = ""
      }
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "T"
    tooltipText: "Tilix (Cytracon)"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.launchTilix()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(420))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        root.cursorActive = true
        if (dy !== 0) root.actionIndex = dy > 0 ? 1 : 0
      }
      onActivateRequested: root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) {
        if (root.bar && typeof root.bar.switchPanelFrom === "function")
          root.bar.switchPanelFrom(root, direction)
      }
      onTextKey: function(t) {
        if (t === "o" || t === "O") root.launchTilix()
        else if (t === "i" || t === "I") root.installApp()
        else if (t === "s" || t === "S") root.openSource()
      }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(12)

        PanelHero {
          width: parent.width
          title: "Tilix (Cytracon)"
          meta: root.installed ? (root.liveVersion || root.shippedVersion) : "Not installed in ~/.local"
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        Column {
          width: parent.width
          spacing: Style.spacing.labelGap
          InfoPair { label: "Shipped"; value: root.shippedVersion }
          InfoPair { label: "Installed"; value: root.installed ? (root.liveVersion || "yes") : "no" }
          InfoPair { label: "VTE"; value: root.liveVte || "0.84" }
          InfoPair { label: "GTK"; value: root.liveGtk || "3.24" }
          InfoPair { label: "Session"; value: "Wayland, tiled" }
          InfoPair { label: "AI Tools"; value: "Grok, Codex, Example" }
        }

        PanelSeparator { foreground: root.foreground }

        ActionRow {
          width: parent.width
          title: root.installed ? "Open Tilix" : "Install Tilix"
          hint: root.installed ? "Right-click the bar icon, or press O" : "Installs the terminal. Press I"
          selected: root.cursorActive && root.actionIndex === 0
          enabled: true
          onClicked: root.launchTilix()
        }

        ActionRow {
          width: parent.width
          title: "Source"
          hint: "github.com/cytracon/tilix"
          selected: root.cursorActive && root.actionIndex === 1
          enabled: true
          onClicked: root.openSource()
        }
      }
    }
  }

  component InfoPair: Row {
    property string label: ""
    property string value: ""
    width: parent.width
    spacing: Style.space(8)
    Text {
      textFormat: Text.PlainText
      text: label
      color: root.foreground
      opacity: 0.6
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }
    Item {
      width: Math.max(0, parent.width - parent.children[0].implicitWidth - parent.children[2].implicitWidth - parent.spacing * 2)
      height: 1
    }
    Text {
      textFormat: Text.PlainText
      text: value
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }
  }

  component ActionRow: CursorSurface {
    id: action
    property string title: ""
    property string hint: ""
    property bool selected: false
    property bool enabled: true
    signal clicked()

    hasCursor: selected
    foreground: root.foreground
    implicitHeight: actionColumn.implicitHeight + Style.spacing.rowPaddingX
    opacity: enabled ? 1 : 0.55

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      enabled: action.enabled
      cursorShape: action.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
      onClicked: action.clicked()
    }

    Column {
      id: actionColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(2)
      Text {
        textFormat: Text.PlainText
        width: parent.width
        text: action.title
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
      }
      Text {
        textFormat: Text.PlainText
        width: parent.width
        text: action.hint
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }
    }
  }
}
