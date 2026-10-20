// Dev container smoke test: opens a Qt Quick window, logs the platform and graphics API, quits.
// Host display:  redux/dev.sh run qml6 redux/tools/smoke.qml
// Headless:      redux/dev.sh run env QT_QPA_PLATFORM=xcb xvfb-run -a qml6 redux/tools/smoke.qml
import QtQuick
import QtQuick.Window

Window {
    width: 480; height: 160; visible: true; color: "#111111"
    title: "Redux Video Player dev container smoke test"

    readonly property var apiNames: ["Unknown", "Software", "OpenVG", "OpenGL", "Direct3D 11", "Vulkan", "Metal", "Null", "Direct3D 12"]
    readonly property string api: apiNames[label.GraphicsInfo.api] ?? "?"

    Text {
        id: label
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        color: "#f08a24"; font.pixelSize: 22
        text: "Redux Video Player container OK\n" + api + " on " + Qt.platform.pluginName
    }

    Timer {
        interval: 1500; running: true
        onTriggered: { console.log("platform=" + Qt.platform.pluginName + " graphicsApi=" + api); Qt.quit() }
    }
}
