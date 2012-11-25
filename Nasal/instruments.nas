# Instrumentation Nasal


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

  settimer(instrumentLoop, 1.0);
}


instrumentLoop();
