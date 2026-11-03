# @name    Persona 3 Reload Clock
# @desc    Iconic P3R Underwater Clock & Calendar for Ulanzi TC002
# @author  patw
# @version 1.0.0
# @display 52x16
# @config  timezone        text   "Timezone"             default="Asia/Taipei" help="IANA timezone or offset, e.g. Asia/Taipei, Asia/Tokyo, UTC, +8, auto"
# @config  force_dark      bool   "Force Dark Hour"      default=false help="Force Tartarus Dark Hour green theme (normally 00:00 - 00:59)"
# @config  enable_p3_cycle bool   "Cycle P3 Logo"        default=true help="Alternate weekday slot with classic pixel P3 logo"

# ==============================================================================
# Persona 3 Reload Theme Calendar & Clock for AWTRIX NG (awtrix-p3r-clock)
# Target Device: Ulanzi TC002 (52x16 RGB LED Matrix)
#
# Features:
#   - Normal Mode:
#     * Left (Cols 0-15): Makoto Yuki underwater icon
#     * Right (Cols 16-51): Ocean blue gradient, ambient rising bubbles
#     * Top-Right: Date (MM/DD) & Yellow Weekday (WED) / P3 logo
#     * Bottom-Right: 4x7 Clock (HH:MM:SS)
#   - Dark Hour Mode (00:00~00:59 or force_dark):
#     * Left (Cols 0-15): Dark Hour Full Moon icon
#     * Right: Dark green gradient, neon green clock, red seconds
#   - Settings (Web UI App Settings):
#     * Timezone string (Asia/Taipei, Asia/Tokyo, UTC, +8, auto)
#     * Force Dark Hour toggle
#     * P3 Logo cycle toggle (alternates Weekday with P3 logo)
# ==============================================================================

# Safe global imports
var time_mod = nil
try
    import time
    time_mod = time
except ..
end

