using Toybox.Graphics as Gfx;
using Toybox.WatchUi;

// Shared 8-color palette used by hand, accent, and background settings.
// Ids (0-7) are the single source of truth kept in sync with
// resources/settings/settings.xml and resources/settings/properties.xml.
module ColorOptions {
    const DEFAULT_ID = 0;

    function colorFor(id) {
        switch (id) {
            case 0:
                return Gfx.COLOR_WHITE;
            case 1:
                return Gfx.COLOR_BLACK;
            case 2:
                return Gfx.COLOR_RED;
            case 3:
                return Gfx.COLOR_ORANGE;
            case 4:
                return Gfx.COLOR_YELLOW;
            case 5:
                return Gfx.COLOR_GREEN;
            case 6:
                return Gfx.COLOR_BLUE;
            case 7:
                return Gfx.COLOR_LT_GRAY;
            default:
                return Gfx.COLOR_WHITE;
        }
    }

    // White and Yellow backgrounds need dark text/icons to stay legible.
    function contrastFor(backgroundId) {
        return (backgroundId == 0 || backgroundId == 4) ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    }

    function labelResource(id) {
        switch (id) {
            case 0:
                return Rez.Strings.ColorWhite;
            case 1:
                return Rez.Strings.ColorBlack;
            case 2:
                return Rez.Strings.ColorRed;
            case 3:
                return Rez.Strings.ColorOrange;
            case 4:
                return Rez.Strings.ColorYellow;
            case 5:
                return Rez.Strings.ColorGreen;
            case 6:
                return Rez.Strings.ColorBlue;
            case 7:
                return Rez.Strings.ColorGray;
            default:
                return Rez.Strings.ColorWhite;
        }
    }
}
