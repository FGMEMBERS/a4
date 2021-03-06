# Instrumentation Nasal

# INS mode switch constants
var INS_MODE_TEST = 0;
var INS_MODE_OFF = 1;
var INS_MODE_STBY = 2;
var INS_MODE_D1 = 3;
var INS_MODE_D2 = 4;

# UHF frequency select constants
var UHF_FREQ_PRESET = 0;
var UHF_FREQ_MANUAL = 1;
var UHF_FREQ_GOXMIT = 2;

# UHF frequency modes
var UHF_MODE_OFF = 0;
var UHF_MODE_TR  = 1;
var UHF_MODE_TRG = 2;
var UHF_MODE_ADF = 3;

# One-second Nasal loop for simple instrumentation calcs.
var instrumentLoop = func() {

  # Drift indicator.
  var drift_mode = getprop("/controls/instrumentation/drift-indicator-mode");
  if ((drift_mode != nil) and ((drift_mode == 2) or (drift_mode == 3))) {
    # Convert to range (-180, +180);
    var drift = getprop("/orientation/track-deg") - getprop("/orientation/heading-deg") + 180;    
    drift = math.mod(drift, 360) - 180;
    setprop("/instrumentation/drift-angle-deg", drift);    
  } else {
    setprop("/instrumentation/drift-angle-deg", 0);      
  }  
  
  if (getprop("controls/instrumentation/bhdi-mode") == 0) {
    setprop("/instrumentation/bhdi/dist-nm", getprop("/instrumentation/ins/set-dist-nm"));
  } else if (getprop("controls/instrumentation/tacan-mode") == 2) {
    # TACAN only provides distance information in T/R position
    setprop("/instrumentation/bhdi/dist-nm", getprop("/instrumentation/tacan/indicated-distance-nm"));
  } else {
    setprop("/instrumentation/bhdi/dist-nm", 0);  
  }
  
  settimer(instrumentLoop, 1.0);
}

# 10 second Nasal loop for more intensive INS calcs.
var insLoop = func() {

  if (getprop("/controls/instrumentation/ins/mode") > INS_MODE_STBY) {
    var dest = geo.Coord.new();
    dest.set_latlon(
      getprop("/controls/instrumentation/ins/current-destination/latitude-deg"),
      getprop("/controls/instrumentation/ins/current-destination/longitude-deg"));
      
    var pos = geo.aircraft_position();      
    setprop("/instrumentation/ins/set-course-deg", pos.course_to(dest));
    setprop("/instrumentation/ins/set-dist-nm", pos.distance_to(dest) * globals.M2NM);
  }

  settimer(insLoop , 3.0);
}

# UHF Preset controls
setlistener("/controls/instrumentation/uhf/preset-channel", func(n) {
  var i = n.getValue();
  
  # If we're in the Preset mode, then change the current COMM1 active
  # channel to the preset value.
  if (getprop("/controls/instrumentation/uhf/freq-select") == UHF_FREQ_PRESET) {
    var p = "/controls/instrumentation/uhf/preset-channels/channel[" ~ i ~ "]";
    var freq = getprop(p);
    setprop("/instrumentation/comm/frequencies/selected-mhz", freq);  
  }
});

# Link COMM1 UHF frequency to the ADF if required 
setlistener("/instrumentation/comm/frequencies/selected-mhz", func(n) {
  var i = n.getValue();
  
  if (getprop("/controls/instrumentation/uhf/mode") == UHF_MODE_ADF) {
    #  We assume that the value is scaled by a factor of 1000.
    setprop("/instrumentation/adffrequencies/selected-khz", i);  
  }
});

setlistener("/controls/instrumentation/uhf/freq-select", func(n) {
  var i = n.getValue();
  
  if (i == UHF_FREQ_PRESET) {
    var c = getprop("/controls/instrumentation/uhf/preset-channel");
    var p = "/controls/instrumentation/uhf/preset-channels/channel[" ~ c ~ "]";
    var freq = getprop(p);
    setprop("/instrumentation/comm/frequencies/selected-mhz", freq);  
  }

  if (i == UHF_FREQ_MANUAL) {
    var freq = getprop("/controls/instrumentation/uhf/manual-channel");
    setprop("/instrumentation/comm/frequencies/selected-mhz", freq);  
  }

});

setlistener("/controls/instrumentation/uhf/manual-channel", func(n) {
  var freq = n.getValue();

  if (getprop("/controls/instrumentation/uhf/freq-select") == UHF_FREQ_MANUAL) {
    setprop("/instrumentation/comm/frequencies/selected-mhz", freq);  
  }
});


# INS Destination Controls
setlistener("/controls/instrumentation/ins/mode", func(n) {
  var i = n.getValue();
  
  if (i == INS_MODE_D1) {
    # D1 selected, so swap in the D1 value
    setprop("/controls/instrumentation/ins/current-destination/latitude-deg",
            getprop("/controls/instrumentation/ins/d1/latitude-deg"));
    
    setprop("/controls/instrumentation/ins/current-destination/longitude-deg",
            getprop("/controls/instrumentation/ins/d1/longitude-deg"));  
  }

  if (i == INS_MODE_D2) {
    # D1 selected, so swap in the D1 value
    setprop("/controls/instrumentation/ins/current-destination/latitude-deg",
            getprop("/controls/instrumentation/ins/d2/latitude-deg"));
    
    setprop("/controls/instrumentation/ins/current-destination/longitude-deg",
            getprop("/controls/instrumentation/ins/d2/longitude-deg"));  
  }
});

setlistener("/controls/instrumentation/ins/current-destination/latitude-deg", func(n) {
  var i = n.getValue();  
  var mode = getprop("/controls/instrumentation/ins/mode");
  
  if (mode == INS_MODE_D1) { setprop("/controls/instrumentation/ins/d1/latitude-deg", i); }
  if (mode == INS_MODE_D2) { setprop("/controls/instrumentation/ins/d2/latitude-deg", i); }
});

setlistener("/controls/instrumentation/ins/current-destination/longitude-deg", func(n) {
  var i = n.getValue();  
  var mode = getprop("/controls/instrumentation/ins/mode");
  
  if (mode == INS_MODE_D1) { setprop("/controls/instrumentation/ins/d1/longitude-deg", i); }
  if (mode == INS_MODE_D2) { setprop("/controls/instrumentation/ins/d2/longitude-deg", i); }
});

instrumentLoop();
insLoop();

# GUI over-rides for the radio dialog.
var radio_dialog = gui.Dialog.new("/sim/gui/dialogs/a4/radio/dialog",
				  "Aircraft/a4/Dialogs/radios.xml");

# GUI over-rides for the radio dialog.
var ins_dialog = gui.Dialog.new("/sim/gui/dialogs/a4/ins/dialog",
				  "Aircraft/a4/Dialogs/ins.xml");

gui.menuBind("radio", "a4_instruments.radio_dialog.open();");
