using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.Math;
using Toybox.SensorHistory;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.UserProfile;
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
        // Center both the icon and the text on the same y so they always
        // line up, regardless of which field/watch hand is nearby.
        var justify = Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER;
        dc.setColor(theme[:foreground], Gfx.COLOR_TRANSPARENT);
        if (field == 0) {
            dc.drawText(x, y, Gfx.FONT_TINY, data[:value], justify);
            return;
        }

        drawFieldIcon(dc, field, x - 20, y, theme, data);
        dc.drawText(x + 12, y, Gfx.FONT_TINY, data[:value], justify);
    }

    // Large, literal glyphs (~16-20px) so each field reads clearly at a
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
                drawCaloriesIcon(dc, x, y, theme);
                break;
            case 6:
                drawStairsIcon(dc, x, y);
                break;
            case 7:
                drawVo2MaxIcon(dc, x, y);
                break;
            case 8:
                drawBodyBatteryIcon(dc, x, y);
                break;
        }
    }

    // Footprint: a single sole pad plus a small arc of toe dots.
    function drawStepsIcon(dc, x, y) {
        dc.fillEllipse(x, y + 3, 6, 9);
        dc.fillCircle(x - 5, y - 8, 2);
        dc.fillCircle(x - 2, y - 10, 2);
        dc.fillCircle(x + 2, y - 10, 2);
        dc.fillCircle(x + 5, y - 8, 2);
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

    // Sweat drop: rounded base with a pointed top, a common "tension" glyph
    // that reads clearly at small sizes and does not resemble heart rate.
    function drawStressIcon(dc, x, y) {
        dc.fillCircle(x, y + 3, 7);
        dc.fillPolygon([
            [x - 6, y - 1],
            [x + 6, y - 1],
            [x, y - 12]
        ]);
    }

    // Battery outline with a terminal nub, filled to the current level.
    // The fill is inset a fixed amount from the outline on every side so it
    // always sits centered inside the rounded corners.
    function drawBatteryIcon(dc, x, y, theme, data) {
        var bodyLeft = x - 11;
        var bodyTop = y - 7;
        var bodyWidth = 20;
        var bodyHeight = 14;
        var inset = 3;

        dc.setColor(theme[:foreground], Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(bodyLeft, bodyTop, bodyWidth, bodyHeight, 3);
        dc.fillRectangle(bodyLeft + bodyWidth, y - 3, 3, 6);

        var level = data[:level];
        if (level != null && level > 0) {
            var maxFillWidth = bodyWidth - (inset * 2);
            var fillWidth = (maxFillWidth * level / 100.0).toNumber();
            if (fillWidth < 2) {
                fillWidth = 2;
            }
            dc.setColor(theme[:accent], Gfx.COLOR_TRANSPARENT);
            dc.fillRectangle(bodyLeft + inset, bodyTop + inset, fillWidth, bodyHeight - (inset * 2));
        }
    }

    // Two-tone flame: a larger silhouette with a smaller cutout near the
    // base (punched through in the background color) for a classic
    // "fire" look instead of a plain diamond.
    function drawCaloriesIcon(dc, x, y, theme) {
        dc.fillPolygon([
            [x, y - 12],
            [x + 6, y - 2],
            [x + 5, y + 7],
            [x, y + 12],
            [x - 5, y + 7],
            [x - 6, y - 2]
        ]);
        dc.setColor(theme[:background], Gfx.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [x, y - 2],
            [x + 3, y + 3],
            [x, y + 8],
            [x - 3, y + 3]
        ]);
        dc.setColor(theme[:accent], Gfx.COLOR_TRANSPARENT);
    }

    // Ascending staircase.
    function drawStairsIcon(dc, x, y) {
        dc.fillRectangle(x - 9, y + 3, 6, 6);
        dc.fillRectangle(x - 2, y - 3, 6, 12);
        dc.fillRectangle(x + 5, y - 9, 6, 18);
    }

    // "Max capacity" glyph: an up arrow inside a ring.
    function drawVo2MaxIcon(dc, x, y) {
        dc.drawCircle(x, y, 10);
        dc.fillPolygon([
            [x, y - 6],
            [x + 5, y + 1],
            [x + 2, y + 1],
            [x + 2, y + 7],
            [x - 2, y + 7],
            [x - 2, y + 1],
            [x - 5, y + 1]
        ]);
    }

    // Leaf: distinct from the device-battery icon while still evoking a
    // charge/energy level.
    function drawBodyBatteryIcon(dc, x, y) {
        dc.fillPolygon([
            [x, y - 10],
            [x + 8, y - 1],
            [x, y + 10],
            [x - 8, y - 1]
        ]);
        dc.drawLine(x, y - 7, x, y + 7);
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
                return { :value => displayValue(activityInfo.floorsClimbed) };
            case 7:
                return { :value => displayValue(getVo2Max()) };
            case 8:
                return { :value => displayValue(getBodyBatteryLevel()) };
            default:
                return { :value => "--" };
        }
    }

    function getVo2Max() {
        var profile = UserProfile.getProfile();
        if (profile has :vo2maxRunning && profile.vo2maxRunning != null) {
            return profile.vo2maxRunning.toNumber();
        }
        if (profile has :vo2maxCycling && profile.vo2maxCycling != null) {
            return profile.vo2maxCycling.toNumber();
        }
        return null;
    }

    function getBodyBatteryLevel() {
        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getBodyBatteryHistory)) {
            return null;
        }
        var iterator = SensorHistory.getBodyBatteryHistory({ :period => 1 });
        var sample = iterator.next();
        return sample == null ? null : sample.data;
    }

    function displayValue(value) {
        return value == null ? "--" : value.toString();
    }
}
