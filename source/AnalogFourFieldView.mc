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
    const ACCENT_COLOR = Gfx.COLOR_BLUE;

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
        drawHands(dc, centerX, centerY, radius, clock.hour, clock.min);
        drawField(dc, "TopField", centerX, centerY - radius + 15, activityInfo, currentActivity);
        drawField(dc, "RightField", centerX + radius - 28, centerY - 4, activityInfo, currentActivity);
        drawField(dc, "BottomField", centerX, centerY + radius - 23, activityInfo, currentActivity);
        drawField(dc, "LeftField", centerX - radius + 28, centerY - 4, activityInfo, currentActivity);
    }

    function onSettingsChanged() {
        WatchUi.requestUpdate();
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
        if (field == null || field == 7) {
            return;
        }

        var data = getFieldData(field, activityInfo, currentActivity);
        dc.setColor(PRIMARY_COLOR, Gfx.COLOR_TRANSPARENT);
        if (field == 0) {
            dc.drawText(x, y, Gfx.FONT_XTINY, data[:value], Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        drawFieldIcon(dc, field, x - 11, y + 5);
        dc.drawText(x + 5, y, Gfx.FONT_XTINY, data[:value], Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawFieldIcon(dc, field, x, y) {
        dc.setColor(PRIMARY_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        switch (field) {
            case 1:
                dc.fillCircle(x - 2, y - 3, 2);
                dc.fillCircle(x + 2, y + 3, 2);
                break;
            case 2:
                dc.drawLine(x - 5, y - 1, x - 2, y - 4);
                dc.drawLine(x - 2, y - 4, x, y - 1);
                dc.drawLine(x, y - 1, x + 2, y - 4);
                dc.drawLine(x + 2, y - 4, x + 5, y - 1);
                dc.drawLine(x + 5, y - 1, x, y + 5);
                dc.drawLine(x, y + 5, x - 5, y - 1);
                break;
            case 3:
                dc.drawLine(x - 5, y + 2, x - 2, y - 3);
                dc.drawLine(x - 2, y - 3, x + 1, y + 2);
                dc.drawLine(x + 1, y + 2, x + 5, y - 3);
                break;
            case 4:
                dc.drawRectangle(x - 5, y - 4, 9, 8);
                dc.fillRectangle(x + 4, y - 2, 2, 4);
                dc.fillRectangle(x - 3, y - 2, 4, 4);
                break;
            case 5:
                dc.drawLine(x, y - 5, x - 3, y);
                dc.drawLine(x - 3, y, x, y + 5);
                dc.drawLine(x, y + 5, x + 3, y);
                dc.drawLine(x + 3, y, x, y - 5);
                break;
            case 6:
                dc.drawCircle(x, y - 2, 3);
                dc.drawLine(x - 2, y, x, y + 5);
                dc.drawLine(x, y + 5, x + 2, y);
                break;
        }
    }

    function getFieldData(field, activityInfo, currentActivity) {
        switch (field) {
            case 0:
                var date = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
                return { :value => Lang.format("$1$ $2$", [date.day_of_week, date.day]) };
            case 1:
                return { :value => displayValue(activityInfo.steps) };
            case 2:
                return { :value => displayValue(currentActivity.currentHeartRate) };
            case 3:
                return { :value => displayValue(activityInfo.stressScore) };
            case 4:
                return { :value => Lang.format("$1$%", [System.getSystemStats().battery]) };
            case 5:
                return { :value => displayValue(activityInfo.calories) };
            case 6:
                if (activityInfo.distance == null) {
                    return { :value => "--" };
                }
                return { :value => Lang.format("$1$ km", [activityInfo.distance / 1000.0]) };
            default:
                return { :value => "--" };
        }
    }

    function displayValue(value) {
        return value == null ? "--" : value.toString();
    }
}
