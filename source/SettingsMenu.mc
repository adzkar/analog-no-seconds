using Toybox.WatchUi;
using Toybox.Application.Properties;
using Toybox.Lang;

// On-device "Customize" menu (pressed from the watch face Apply/Customize
// prompt). Mirrors the phone-app/Garmin Express settings.xml so the same
// four field positions and four colors can be changed directly on the watch.
class SettingsMenu extends WatchUi.Menu2 {
    var items;

    function initialize() {
        Menu2.initialize({ :title => Rez.Strings.SettingsTitle });
        items = {};
        addFieldItem("TopField", Rez.Strings.TopField);
        addFieldItem("RightField", Rez.Strings.RightField);
        addFieldItem("BottomField", Rez.Strings.BottomField);
        addFieldItem("LeftField", Rez.Strings.LeftField);
        addColorItem("HourHandColor", Rez.Strings.HourHandColor);
        addColorItem("MinuteHandColor", Rez.Strings.MinuteHandColor);
        addColorItem("AccentColor", Rez.Strings.AccentColor);
        addColorItem("BackgroundColor", Rez.Strings.BackgroundColor);
    }

    function addFieldItem(propertyKey, titleRez) {
        var item = new WatchUi.MenuItem(titleRez, fieldSubLabel(propertyKey), propertyKey, {});
        items.put(propertyKey, item);
        addItem(item);
    }

    function addColorItem(propertyKey, titleRez) {
        var item = new WatchUi.MenuItem(titleRez, colorSubLabel(propertyKey), propertyKey, {});
        items.put(propertyKey, item);
        addItem(item);
    }

    function fieldSubLabel(propertyKey) {
        return WatchUi.loadResource(FieldOptions.labelResource(Properties.getValue(propertyKey)));
    }

    function colorSubLabel(propertyKey) {
        return WatchUi.loadResource(ColorOptions.labelResource(Properties.getValue(propertyKey)));
    }

    function refreshItem(propertyKey, isColor) {
        var item = items.get(propertyKey);
        if (item == null) {
            return;
        }
        item.setSubLabel(isColor ? colorSubLabel(propertyKey) : fieldSubLabel(propertyKey));
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    var menu;
    const FIELD_KEYS = ["TopField", "RightField", "BottomField", "LeftField"];

    function initialize(menuRef) {
        Menu2InputDelegate.initialize();
        menu = menuRef;
    }

    function onSelect(item) {
        var propertyKey = item.getId();
        var isField = FIELD_KEYS.indexOf(propertyKey) >= 0;
        var optionCount = isField ? FieldOptions.COUNT : 8;
        var picker = new OptionPickerMenu(item.getLabel(), propertyKey, optionCount, isField);
        var delegate = new OptionPickerDelegate(propertyKey, isField, menu);
        WatchUi.pushView(picker, delegate, WatchUi.SLIDE_LEFT);
    }
}

// Generic 0-7 option list reused for both the field pickers and the color
// pickers; the underlying values already share the same numeric range.
class OptionPickerMenu extends WatchUi.Menu2 {
    function initialize(titleText, propertyKey, optionCount, isField) {
        Menu2.initialize({ :title => titleText });
        for (var i = 0; i < optionCount; i += 1) {
            var labelRez = isField ? FieldOptions.labelResource(i) : ColorOptions.labelResource(i);
            addItem(new WatchUi.MenuItem(labelRez, null, i.toString(), {}));
        }
    }
}

class OptionPickerDelegate extends WatchUi.Menu2InputDelegate {
    var propertyKey;
    var isField;
    var parentMenu;

    function initialize(propertyKeyValue, isFieldValue, parentMenuValue) {
        Menu2InputDelegate.initialize();
        propertyKey = propertyKeyValue;
        isField = isFieldValue;
        parentMenu = parentMenuValue;
    }

    function onSelect(item) {
        var id = item.getId() as Lang.String;
        var value = id.toNumber();
        Properties.setValue(propertyKey, value);
        parentMenu.refreshItem(propertyKey, !isField);
        WatchUi.requestUpdate();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
