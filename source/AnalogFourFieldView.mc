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
        drawField(dc, "TopField", centerX, centerY - radius + 20, activityInfo, currentActivity, theme);
        drawField(dc, "RightField", centerX + radius - 34, centerY - 2, activityInfo, currentActivity, theme);
        drawField(dc, "BottomField", centerX, centerY + radius - 24, activityInfo, currentActivity, theme);
        drawField(dc, "LeftField", centerX - radius + 34, centerY - 2, activityInfo, currentActivity, theme);
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
            dc.drawText(x, y, Gfx.FONT_TINY, data[:value], Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        drawFieldIcon(dc, field, x - 20, y + 6, theme, data);
        dc.drawText(x + 12, y, Gfx.FONT_TINY, data[:value], Gfx.TEXT_JUSTIFY_CENTER);
    }

    // Large, literal glyphs (~15-18px) so each field reads clearly at a
    // glance; icons are allowed to sit close to / overlap the watch hands.
    function drawFieldIcon(dc, field, x, y, theme, data) {
        dc.setColor(theme[:accent], Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
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
        dc.fillEllipse(x - 3, y + 4, 6, 8);
        dc.fillEllipse(x + 4, y - 6, 4, 7);
    }

    // Classic heart shape: two lobes plus a triangular point.
    function drawHeartIcon(dc, x, y) {
        dc.fillCircle(x - 4, y - 3, 6);
        dc.fillCircle(x + 4, y - 3, 6);
        dc.fillPolygon([
            [x - 10, y - 1],
            [x + 10, y - 1],
            [x, y + 11]
        ]);
    }

    // Stress "gauge" pictogram: a dial with a needle pointing toward the
    // high end, echoing how Garmin's own stress score is shown as a gauge
    // rather than a heartbeat line (which reads too much like heart rate).
    function drawStressIcon(dc, x, y) {
        var pivotX = x;
        var pivotY = y + 6;
        var dialRadius = 12;

        dc.drawArc(pivotX, pivotY, dialRadius, Gfx.ARC_CLOCKWISE, 205, 335);

        var needleAngle = 55 * Math.PI / 180.0;
        dc.drawLine(pivotX, pivotY,
            pivotX + Math.cos(needleAngle) * (dialRadius - 3),
            pivotY - Math.sin(needleAngle) * (dialRadius - 3));
        dc.fillCircle(pivotX, pivotY, 3);
    }

    // Battery outline with a terminal nub, filled to the current level.
    function drawBatteryIcon(dc, x, y, theme, data) {
        dc.setColor(theme[:foreground], Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRoundedRectangle(x - 11, y - 8, 21, 17, 3);
        dc.fillRectangle(x + 10, y - 4, 3, 8);

        var level = data[:level];
        if (level != null && level > 0) {
            var fillWidth = (15 * level / 100.0).toNumber();
            if (fillWidth < 1) {
                fillWidth = 1;
            }
            dc.setColor(theme[:accent], Gfx.COLOR_TRANSPARENT);
            dc.fillRectangle(x - 8, y - 5, fillWidth, 11);
        }
    }

    // Flame silhouette.
    function drawCaloriesIcon(dc, x, y) {
        dc.fillPolygon([
            [x, y - 11],
            [x + 7, y - 3],
            [x + 6, y + 6],
            [x, y + 11],
            [x - 6, y + 6],
            [x - 7, y - 3]
        ]);
    }

    // Map-pin marker.
    function drawDistanceIcon(dc, x, y, theme) {
        dc.fillCircle(x, y - 3, 8);
        dc.fillPolygon([
            [x - 7, y],
            [x + 7, y],
            [x, y + 13]
        ]);
        dc.setColor(theme[:background], Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(x, y - 3, 3);
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
