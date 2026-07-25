using Toybox.WatchUi;

// Shared field-type ids (0-7) kept in sync with
// resources/settings/settings.xml and resources/settings/properties.xml.
module FieldOptions {
    const NONE = 7;

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
                return Rez.Strings.Distance;
            default:
                return Rez.Strings.None;
        }
    }
}
