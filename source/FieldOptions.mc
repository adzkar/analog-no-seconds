using Toybox.WatchUi;

// Shared field-type ids (0-9) kept in sync with
// resources/settings/settings.xml and resources/settings/properties.xml.
module FieldOptions {
    const NONE = 9;
    const COUNT = 10;

    function labelResource(id) {
        switch (id) {
            case 0:
                return Rez.Strings.Date;
            case 1:
                return Rez.Strings.Steps;
            case 2:
                return Rez.Strings.HeartRate;
            case 3:
                return Rez.Strings.Stress;
            case 4:
                return Rez.Strings.Battery;
            case 5:
                return Rez.Strings.Calories;
            case 6:
                return Rez.Strings.Stairs;
            case 7:
                return Rez.Strings.Vo2Max;
            case 8:
                return Rez.Strings.BodyBattery;
            default:
                return Rez.Strings.None;
        }
    }
}
