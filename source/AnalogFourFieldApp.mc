using Toybox.Application;
using Toybox.WatchUi;

class AnalogFourFieldApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new AnalogFourFieldView()];
    }
}

function getApp() {
    return Application.getApp();
}
