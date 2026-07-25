using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

class AnalogFourFieldView extends WatchUi.WatchFace {
    const BACKGROUND_COLOR = Gfx.COLOR_BLACK;
    const PRIMARY_COLOR = Gfx.COLOR_WHITE;
    const SECONDARY_COLOR = Gfx.COLOR_LT_GRAY;
    const ACCENT_COLOR = Gfx.COLOR_CYAN;

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        var radius = (width < height ? width : height) / 2 - 8;
        var clock = System.getClockTime();
        var activityInfo = ActivityMonitor.getInfo();
        var currentActivity = Activity.getActivityInfo();

        dc.setColor(BACKGROUND_COLOR, BACKGROUND_COLOR);
        dc.clear();
        drawDial(dc, centerX, centerY, radius);
        drawHands(dc, centerX, centerY, radius, clock.hour, clock.min);
        drawField(dc, "TopField", centerX, centerY - radius + 17, activityInfo, currentActivity);
        drawField(dc, "RightField", centerX + radius - 31, centerY - 8, activityInfo, currentActivity);
        drawField(dc, "BottomField", centerX, centerY + radius - 34, activityInfo, currentActivity);
        drawField(dc, "LeftField", centerX - radius + 31, centerY - 8, activityInfo, currentActivity);
    }

    function onSettingsChanged() {
        WatchUi.requestUpdate();
    }

    function drawDial(dc, centerX, centerY, radius) {
        dc.setColor(PRIMARY_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(centerX, centerY, radius);

        for (var mark = 0; mark < 12; mark += 1) {
            var angle = mark * Math.PI / 6.0 - Math.PI / 2.0;
            var outerX = centerX + Math.cos(angle) * (radius - 4);
            var outerY = centerY + Math.sin(angle) * (radius - 4);
            var innerX = centerX + Math.cos(angle) * (radius - 10);
            var innerY = centerY + Math.sin(angle) * (radius - 10);
            dc.drawLine(outerX, outerY, innerX, innerY);
        }
    }

    function drawHands(dc, centerX, centerY, radius, hour, minute) {
        var hourAngle = ((hour % 12) + minute / 60.0) * Math.PI / 6.0 - Math.PI / 2.0;
        var minuteAngle = minute * Math.PI / 30.0 - Math.PI / 2.0;

        dc.setColor(PRIMARY_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(5);
        dc.drawLine(centerX, centerY, centerX + Math.cos(hourAngle) * radius * 0.45, centerY + Math.sin(hourAngle) * radius * 0.45);
        dc.setPenWidth(3);
        dc.drawLine(centerX, centerY, centerX + Math.cos(minuteAngle) * radius * 0.68, centerY + Math.sin(minuteAngle) * radius * 0.68);
        dc.setColor(ACCENT_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 4);
    }

    function drawField(dc, propertyKey, x, y, activityInfo, currentActivity) {
        var field = Application.Properties.getValue(propertyKey);
        var data = getFieldData(field, activityInfo, currentActivity);

        dc.setColor(SECONDARY_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_XTINY, data[:label], Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(PRIMARY_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y + 12, Gfx.FONT_SMALL, data[:value], Gfx.TEXT_JUSTIFY_CENTER);
    }

    function getFieldData(field, activityInfo, currentActivity) {
        switch (field) {
            case 0:
                var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
                return { :label => "DATE", :value => Lang.format("$1$/$2$", [date.day, date.month]) };
            case 1:
                return { :label => "STEPS", :value => displayValue(activityInfo.steps) };
            case 2:
                return { :label => "HEART", :value => displayValue(currentActivity.currentHeartRate) };
            case 3:
                return { :label => "STRESS", :value => displayValue(activityInfo.stressScore) };
            case 4:
                return { :label => "BATTERY", :value => Lang.format("$1$%", [System.getSystemStats().battery]) };
            case 5:
                return { :label => "CAL", :value => displayValue(activityInfo.calories) };
            case 6:
                if (activityInfo.distance == null) {
                    return { :label => "DIST", :value => "--" };
                }
                return { :label => "DIST", :value => Lang.format("$1$ km", [activityInfo.distance / 1000.0]) };
            default:
                return { :label => "", :value => "--" };
        }
    }

    function displayValue(value) {
        return value == null ? "--" : value.toString();
    }
}
