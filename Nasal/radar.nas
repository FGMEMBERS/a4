# AN/APG-53B Radar scope implemented in Nasal/Canvas.

# Constants controlling the canvas
var SIZE = 512;  # Canvas SIZE
var BORDER = 50; # Edge BORDER
var VSPACING = (SIZE - 2*BORDER) / 5;  # Vertical spacing between the 5 horizontal lines
var HSPACING = (SIZE - 2*BORDER) / 5;  # Horizontal spacing between the vertical tick-marks 
var VLENGTH = 20; # Length of the tick-marks
var GAP =  256;  # Gap in the middle of the display
var STEPS = 20;  # Number of points to draw in radar trace

# Radar Modes
var RADAR_MODE_OFF  = 0;
var RADAR_MODE_STBY = 1;
var RADAR_MODE_SRCH = 2;
var RADAR_MODE_TC   = 3;
var RADAR_MODE_AG   = 4;

# Radar orientation
var RADAR_ORIENT_PLAN = 0;
var RADAR_ORIENT_PROFILE = 1;

# Global variables
var mark_intensity = 0.5;   # Mark brightness;
var trace_intensity = 1.0;  # Trace brightness
var range_mode = 10; # Range mode - either 10nm or 20nm

var my_canvas = canvas.new({
  "name": "RadarScope",   # The name is optional but allow for easier identification
  "size": [SIZE, SIZE], # Size of the underlying texture (should be a power of 2, required)
  "view": [SIZE, SIZE],  # Virtual resolution (Defines the coordinate system of the canvas
                        # which will be stretched the SIZE of the texture, required)
  "mipmapping": 1       # Enable mipmapping (optional)
});

var group = my_canvas.createGroup();
my_canvas.addPlacement({"node": "RadarDisplay"});

# We only display the vertical modes at present
var line1 = group.createChild("path")
                    .setStrokeLineWidth(2.0)
                    .setColor(mark_intensity,mark_intensity,mark_intensity);

line1.setData
        (
          [ canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
          
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,

            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            
            # Vertical marks on the +5 line
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,

            # Vertical mark on the -15 line
            canvas.Path.VG_MOVE_TO, canvas.Path.VG_LINE_TO,
            
            canvas.Path.VG_CLOSE_PATH ],
          [ 
            # +10 degrees
            (BORDER + 50), BORDER, (SIZE - BORDER - 50), BORDER,
            
            # + 5 degrees
            BORDER, (VSPACING + BORDER), (SIZE - BORDER), (VSPACING + BORDER),
                  
            # 0 degrees.  There is a GAP in this line, so we need to draw two                        
            BORDER, (2 * VSPACING + BORDER), (0.5*SIZE - 0.5 * GAP), (2 * VSPACING + BORDER),
            (0.5 * SIZE + 0.5 * GAP), (2 * VSPACING + BORDER), (SIZE - BORDER), (2 * VSPACING + BORDER),
            
            # -5 degrees.  There is a GAP in this line as well
            BORDER, (3 * VSPACING + BORDER), (0.5*SIZE - 0.5 * GAP), (3 * VSPACING + BORDER),
            (0.5 * SIZE + 0.5 * GAP), (3 * VSPACING + BORDER), (SIZE - BORDER), (3 * VSPACING + BORDER),
            
            # -10 degrees
            BORDER, (4 * VSPACING + BORDER), (SIZE - BORDER), (4 * VSPACING + BORDER),
            
            # - 15 degrees
            (BORDER + 50), (5 * VSPACING + BORDER), (SIZE - BORDER - 50), (5 * VSPACING + BORDER),
            
            
            # Vertical lines - 6 evenly spaced on the +5 line
            BORDER, (VSPACING + BORDER), BORDER, (VSPACING + BORDER + VLENGTH),
            BORDER + HSPACING, (VSPACING + BORDER), BORDER + HSPACING, (VSPACING + BORDER + VLENGTH),
            BORDER + 2*HSPACING, (VSPACING + BORDER), BORDER + 2*HSPACING, (VSPACING + BORDER + VLENGTH),
            BORDER + 3*HSPACING, (VSPACING + BORDER), BORDER + 3*HSPACING, (VSPACING + BORDER + VLENGTH),
            BORDER + 4*HSPACING, (VSPACING + BORDER), BORDER + 4*HSPACING, (VSPACING + BORDER + VLENGTH),
            BORDER + 5*HSPACING, (VSPACING + BORDER), BORDER + 5*HSPACING, (VSPACING + BORDER + VLENGTH),
            
            # Vertical mark on the -15 line
            0.5*SIZE, (5 * VSPACING + BORDER), 0.5*SIZE, (5 * VSPACING + BORDER - VLENGTH)
            
          ]
        );
        