class P3R_Clock
    # App Settings (injected via @config)
    var timezone          # Timezone string, e.g. "Asia/Taipei", "Asia/Tokyo", "+8", "auto"
    var force_dark        # true = Force Dark Hour; false = auto (00:00~00:59)
    var enable_p3_cycle   # true = Alternate weekday with P3 logo; false = weekday only

    # Internal state
    var frame_count       # Frame counter for animations
    var spans_makoto      # 16x16 Inverted Makoto Yuki Spans
    var spans_moon        # 16x16 Dark Hour Full Moon Spans
    var digits_4x7        # 4x7 clock numbers font
    var font_3x5          # 3x5 font for date, weekday, and text
    var bubbles           # Floating water bubbles & ambient particles
    var has_pixel         # True if firmware supports pixel()
    var has_line          # True if firmware supports line()
    var pseudo_seed       # Pseudo-random generator state

    def init()
        # Load user settings from AWTRIX store
        try
            var tz = store.get("timezone")
            if tz == nil tz = store.get("tz") end
            if tz != nil self.timezone = tz end
        except ..
        end
        try
            var fd = store.get("force_dark")
            if fd == nil fd = store.get("dark") end
            if fd != nil self.force_dark = fd end
        except ..
        end
        try
            var ep = store.get("enable_p3_cycle")
            if ep == nil ep = store.get("p3_cycle") end
            if ep != nil self.enable_p3_cycle = ep end
        except ..
        end

        if self.timezone == nil
            self.timezone = "Asia/Taipei"
        end
        if self.force_dark == nil
            self.force_dark = false
        end
        if self.enable_p3_cycle == nil
            self.enable_p3_cycle = true
        end

        self.frame_count = 0
        self.pseudo_seed = 12345

        self.has_pixel = true
        self.has_line = false
        try
            import global
            if global.contains("pixel") self.has_pixel = true end
            if global.contains("line") self.has_line = true end
        except ..
        end

        # 1. Makoto Yuki inverted plunge RLE Spans [x, y, w, color]
        self.spans_makoto = [
            [0, 0, 3, 0xFFFFFF], [3, 0, 1, 0x0A0D18], [4, 0, 2, 0xFFFFFF], [6, 0, 2, 0xEAF2FA], [8, 0, 2, 0xFFEAD8], [10, 0, 1, 0xD4B098], [11, 0, 1, 0x8BE9FD], [12, 0, 1, 0x00E5FF], [13, 0, 3, 0x0033A0],
            [0, 1, 2, 0xFFFFFF], [2, 1, 2, 0x0A0D18], [4, 1, 1, 0xFFFFFF], [5, 1, 2, 0xEAF2FA], [7, 1, 3, 0xFFEAD8], [10, 1, 1, 0xD4B098], [11, 1, 1, 0x8BE9FD], [12, 1, 1, 0x00E5FF], [13, 1, 3, 0x0033A0],
            [0, 2, 3, 0xFFFFFF], [3, 2, 1, 0x0A0D18], [4, 2, 2, 0xEAF2FA], [6, 2, 3, 0xFFEAD8], [9, 2, 1, 0xD4B098], [10, 2, 1, 0x00E5FF], [11, 2, 5, 0x0033A0],
            [0, 3, 5, 0xFFFFFF], [5, 3, 3, 0xFFEAD8], [8, 3, 1, 0xD4B098], [9, 3, 1, 0x00E5FF], [10, 3, 6, 0x0033A0],
            [0, 4, 4, 0xFFFFFF], [4, 4, 2, 0xFFEAD8], [6, 4, 1, 0xD4B098], [7, 4, 1, 0xFFEAD8], [8, 4, 1, 0x00E5FF], [9, 4, 7, 0x0033A0],
            [0, 5, 3, 0xFFFFFF], [3, 5, 5, 0xFFEAD8], [8, 5, 8, 0x0033A0],
            [0, 6, 2, 0xFFFFFF], [2, 6, 1, 0x08206A], [3, 6, 1, 0x030C28], [4, 6, 1, 0xFFEAD8], [5, 6, 3, 0x020818], [8, 6, 1, 0x00E5FF], [9, 6, 7, 0x0033A0],
            [0, 7, 1, 0xFFFFFF], [1, 7, 1, 0x08206A], [2, 7, 1, 0x030C28], [3, 7, 1, 0x08206A], [4, 7, 1, 0xFFEAD8], [5, 7, 1, 0xFFFFFF], [6, 7, 1, 0x00E5FF], [7, 7, 1, 0x020818], [8, 7, 1, 0x00E5FF], [9, 7, 7, 0x0033A0],
            [0, 8, 1, 0x08206A], [1, 8, 1, 0x030C28], [2, 8, 1, 0x144AC0], [3, 8, 1, 0x08206A], [4, 8, 1, 0x00E5FF], [5, 8, 1, 0xFFEAD8], [6, 8, 1, 0x00E5FF], [7, 8, 1, 0xFFEAD8], [8, 8, 8, 0x0033A0],
            [0, 9, 1, 0x030C28], [1, 9, 1, 0x08206A], [2, 9, 2, 0x144AC0], [4, 9, 1, 0x08206A], [5, 9, 1, 0x00E5FF], [6, 9, 1, 0xFFEAD8], [7, 9, 1, 0xD4B098], [8, 9, 8, 0x0033A0],
            [0, 10, 2, 0x030C28], [2, 10, 1, 0x08206A], [3, 10, 2, 0x144AC0], [5, 10, 1, 0x08206A], [6, 10, 1, 0x00E5FF], [7, 10, 5, 0x0033A0], [12, 10, 4, 0x001450],
            [0, 11, 1, 0x001450], [1, 11, 2, 0x030C28], [3, 11, 1, 0x08206A], [4, 11, 2, 0x144AC0], [6, 11, 1, 0x08206A], [7, 11, 1, 0x00E5FF], [8, 11, 1, 0x0033A0], [9, 11, 7, 0x001450],
            [0, 12, 2, 0x001450], [2, 12, 2, 0x030C28], [4, 12, 1, 0x08206A], [5, 12, 2, 0x144AC0], [7, 12, 1, 0x00E5FF], [8, 12, 8, 0x001450],
            [0, 13, 3, 0x001450], [3, 13, 1, 0x030C28], [4, 13, 2, 0x08206A], [6, 13, 1, 0x144AC0], [7, 13, 1, 0x00E5FF], [8, 13, 8, 0x001450],
            [0, 14, 4, 0x001450], [4, 14, 2, 0x030C28], [6, 14, 1, 0x08206A], [7, 14, 1, 0x144AC0], [8, 14, 8, 0x001450],
            [0, 15, 5, 0x001450], [5, 15, 1, 0x030C28], [6, 15, 1, 0x08206A], [7, 15, 9, 0x001450]
        ]

        # 2. Dark Hour Full Moon RLE Spans (Green atmosphere with lunar craters)
        self.spans_moon = [
            [0, 0, 6, 0x0A2B18], [6, 0, 4, 0x1B5E28], [10, 0, 6, 0x0A2B18],
            [0, 1, 4, 0x0A2B18], [4, 1, 2, 0x1B5E28], [6, 1, 4, 0x55DE44], [10, 1, 2, 0x1B5E28], [12, 1, 4, 0x0A2B18],
            [0, 2, 2, 0x0A2B18], [2, 2, 2, 0x1B5E28], [4, 2, 2, 0x55DE44], [6, 2, 4, 0x9CE050], [10, 2, 2, 0x55DE44], [12, 2, 2, 0x1B5E28], [14, 2, 2, 0x0A2B18],
            [0, 3, 2, 0x0A2B18], [2, 3, 1, 0x1B5E28], [3, 3, 1, 0x55DE44], [4, 3, 2, 0x9CE050], [6, 3, 1, 0x509424], [7, 3, 2, 0xDDFFA0], [9, 3, 3, 0x9CE050], [12, 3, 1, 0x55DE44], [13, 3, 1, 0x1B5E28], [14, 3, 2, 0x0A2B18],
            [0, 4, 1, 0x0A2B18], [1, 4, 1, 0x1B5E28], [2, 4, 1, 0x55DE44], [3, 4, 1, 0x9CE050], [4, 4, 1, 0xDDFFA0], [5, 4, 1, 0x509424], [6, 4, 1, 0x306414], [7, 4, 1, 0x509424], [8, 4, 1, 0x9CE050], [9, 4, 2, 0xDDFFA0], [11, 4, 2, 0x9CE050], [13, 4, 1, 0x55DE44], [14, 4, 1, 0x1B5E28], [15, 4, 1, 0x0A2B18],
            [0, 5, 1, 0x0A2B18], [1, 5, 1, 0x1B5E28], [2, 5, 1, 0x55DE44], [3, 5, 1, 0x9CE050], [4, 5, 1, 0x509424], [5, 5, 3, 0x306414], [8, 5, 1, 0x509424], [9, 5, 1, 0xDDFFA0], [10, 5, 1, 0x9CE050], [11, 5, 1, 0xDDFFA0], [12, 5, 1, 0x9CE050], [13, 5, 1, 0x55DE44], [14, 5, 1, 0x1B5E28], [15, 5, 1, 0x0A2B18],
            [0, 6, 1, 0x1B5E28], [1, 6, 1, 0x55DE44], [2, 6, 2, 0x9CE050], [4, 6, 1, 0xDDFFA0], [5, 6, 1, 0x509424], [6, 6, 1, 0x306414], [7, 6, 2, 0x509424], [9, 6, 2, 0x306414], [11, 6, 1, 0x509424], [12, 6, 2, 0x9CE050], [14, 6, 1, 0x55DE44], [15, 6, 1, 0x1B5E28],
            [0, 7, 1, 0x1B5E28], [1, 7, 1, 0x55DE44], [2, 7, 1, 0x9CE050], [3, 7, 2, 0xDDFFA0], [5, 7, 1, 0x9CE050], [6, 7, 1, 0x509424], [7, 7, 1, 0xDDFFA0], [8, 7, 1, 0x509424], [9, 7, 2, 0x306414], [11, 7, 1, 0x509424], [12, 7, 1, 0xDDFFA0], [13, 7, 1, 0x9CE050], [14, 7, 1, 0x55DE44], [15, 7, 1, 0x1B5E28],
            [0, 8, 1, 0x1B5E28], [1, 8, 1, 0x55DE44], [2, 8, 1, 0x9CE050], [3, 8, 1, 0xDDFFA0], [4, 8, 1, 0x9CE050], [5, 8, 2, 0xDDFFA0], [7, 8, 1, 0x9CE050], [8, 8, 1, 0x509424], [9, 8, 2, 0x306414], [11, 8, 1, 0x509424], [12, 8, 1, 0xDDFFA0], [13, 8, 1, 0x9CE050], [14, 8, 1, 0x55DE44], [15, 8, 1, 0x1B5E28],
            [0, 9, 1, 0x1B5E28], [1, 9, 1, 0x55DE44], [2, 9, 2, 0x9CE050], [4, 9, 2, 0xDDFFA0], [6, 9, 2, 0x509424], [8, 9, 1, 0xDDFFA0], [9, 9, 1, 0x9CE050], [10, 9, 2, 0xDDFFA0], [12, 9, 2, 0x9CE050], [14, 9, 1, 0x55DE44], [15, 9, 1, 0x1B5E28],
            [0, 10, 1, 0x0A2B18], [1, 10, 1, 0x1B5E28], [2, 10, 1, 0x55DE44], [3, 10, 1, 0x9CE050], [4, 10, 1, 0xDDFFA0], [5, 10, 1, 0x9CE050], [6, 10, 2, 0x509424], [8, 10, 1, 0x9CE050], [9, 10, 2, 0xDDFFA0], [11, 10, 2, 0x9CE050], [13, 10, 1, 0x55DE44], [14, 10, 1, 0x1B5E28], [15, 10, 1, 0x0A2B18],
            [0, 11, 1, 0x0A2B18], [1, 11, 1, 0x1B5E28], [2, 11, 1, 0x55DE44], [3, 11, 2, 0x9CE050], [5, 11, 1, 0xDDFFA0], [6, 11, 2, 0x509424], [8, 11, 2, 0xDDFFA0], [10, 11, 1, 0x9CE050], [11, 11, 1, 0xDDFFA0], [12, 11, 1, 0x9CE050], [13, 11, 1, 0x55DE44], [14, 11, 1, 0x1B5E28], [15, 11, 1, 0x0A2B18],
            [0, 12, 2, 0x0A2B18], [2, 12, 1, 0x1B5E28], [3, 12, 1, 0x55DE44], [4, 12, 3, 0x9CE050], [7, 12, 2, 0xDDFFA0], [9, 12, 3, 0x9CE050], [12, 12, 1, 0x55DE44], [13, 12, 1, 0x1B5E28], [14, 12, 2, 0x0A2B18],
            [0, 13, 2, 0x0A2B18], [2, 13, 2, 0x1B5E28], [4, 13, 2, 0x55DE44], [6, 13, 4, 0x9CE050], [10, 13, 2, 0x55DE44], [12, 13, 2, 0x1B5E28], [14, 13, 2, 0x0A2B18],
            [0, 14, 4, 0x0A2B18], [4, 14, 2, 0x1B5E28], [6, 14, 4, 0x55DE44], [10, 14, 2, 0x1B5E28], [12, 14, 4, 0x0A2B18],
            [0, 15, 6, 0x0A2B18], [6, 15, 4, 0x1B5E28], [10, 15, 6, 0x0A2B18]
        ]

        # 3. 4x7 Bold Digit Bitmaps
        self.digits_4x7 = {
            0: [0x6, 0x9, 0x9, 0x9, 0x9, 0x9, 0x6],
            1: [0x4, 0xC, 0x4, 0x4, 0x4, 0x4, 0xE],
            2: [0x6, 0x9, 0x1, 0x2, 0x4, 0x8, 0xF],
            3: [0x6, 0x9, 0x1, 0x6, 0x1, 0x9, 0x6],
            4: [0x9, 0x9, 0x9, 0xF, 0x1, 0x1, 0x1],
            5: [0xF, 0x8, 0x8, 0xE, 0x1, 0x1, 0xE],
            6: [0x6, 0x8, 0x8, 0xE, 0x9, 0x9, 0x6],
            7: [0xF, 0x1, 0x2, 0x2, 0x4, 0x4, 0x4],
            8: [0x6, 0x9, 0x9, 0x6, 0x9, 0x9, 0x6],
            9: [0x6, 0x9, 0x9, 0x7, 0x1, 0x1, 0x6]
        }

        # 4. 3x5 Calendar & Text Bitmaps
        self.font_3x5 = {
            "0": [0x7, 0x5, 0x5, 0x5, 0x7],
            "1": [0x2, 0x6, 0x2, 0x2, 0x7],
            "2": [0x7, 0x1, 0x7, 0x4, 0x7],
            "3": [0x7, 0x1, 0x7, 0x1, 0x7],
            "4": [0x5, 0x5, 0x7, 0x1, 0x1],
            "5": [0x7, 0x4, 0x7, 0x1, 0x7],
            "6": [0x7, 0x4, 0x7, 0x5, 0x7],
            "7": [0x7, 0x1, 0x2, 0x2, 0x2],
            "8": [0x7, 0x5, 0x7, 0x5, 0x7],
            "9": [0x7, 0x5, 0x7, 0x1, 0x7],
            "/": [0x1, 0x1, 0x2, 0x4, 0x4],
            ":": [0x0, 0x2, 0x0, 0x2, 0x0],
            " ": [0x0, 0x0, 0x0, 0x0, 0x0],
            "S": [0x7, 0x4, 0x7, 0x1, 0x7],
            "U": [0x5, 0x5, 0x5, 0x5, 0x7],
            "N": [0x5, 0x7, 0x7, 0x5, 0x5],
            "M": [0x5, 0x7, 0x5, 0x5, 0x5],
            "O": [0x7, 0x5, 0x5, 0x5, 0x7],
            "T": [0x7, 0x2, 0x2, 0x2, 0x2],
            "E": [0x7, 0x4, 0x6, 0x4, 0x7],
            "W": [0x5, 0x5, 0x5, 0x5, 0x2],
            "D": [0x6, 0x5, 0x5, 0x5, 0x6],
            "H": [0x5, 0x5, 0x7, 0x5, 0x5],
            "F": [0x7, 0x4, 0x6, 0x4, 0x4],
            "R": [0x6, 0x5, 0x6, 0x5, 0x5],
            "I": [0x7, 0x2, 0x2, 0x2, 0x7],
            "A": [0x2, 0x5, 0x7, 0x5, 0x5]
        }

        # 5. Rising water bubbles and subtle pink particle shards
        self.bubbles = [
            {"x": 19, "y": 14.0, "speed": 0.20, "color": 0x6CEFFF},
            {"x": 25, "y": 12.0, "speed": 0.25, "color": 0x4AE5FF},
            {"x": 33, "y": 15.0, "speed": 0.18, "color": 0xFF69B4},
            {"x": 41, "y": 10.0, "speed": 0.22, "color": 0x9EEFFF},
            {"x": 48, "y": 13.0, "speed": 0.30, "color": 0xFF85C2}
        ]
    end

    def rand_next(max_val)
        self.pseudo_seed = (self.pseudo_seed * 1103515245 + 12345) & 0x7FFFFFFF
        return self.pseudo_seed % max_val
    end

    # Parse timezone string and compute second offset
    def get_tz_offset()
        var tz = self.timezone
        if tz == nil || tz == "auto" return 0 end

        try
            import string
            if string.find(tz, "Taipei") >= 0 || string.find(tz, "Hong_Kong") >= 0 || string.find(tz, "Beijing") >= 0 || string.find(tz, "Singapore") >= 0
                return 28800
            elif string.find(tz, "Tokyo") >= 0 || string.find(tz, "Seoul") >= 0
                return 32400
            elif string.find(tz, "London") >= 0 || string.find(tz, "UTC") >= 0 || string.find(tz, "GMT") >= 0
                return 0
            elif string.find(tz, "New_York") >= 0 || string.find(tz, "EST") >= 0 || string.find(tz, "EDT") >= 0
                return -18000
            elif string.find(tz, "Los_Angeles") >= 0 || string.find(tz, "PST") >= 0 || string.find(tz, "PDT") >= 0
                return -28800
            elif string.find(tz, "Paris") >= 0 || string.find(tz, "Berlin") >= 0 || string.find(tz, "Rome") >= 0
                return 3600
            elif string.find(tz, "Sydney") >= 0
                return 36000
            end
        except ..
            if tz == "Asia/Taipei" return 28800
            elif tz == "Asia/Tokyo" return 32400
            elif tz == "UTC" return 0
            end
        end

        # Support numeric offset strings like "+8", "8", "-5", "0"
        try
            var num = int(tz)
            return num * 3600
        except ..
            return 28800
        end
    end

    def epoch_to_time(epoch)
        var day_count = epoch / 86400
        var rem_sec = epoch % 86400
        if rem_sec < 0
            rem_sec = rem_sec + 86400
            day_count = day_count - 1
        end

        var hour = rem_sec / 3600
        var minute = (rem_sec % 3600) / 60
        var sec = rem_sec % 60
        var weekday = (day_count + 4) % 7

        var z = day_count + 719468
        var z_adj = z
        if z < 0
            z_adj = z - 146096
        end
        var era = z_adj / 146097
        var doe = z - era * 146097
        var yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
        var y = yoe + era * 400
        var doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
        var mp = (5 * doy + 2) / 153
        var d = doy - (153 * mp + 2) / 5 + 1
        var m = 0
        if mp < 10
            m = mp + 3
        else
            m = mp - 9
        end
        if m <= 2
            y = y + 1
        end

        return {
            "year": y, "month": m, "day": d,
            "hour": hour, "min": minute, "sec": sec,
            "weekday": weekday, "epoch": epoch
        }
    end

    # Retrieve current time (prioritize native AWTRIX NG time functions)
    def get_now()
        var offset_sec = self.get_tz_offset()

        # 1. Native AWTRIX NG global time functions
        try
            import global
            if global.contains("hour") && global.contains("minute") && global.contains("second")
                var h = global.hour()
                var mi = global.minute()
                var s = global.second()
                var mo = 11
                var d = 3
                var wd = 2
                var y = 2026
                if global.contains("month") mo = global.month() end
                if global.contains("day") d = global.day() end
                if global.contains("weekday") wd = global.weekday() end
                if global.contains("year") y = global.year() end
                return {
                    "year": y, "month": mo, "day": d,
                    "hour": h, "min": mi, "sec": s,
                    "weekday": wd
                }
            end
        except ..
        end

        # 2. Native epoch_ms()
        try
            import global
            if global.contains("epoch_ms")
                var ep = global.epoch_ms() / 1000 + offset_sec
                return self.epoch_to_time(ep)
            end
        except ..
        end

        # 3. Fallback: time module
        if time_mod != nil
            try
                var ep = time_mod.time() + offset_sec
                return self.epoch_to_time(ep)
            except ..
            end
        end

        # 4. Default fallback
        return {"year": 2026, "month": 11, "day": 3, "hour": 21, "min": 45, "sec": 0, "weekday": 2}
    end

    # Draw 4x7 bold number for clock
    def draw_digit_4x7(x, y, num, color)
        if !self.digits_4x7.contains(num) return end
        var rows = self.digits_4x7[num]
        var ry = 0
        while ry < 7
            var bits = rows[ry]
            var rx = 0
            while rx < 4
                if (bits & (8 >> rx)) != 0
                    pixel(x + rx, y + ry, color)
                end
                rx = rx + 1
            end
            ry = ry + 1
        end
    end

    # Draw single 3x5 character using pixel()
    def draw_char_3x5(x, y, ch, color)
        if !self.font_3x5.contains(ch) return 0 end
        var rows = self.font_3x5[ch]
        var ry = 0
        while ry < 5
            var bits = rows[ry]
            var rx = 0
            while rx < 3
                if (bits & (4 >> rx)) != 0
                    pixel(x + rx, y + ry, color)
                end
                rx = rx + 1
            end
            ry = ry + 1
        end
        return 4
    end

    # Draw 3x5 string
    def draw_text_3x5(x, y, str_val, color)
        var cur_x = x
        var i = 0
        var slen = size(str_val)
        while i < slen
            var ch = str_val[i]
            cur_x = cur_x + self.draw_char_3x5(cur_x, y, ch, color)
            i = i + 1
        end
    end

    # Draw classic Persona 3 Reload pixel logo (P3)
    def draw_p3_logo(x, y, color)
        # P (5x5, located at x..x+4)
        pixel(x + 1, y, color)
        pixel(x + 2, y, color)
        pixel(x + 3, y, color)
        pixel(x + 4, y, color)

        pixel(x, y + 1, color)
        pixel(x + 4, y + 1, color)

        pixel(x, y + 2, color)
        pixel(x + 1, y + 2, color)
        pixel(x + 2, y + 2, color)
        pixel(x + 3, y + 2, color)
        pixel(x + 4, y + 2, color)

        pixel(x, y + 3, color)
        pixel(x, y + 4, color)

        # 3 (5x5, located at x+6..x+10)
        pixel(x + 6, y, color)
        pixel(x + 7, y, color)
        pixel(x + 8, y, color)
        pixel(x + 9, y, color)

        pixel(x + 10, y + 1, color)

        pixel(x + 7, y + 2, color)
        pixel(x + 8, y + 2, color)
        pixel(x + 9, y + 2, color)

        pixel(x + 10, y + 3, color)

        pixel(x + 6, y + 4, color)
        pixel(x + 7, y + 4, color)
        pixel(x + 8, y + 4, color)
        pixel(x + 9, y + 4, color)
    end

    def pad2(val)
        var s = str(val)
        if size(s) == 1
            return "0" + s
        end
        return s
    end

    def draw_line(x0, y0, x1, y1, color)
        if self.has_line
            line(x0, y0, x1, y1, color)
        else
            if y0 == y1
                var x = x0
                while x <= x1
                    pixel(x, y0, color)
                    x = x + 1
                end
            elif x0 == x1
                var y = y0
                while y <= y1
                    pixel(x0, y, color)
                    y = y + 1
                end
            else
                pixel(x0, y0, color)
                pixel(x1, y1, color)
            end
        end
    end

    def loop()
    end

    # 40 FPS Rendering Loop
    def draw()
        self.frame_count = self.frame_count + 1
        var now = self.get_now()
        
        # Check if Dark Hour is active (either via force_dark or midnight 00:00~00:59)
        var is_dark_hour = (self.force_dark == true || self.force_dark == "true" || self.force_dark == 1) || (now["hour"] == 0)

        # -------------------------------------------------------------
        # Theme palette setup (100% compliant Berry syntax, no ternary)
        # -------------------------------------------------------------
        var c_surf = 0x00AEEF
        var c_mid1 = 0x0055D4
        var c_mid2 = 0x002B9E
        var c_deep = 0x00176E
        var c_abys = 0x000B42
        var target_spans = self.spans_makoto
        var date_col = 0xFFFFFF
        var slash_col = 0x00E5FF
        var sep_col = 0x00E5FF
        var bar_col = 0x00D4FF
        var clock_col = 0xFFFFFF
        var sec_col = 0x00E5FF
        var p3_col = 0xFFFFFF

        if is_dark_hour
            # Dark Hour: Deep Tartarus green gradient matching the moon background (0x0A2B18)
            # Row 0 and 1 use 0x0A2B18 so there is NO bright green line above the date
            c_surf = 0x0A2B18
            c_mid1 = 0x082414
            c_mid2 = 0x061D10
            c_deep = 0x04150B
            c_abys = 0x020B05
            target_spans = self.spans_moon
            date_col = 0x2BFF88
            slash_col = 0x2BFF88
            sep_col = 0x2BFF88
            bar_col = 0x2BFF88
            clock_col = 0x2BFF88
            sec_col = 0xFF3333
            p3_col = 0xE8FFC0
        end

        # -------------------------------------------------------------
        # 1. Vertical background gradient (Cols 16 to 51)
        # -------------------------------------------------------------
        var y = 0
        while y < 16
            var c_line = c_abys
            if is_dark_hour
                # In Dark Hour: smooth deep Tartarus gradient with NO green stripe at top
                if y <= 1
                    c_line = c_surf
                elif y <= 4
                    c_line = c_mid1
                elif y <= 8
                    c_line = c_mid2
                elif y <= 12
                    c_line = c_deep
                end
            else
                # In Normal Mode: ocean water with animated surface shimmer
                if y <= 1
                    if (self.frame_count / 10 + y) % 3 == 0
                        c_line = 0x00E5FF
                    else
                        c_line = c_surf
                    end
                elif y <= 4
                    c_line = c_mid1
                elif y <= 8
                    c_line = c_mid2
                elif y <= 12
                    c_line = c_deep
                end
            end
            self.draw_line(16, y, 51, y, c_line)
            y = y + 1
        end

        # -------------------------------------------------------------
        # 2. Left tile (Cols 0 to 15): Makoto Yuki or Dark Hour Full Moon
        # -------------------------------------------------------------
        var i = 0
        var span_count = target_spans.size()
        while i < span_count
            var s = target_spans[i]
            self.draw_line(s[0], s[1], s[0] + s[2] - 1, s[1], s[3])
            i = i + 1
        end

        # -------------------------------------------------------------
        # 3. Ambient bubbles and particle animations
        # -------------------------------------------------------------
        var bi = 0
        while bi < self.bubbles.size()
            var b = self.bubbles[bi]
            b["y"] = b["y"] - b["speed"]
            if b["y"] < 0.0
                b["y"] = 15.5
                b["x"] = 17 + self.rand_next(34)
            end
            var b_color = b["color"]
            if is_dark_hour
                b_color = 0x2BFF88
            end
            pixel(b["x"], int(b["y"]), b_color)
            bi = bi + 1
        end

        # -------------------------------------------------------------
        # 4. Top-Right: Date (MM/DD) and Weekday / P3 Logo
        # -------------------------------------------------------------
        var m_str = self.pad2(now["month"])
        var d_str = self.pad2(now["day"])

        self.draw_text_3x5(18, 1, m_str, date_col)
        self.draw_char_3x5(26, 1, "/", slash_col)
        self.draw_text_3x5(30, 1, d_str, date_col)

        # Vertical separator line (X=37)
        self.draw_line(37, 1, 37, 5, sep_col)

        # Weekday slot (X=39..51): Alternate between weekday and P3 logo
        var is_cycle_enabled = (self.enable_p3_cycle == true || self.enable_p3_cycle == "true" || self.enable_p3_cycle == 1)
        var show_p3_now = is_cycle_enabled && ((self.frame_count / 160) % 2 == 1)

        if show_p3_now
            # P3 Logo mode: classic Persona 3 Reload pixel typography
            self.draw_p3_logo(40, 1, p3_col)
        else
            # Weekday mode: SUN, MON, TUE, WED, THU, FRI, SAT (High contrast yellow)
            var weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            var w_name = weekdays[now["weekday"] % 7]
            var w_color = 0xFFE600 # Persona Yellow
            if is_dark_hour
                w_color = 0xCEFF40 # Tartarus Lime Yellow
            elif now["weekday"] == 0
                w_color = 0xFF2A4D # Sunday Red
            end
            self.draw_text_3x5(39, 1, w_name, w_color)
        end

        # Horizontal divider beam (Y=7)
        self.draw_line(17, 7, 50, 7, bar_col)

        # -------------------------------------------------------------
        # 5. Bottom-Right: Unified 4x7 Clock (HH:MM:SS) (X=18..50, Y=8..14)
        # -------------------------------------------------------------
        var h1 = now["hour"] / 10
        var h2 = now["hour"] % 10
        var m1 = now["min"] / 10
        var m2 = now["min"] % 10
        var s1 = now["sec"] / 10
        var s2 = now["sec"] % 10

        # HH: 18..26
        self.draw_digit_4x7(18, 8, h1, clock_col)
        self.draw_digit_4x7(23, 8, h2, clock_col)

        # Colon 1 (X=28)
        pixel(28, 10, clock_col)
        pixel(28, 12, clock_col)

        # MM: 30..38
        self.draw_digit_4x7(30, 8, m1, clock_col)
        self.draw_digit_4x7(35, 8, m2, clock_col)

        # Colon 2 (X=40)
        pixel(40, 10, clock_col)
        pixel(40, 12, clock_col)

        # SS: 42..50
        self.draw_digit_4x7(42, 8, s1, sec_col)
        self.draw_digit_4x7(47, 8, s2, sec_col)
    end
end

# Return App instance for AWTRIX NG rotation
return P3R_Clock()
