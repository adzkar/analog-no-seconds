using Toybox.Application;
using Toybox.WatchUi;

class AnalogFourFieldApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new AnalogFourFieldView()];
    }

    // Backs the on-device "Customize" prompt shown after selecting the
    // watch face; without this the watch only offers "Apply".
    function getSettingsView() {
        var menu = new SettingsMenu();
        return [menu, new SettingsMenuDelegate(menu)];
    }
}

function getApp() {
    return Application.getApp();
}