# Text labels for the horizontal lines
var halign = BORDER - 10;

var labels = [
        
group.createChild("text", "+10")
    .setTranslation(halign, BORDER)      # The origin is in the top left corner
    .setAlignment("right-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
    .setFont("LiberationFonts/LiberationSans-Regular.ttf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
    .setFontSize(24, 1.2)        # Set fontSIZE and optionally character aspect ratio
    .setColor(mark_intensity,mark_intensity,mark_intensity)             # Text color
    .setText("+10"),

group.createChild("text", "+5")
    .setTranslation(halign, BORDER + VSPACING)      # The origin is in the top left corner
    .setAlignment("right-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
    .setFont("LiberationFonts/LiberationSans-Regular.ttf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
    .setFontSize(24, 1.2)        # Set fontSIZE and optionally character aspect ratio
    .setColor(mark_intensity,mark_intensity,mark_intensity)             # Text color
    .setText("+5"),
    
group.createChild("text", "0")
    .setTranslation(halign, BORDER + 2 * VSPACING)      # The origin is in the top left corner
    .setAlignment("right-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
    .setFont("LiberationFonts/LiberationSans-Regular.ttf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
    .setFontSize(24, 1.2)        # Set fontSIZE and optionally character aspect ratio
    .setColor(mark_intensity,mark_intensity,mark_intensity)             # Text color
    .setText("0"),

group.createChild("text", "-5")
    .setTranslation(halign, BORDER + 3 * VSPACING)      # The origin is in the top left corner
    .setAlignment("right-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
    .setFont("LiberationFonts/LiberationSans-Regular.ttf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
    .setFontSize(24, 1.2)        # Set fontSIZE and optionally character aspect ratio
    .setColor(mark_intensity,mark_intensity,mark_intensity)             # Text color
    .setText("-5"),

group.createChild("text", "-10")
    .setTranslation(halign, BORDER + 4 * VSPACING)      # The origin is in the top left corner
    .setAlignment("right-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
    .setFont("LiberationFonts/LiberationSans-Regular.ttf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
    .setFontSize(24, 1.2)        # Set fontSIZE and optionally character aspect ratio
    .setColor(mark_intensity,mark_intensity,mark_intensity)             # Text color
    .setText("-10"),

group.createChild("text", "-15")
    .setTranslation(halign, BORDER + 5 * VSPACING)      # The origin is in the top left corner
    .setAlignment("right-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
    .setFont("LiberationFonts/LiberationSans-Regular.ttf") # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
    .setFontSize(24, 1.2)        # Set fontSIZE and optionally character aspect ratio
    .setColor(mark_intensity,mark_intensity,mark_intensity)             # Text color
    .setText("-15")
];

# Initially hidden as the radar is switched off
if (getprop("controls/radar/mode") == RADAR_MODE_OFF) {
  group.hide();
}
    
# Map a given distance and height value to a y location on the scope.
# Distance and height must be in the same units.    
var map_y = func (d, h) {
    # We'll assume that tan() is close to linear from [-15,10]
    # 0.01786 per degree
    var t =  - h / d;
    var y = (BORDER + 2*VSPACING) - (t / 0.01786) * (VSPACING / 5);
    if (y < BORDER) { y = BORDER; }
    if (y > (SIZE - BORDER)) { y = SIZE - BORDER; }      
    return y;
}

# Map a given normalized x value to an x location on the scope
var map_x = func(n) {
    # x-axis evenly distributed across space
    return BORDER + (SIZE - 2*BORDER) * n;
}

# 1000ft scribe lines, for 10nm and 20nm
var thousand10nm = 
  group.createChild("path", "radar-trace")
                    .setStrokeLineWidth(1.0)
                    .setColor(trace_intensity, trace_intensity, trace_intensity)
                    .hide();
                    
var c = [canvas.Path.VG_MOVE_TO];
var p = [map_x(0), SIZE - BORDER];
                  
for (var i = 1; i < (STEPS + 1); i+=1) {
  append(c, canvas.Path.VG_LINE_TO);
  append(p, map_x(i/STEPS));
  append(p, map_y(i * 3038, 1000));
}
                    
thousand10nm.setData(c, p);

var thousand20nm = 
  group.createChild("path", "radar-trace")
                    .setStrokeLineWidth(1.0)
                    .setColor(trace_intensity, trace_intensity, trace_intensity)
                    .hide();
var c = [canvas.Path.VG_MOVE_TO];
var p = [map_x(0), SIZE - BORDER];
                  
for (var i = 1; i < (STEPS + 1); i+=1) {
  append(c, canvas.Path.VG_LINE_TO);
  append(p, map_x(i/STEPS));
  append(p, map_y(i * 6076, 1000));
}
                    
thousand20nm.setData(c, p);

if (getprop("controls/radar/range") == 10) {
  thousand10nm.show();    
  thousand20nm.hide();
} else {
  thousand10nm.hide();
  thousand20nm.show();
}

    
#  Trace line itself
var trace = 
  group.createChild("path", "radar-trace")
                    .setStrokeLineWidth(2.0)
                    .setColor(trace_intensity, trace_intensity, trace_intensity);
                    
# We want a series of distances from the aircraft to mimic the angular
# movement of a radar head.  All values in nm.
var sweep = func {
  if ((getprop("/controls/radar/mode") == RADAR_MODE_TC) and 
      (getprop("/controls/radar/orientation") == RADAR_ORIENT_PROFILE))
  {  
    var hdg = getprop("/orientation/heading-deg");
    var height = getprop("/position/altitude-ft");
    
    # Vertical sweep is -15 degrees to + 10 degrees.  
    # Follow a scan-line for 10nm or 20nm depending on range set.
    var dx = 10 /  STEPS;
    if (range_mode > 10) {
      dx = 20 / STEPS;  
    }
    
    var p = geo.aircraft_position();
    var alt = height * 0.3048;
    var a = -0.268;
    p = p.apply_course_distance(hdg, dx * 1852);
    var cmds = [canvas.Path.VG_MOVE_TO];
    var x = BORDER;
    var y = SIZE - BORDER;
    var pts = [x, y];
      
    setprop("/sim/alarms/obst", 0.0);      
    
    for (var i = 1; i < STEPS; i+=1) {
      var h =  geo.elevation(p.lat(), p.lon());
      
      # Cover calls before the scenery is initialized
      if (h == nil) { h = alt; }
      
      # Display the OBST light if we''ve got less than 1000ft
      # clearance.
      if ((alt - h) < 305) {
        setprop("/sim/alarms/obst", 1.0);
      }
      
      # Work out the angle from the aircraft.  All units in meters
      var t = - (alt - h) / (i * dx * 1852);

      if ((i == 1) or (t < -0.268) or (t < a)) {
        # point is the first trace, out of range, or obscured by earlier terrain,
        # so ignore.
        append(cmds, canvas.Path.VG_MOVE_TO);    
      } else {
        append(cmds, canvas.Path.VG_LINE_TO); 
      }       
            
      append(pts, map_x(i/STEPS));
      append(pts, map_y((i * dx * 1852), alt - h));
      
      p.apply_course_distance(hdg, dx * 1852);    
      
      #  Set the minimum angle, below which terrain is obscured by previous returns
      a = math.max(a, t);
    }  

    trace.setData(cmds, pts);
  }
  
  settimer(sweep, 1);
}

sweep();

# Control functions
var toggleRange = func() {
  if (getprop("/controls/radar/range") > 10) {
    setprop("/controls/radar/range", 10);
  } else {
    setprop("/controls/radar/range", 20);
  }
}

# Listeners for control properties
setlistener("/controls/radar/range", func(n) {
  range_mode = n.getValue();
  if (range_mode > 10) {
    thousand10nm.hide();
    thousand20nm.show();
  } else {
    thousand10nm.show();    
    thousand20nm.hide();
  }
});

setlistener("/controls/radar/reticle-norm", func(n) {
  var i = n.getValue();
  # Set the reticle brightness.
  line1.setColor(i,i,i);
  
  # Set the text brightness
  foreach (var c; labels) {
    c.setColor(i,i,i);
  }
});

setlistener("/controls/radar/brightness-norm", func(n) {
  var i = n.getValue();
  # Set the reticle brightness.
  trace.setColor(i,i,i);
  thousand10nm.setColor(i,i,i);
  thousand20nm.setColor(i,i,i);
});


setlistener("/controls/radar/mode", func(n) {
  var i = n.getValue();
  # Switch the radar on/off as appropriate.
  if (i == RADAR_MODE_OFF) {
    group.hide();
  } else {
    group.show();  
  }
  
  # Display the trace line only if we're in TC mode
  if (i == RADAR_MODE_TC) {
    trace.show();  
  } else {
    trace.hide(); 
  }  
  
  # Rest the OBST light - it will get switched on again
  # if required.
  setprop("sim/alarms/obst", 0);
  
});
