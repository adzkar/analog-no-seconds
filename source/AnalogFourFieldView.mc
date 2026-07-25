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

        var backgroundId = Application.Properties.getValue("BackgroundColor");
        var backgroundColor = ColorOptions.colorFor(backgroundId);
        var foregroundColor = ColorOptions.contrastFor(backgroundId);
        var hourColor = ColorOptions.colorFor(Application.Properties.getValue("HourHandColor"));
        var minuteColor = ColorOptions.colorFor(Application.Properties.getValue("MinuteHandColor"));
        var accentColor = ColorOptions.colorFor(Application.Properties.getValue("AccentColor"));

        dc.setColor(backgroundColor, backgroundColor);
        dc.clear();
        drawHands(dc, centerX, centerY, radius, clock.hour, clock.min, hourColor, minuteColor, accentColor);

        var theme = { :foreground => foregroundColor, :accent => accentColor, :background => backgroundColor } as Lang.Dictionary<Lang.Symbol, Lang.Number>;
        drawField(dc, "TopField", centerX, centerY - radius + 17, activityInfo, currentActivity, theme);
        drawField(dc, "RightField", centerX + radius - 30, centerY - 2, activityInfo, currentActivity, theme);
        drawField(dc, "BottomField", centerX, centerY + radius - 21, activityInfo, currentActivity, theme);
        drawField(dc, "LeftField", centerX - radius + 30, centerY - 2, activityInfo, currentActivity, theme);
    }

    function onSettingsChanged() {
        WatchUi.requestUpdate();
    }

    function drawHands(dc, centerX, centerY, radius, hour, minute, hourColor, minuteColor, accentColor) {
        var hourAngle = ((hour % 12) + minute / 60.0) * Math.PI / 6.0 - Math.PI / 2.0;
        var minuteAngle = minute * Math.PI / 30.0 - Math.PI / 2.0;

        dc.setColor(hourColor, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(5);
        dc.drawLine(centerX, centerY, centerX + Math.cos(hourAngle) * radius * 0.45, centerY + Math.sin(hourAngle) * radius * 0.45);
        dc.setColor(minuteColor, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(centerX, centerY, centerX + Math.cos(minuteAngle) * radius * 0.68, centerY + Math.sin(minuteAngle) * radius * 0.68);
        dc.setColor(accentColor, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 4);
    }

    function drawField(dc, propertyKey, x, y, activityInfo, currentActivity, theme) {
        var field = Application.Properties.getValue(propertyKey);
        if (field == null || field == FieldOptions.NONE) {
            return;
        }

        var data = getFieldData(field, activityInfo, currentActivity);
        dc.setColor(theme[:foreground], Gfx.COLOR_TRANSPARENT);
        if (field == 0) {
            dc.drawText(x, y, Gfx.FONT_XTINY, data[:value], Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        drawFieldIcon(dc, field, x - 15, y + 5, theme, data);
        dc.drawText(x + 8, y, Gfx.FONT_XTINY, data[:value], Gfx.TEXT_JUSTIFY_CENTER);
    }

    // Larger, more literal glyphs (~9-10px) so each field reads clearly at a
    // glance; icons are allowed to sit close to / overlap the watch hands.
    function drawFieldIcon(dc, field, x, y, theme, data) {
        dc.setColor(theme[:accent], Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        switch (field) {
            case 1:
                drawStepsIcon(dc, x, y);
                break;
            case 2:
                drawHeartIcon(dc, x, y);
                break;
            case 3:
                drawStressIcon(dc, x, y);
                break;
            case 4:
                drawBatteryIcon(dc, x, y, theme, data);
                break;
            case 5:
                drawCaloriesIcon(dc, x, y);
                break;
            case 6:
                drawDistanceIcon(dc, x, y, theme);
                break;
        }
    }

    // Two overlapping footprint pads.
    function drawStepsIcon(dc, x, y) {
        dc.fillEllipse(x - 2, y + 3, 4, 6);
        dc.fillEllipse(x + 3, y - 4, 3, 5);
    }

    // Classic heart shape: two lobes plus a triangular point.
    function drawHeartIcon(dc, x, y) {
        dc.fillCircle(x - 3, y - 2, 4);
        dc.fillCircle(x + 3, y - 2, 4);
        dc.fillPolygon([
            [x - 7, y - 1],
            [x + 7, y - 1],
            [x, y + 8]
        ]);
    }

    // Pulse / EKG-style zigzag line.
    function drawStressIcon(dc, x, y) {
        dc.drawLine(x - 8, y, x - 4, y);
        dc.drawLine(x - 4, y, x - 2, y - 7);
        dc.drawLine(x - 2, y - 7, x + 1, y + 7);
        dc.drawLine(x + 1, y + 7, x + 3, y);
        dc.drawLine(x + 3, y, x + 8, y);
    }

    // Battery outline with a terminal nub, filled to the current level.
    function drawBatteryIcon(dc, x, y, theme, data) {
        dc.setColor(theme[:foreground], Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(x - 8, y - 6, 15, 12, 2);
        dc.fillRectangle(x + 7, y - 3, 2, 6);

        var level = data[:level];
        if (level != null && level > 0) {
            var fillWidth = (11 * level / 100.0).toNumber();
            if (fillWidth < 1) {
                fillWidth = 1;
            }
            dc.setColor(theme[:accent], Gfx.COLOR_TRANSPARENT);
            dc.fillRectangle(x - 6, y - 4, fillWidth, 8);
        }
    }

    // Flame silhouette.
    function drawCaloriesIcon(dc, x, y) {
        dc.fillPolygon([
            [x, y - 8],
            [x + 5, y - 2],
            [x + 4, y + 4],
            [x, y + 8],
            [x - 4, y + 4],
            [x - 5, y - 2]
        ]);
    }

    // Map-pin marker.
    function drawDistanceIcon(dc, x, y, theme) {
        dc.fillCircle(x, y - 2, 6);
        dc.fillPolygon([
            [x - 5, y],
            [x + 5, y],
            [x, y + 9]
        ]);
        dc.setColor(theme[:background], Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(x, y - 2, 2);
        dc.setColor(theme[:accent], Gfx.COLOR_TRANSPARENT);
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
                var battery = System.getSystemStats().battery;
                return { :value => Lang.format("$1$%", [battery.toNumber()]), :level => battery };
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
