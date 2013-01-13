
# Update period for systems loop
UPDATE_PERIOD = 0.2;


# =============================== Pilot G stuff======================================

pilot_g = props.globals.getNode("accelerations/pilot-g", 1);
timeratio = props.globals.getNode("accelerations/timeratio", 1);
pilot_g_damped = props.globals.getNode("accelerations/pilot-g-damped", 1);

pilot_g.setDoubleValue(0);
pilot_g_damped.setDoubleValue(0);
timeratio.setDoubleValue(0.03);

var g_damp = 0;

updatePilotG = func {
        var n = timeratio.getValue();
	var g = pilot_g.getValue() ;

	g_damp = ( g * n) + (g_damp * (1 - n));

	pilot_g_damped.setDoubleValue(g_damp);

# print(sprintf("pilot_g_damped in=%0.5f, out=%0.5f", g, g_damp));

        settimer(updatePilotG, 0.1);

} #end updatePilotG()

updatePilotG();

# headshake - this is a modification of the original work by Josh Babcock

# Define some stuff with global scope

xConfigNode = '';
yConfigNode = '';
zConfigNode = '';

xAccelNode = '';
yAccelNode = '';
zAccelNode = '';

var xDivergence_damp = 0;
var yDivergence_damp = 0;
var zDivergence_damp = 0;

var last_xDivergence = 0;
var last_yDivergence = 0;
var last_zDivergence = 0;

# Make sure that some vital data exists and set some default values
enabledNode = props.globals.getNode("/sim/headshake/enabled", 1);
enabledNode.setBoolValue(1);

xMaxNode = props.globals.getNode("/sim/headshake/x-max-m",1);
xMaxNode.setDoubleValue( 0.025 );

xMinNode = props.globals.getNode("/sim/headshake/x-min-m",1);
xMinNode.setDoubleValue( -0.01 );

yMaxNode = props.globals.getNode("/sim/headshake/y-max-m",1);
yMaxNode.setDoubleValue( 0.01 );

yMinNode = props.globals.getNode("/sim/headshake/y-min-m",1);
yMinNode.setDoubleValue( -0.01 );

zMaxNode = props.globals.getNode("/sim/headshake/z-max-m",1);
zMaxNode.setDoubleValue( 0.01 );

zMinNode = props.globals.getNode("/sim/headshake/z-min-m",1);
zMinNode.setDoubleValue( -0.03 );

view_number_Node = props.globals.getNode("/sim/current-view/view-number",1);
view_number_Node.setDoubleValue( 0 );

time_ratio_Node = props.globals.getNode("/sim/headshake/time-ratio",1);
time_ratio_Node.setDoubleValue( 0.003 );

seat_vertical_adjust_Node = props.globals.getNode("/controls/seat/vertical-adjust",1);
seat_vertical_adjust_Node.setDoubleValue( 0 );

xThreasholdNode = props.globals.getNode("/sim/headshake/x-threashold-g",1);
xThreasholdNode.setDoubleValue( 0.5 );

yThreasholdNode = props.globals.getNode("/sim/headshake/y-threashold-g",1);
yThreasholdNode.setDoubleValue( 0.5 );

zThreasholdNode = props.globals.getNode("/sim/headshake/z-threashold-g",1);
zThreasholdNode.setDoubleValue( 0.5 );

# We will use these later
xConfigNode = props.globals.getNode("/sim/view/config/z-offset-m");
yConfigNode = props.globals.getNode("/sim/view/config/x-offset-m");
zConfigNode = props.globals.getNode("/sim/view/config/y-offset-m");

xAccelNode = props.globals.getNode("/accelerations/pilot/x-accel-fps_sec",1);
xAccelNode.setDoubleValue( 0 );
yAccelNode = props.globals.getNode("/accelerations/pilot/y-accel-fps_sec",1);
yAccelNode.setDoubleValue( 0 );
zAccelNode = props.globals.getNode("/accelerations/pilot/z-accel-fps_sec",1);
zAccelNode.setDoubleValue(-32 );


headShake = func {

    # First, we don't shake outside the vehicle. Inside, we boogie down.
    # There are two coordinate systems here, one used for accelerations, and one used for the viewpoint.
    # We will be using the one for accelerations.
    var enabled = enabledNode.getValue();
    var view_number= view_number_Node.getValue();
    var n = timeratio.getValue();
    var seat_vertical_adjust = seat_vertical_adjust_Node.getValue();


    if ( (enabled) and ( view_number == 0)) {

	var xConfig = xConfigNode.getValue();
        var yConfig = yConfigNode.getValue();
        var zConfig = zConfigNode.getValue();

        var xMax = xMaxNode.getValue();
        var xMin = xMinNode.getValue();
        var yMax = yMaxNode.getValue();
        var yMin = yMinNode.getValue();
        var zMax = zMaxNode.getValue();
        var zMin = zMinNode.getValue();

	#work in G, not fps/s
        var xAccel = xAccelNode.getValue()/32;
        var yAccel = yAccelNode.getValue()/32;
        var zAccel = (zAccelNode.getValue() + 32)/32; # We aren't counting gravity

	var xThreashold =  xThreasholdNode.getValue();
	var yThreashold =  yThreasholdNode.getValue();
	var zThreashold =  zThreasholdNode.getValue();

        # Set viewpoint divergence and clamp
        # Note that each dimension has it's own special ratio and +X is clamped at 1cm
        # to simulate a headrest.

        if (xAccel < -1) {
            xDivergence = ((( -0.0506 * xAccel ) - ( 0.538 )) * xAccel - ( 0.9915 )) * xAccel - 0.52;
        } elsif (xAccel > 1) {
            xDivergence = ((( -0.0387 * xAccel ) + ( 0.4157 )) * xAccel - ( 0.8448 )) * xAccel + 0.475;
        }else {
	    xDivergence = 0;
	}
#        setprop("/sim/current-view/z-offset-m", (xConfig + xDivergence));

        if (yAccel < -0.5) {
            yDivergence = ((( -0.013 * yAccel ) - ( 0.125 )) * yAccel - (  0.1202 )) * yAccel - 0.0272;
            } elsif (yAccel > 0.5) {
            yDivergence = ((( -0.013 * yAccel ) + ( 0.125 )) * yAccel - (  0.1202 )) * yAccel + 0.0272;
        }else {
	    yDivergence = 0;
	}
#        setprop("/sim/current-view/x-offset-m", (yConfig + yDivergence));

        if (zAccel < -1) {
	    zDivergence = ((( -0.0506 * zAccel ) - ( 0.538 )) * zAccel - ( 0.9915 )) * zAccel - 0.52;
        } elsif (zAccel > 1) {
            zDivergence = ((( -0.0387 * zAccel ) + ( 0.4157 )) * zAccel - ( 0.8448 )) * zAccel + 0.475;
	} else {
	    zDivergence = 0;
        }


	xDivergence_total = ( xDivergence * 0.25 ) + ( zDivergence * 0.25 );
	if (xDivergence_total > xMax){xDivergence_total = xMax;}
        if (xDivergence_total < xMin){xDivergence_total = xMin;}

	if (abs(last_xDivergence - xDivergence_total) <= xThreashold){
	        xDivergence_damp = ( xDivergence_total * n) + ( xDivergence_damp * (1 - n));
	#	print ("x low pass");
	} else {
		xDivergence_damp = xDivergence_total;
	#	print ("x high pass");
	}

	last_xDivergence = xDivergence_damp;

#print (sprintf("x total=%0.5f, x min=%0.5f, x div damped=%0.5f", xDivergence_total, xMin , xDivergence_damp));

	yDivergence_total = yDivergence;
        if (yDivergence_total >= yMax){yDivergence_total = yMax;}
        if (yDivergence_total <= yMin){yDivergence_total = yMin;}

	if (abs(last_yDivergence - yDivergence_total) <= yThreashold){
		yDivergence_damp = ( yDivergence_total * n) + ( yDivergence_damp * (1 - n));
       	# 	print ("y low pass");
	} else {
		yDivergence_damp = yDivergence_total;
	#	print ("y high pass");
	}

	last_yDivergence = yDivergence_damp;

#print (sprintf("y=%0.5f, y total=%0.5f, y min=%0.5f, y div damped=%0.5f",yDivergence, yDivergence_total, yMin , yDivergence_damp));

	zDivergence_total =  xDivergence + zDivergence;
        if (zDivergence_total >= zMax){zDivergence_total = zMax;}
        if (zDivergence_total <= zMin){zDivergence_total = zMin;}

	if (abs(last_zDivergence - zDivergence_total) <= zThreashold){
        	zDivergence_damp = ( zDivergence_total * n) + ( zDivergence_damp * (1 - n));
        #        print ("z low pass");
	} else {
		zDivergence_damp = zDivergence_total;
	#	print ("z high pass");
	}

	last_zDivergence = zDivergence_damp;

#print (sprintf("z total=%0.5f, z min=%0.5f, z div damped=%0.5f", zDivergence_total, zMin , zDivergence_damp));

	setprop("/sim/current-view/z-offset-m", xConfig + xDivergence_damp );
        setprop("/sim/current-view/x-offset-m", yConfig + yDivergence_damp );
	setprop("/sim/current-view/y-offset-m", zConfig + zDivergence_damp + seat_vertical_adjust );
    }
    settimer(headShake,0 );

}

headShake();
# ======================================= end Pilot G stuff ============================


# Weapons handling
var master = props.globals.getNode("controls/armament/master", 1);
var gun = props.globals.getNode("controls/armament/guns", 1);
var fire_cannon = props.globals.getNode("controls/armament/trigger-cannon", 1);
var nosetail = props.globals.getNode("controls/armament/nose-tail", 1);
var function_select = props.globals.getNode("controls/armament/function-select", 1);
var emergency_function_select = props.globals.getNode("controls/armament/emergency-function-select", 1);
var stations = props.globals.getNode("/sim").getChildren("weight");


setlistener("/controls/armament/trigger", func(n) {
  if (master.getValue()) {
	if (gun.getValue()) {
	  fire_cannon.setBoolValue(n.getValue());
	}

	if (function_select.getValue() == 1) {
	  # Rockets armed
	  foreach (var station; stations) {
		if (station.getNode("enabled", 1).getValue() == 1)
		{
		  station.getNode("trigger-rocket", 1).setBoolValue(n.getValue());
		}
	  }
	}
  }
});

setlistener("/controls/armament/bomb", func(n) {
  if (master.getValue()) {
	if ((function_select.getValue() == 5) and (nosetail.getValue() != 0)) {
	  # Bombs armed
	  foreach (var station; stations) {
		if (station.getNode("enabled", 1).getValue() == 1)
		{
		  station.getNode("trigger-bomb", 1).setBoolValue(n.getValue());
		}
	  }
	}
  }
});

var station_handler = func(n) {
  var isBomb = (n.getName() == "trigger-bomb") ? 1 : 0;
  var station = n.getParent();
  var type = station.getChild("selected").getValue();
  var mass = station.getChild("weight-lb");
  var trigger = nil;
  var count = nil;
  var load_mass = nil;

  
  if (isBomb) {
    trigger = station.getNode(type, 1).getChild("trigger-bomb");
    count = station.getNode("bomb-count",1);
    load_mass = station.getNode("bomb-load-mass-lb",1).getValue();
  } else {
    trigger = station.getNode(type, 1).getNode("trigger-rocket", 1);
    count = station.getNode("rocket-count", 1);
    load_mass = station.getNode("rocket-load-mass-lb", 1).getValue();  
  }
    
  if ((n.getValue() == 1) and (count != nil) and (count.getValue() > 0)) {
    # Trigger attempt with at least one left
    count.setIntValue(count.getValue() - 1);
    mass.setValue(math.max(mass.getValue() - load_mass, 0));
    trigger.setValue(1);  
  }  
  else if (! n.getValue())  {
    # Trigger release
    trigger.setValue(0);  
  }  
}

setlistener("/sim/weight[0]/trigger-bomb", station_handler);
setlistener("/sim/weight[1]/trigger-bomb", station_handler);
setlistener("/sim/weight[2]/trigger-bomb", station_handler);
setlistener("/sim/weight[3]/trigger-bomb", station_handler);
setlistener("/sim/weight[4]/trigger-bomb", station_handler);

setlistener("/sim/weight[0]/trigger-rocket", station_handler);
setlistener("/sim/weight[1]/trigger-rocket", station_handler);
setlistener("/sim/weight[2]/trigger-rocket", station_handler);
setlistener("/sim/weight[3]/trigger-rocket", station_handler);
setlistener("/sim/weight[4]/trigger-rocket", station_handler);


var loadout_handler = func(n) {
  var type = n.getValue();
  var station = n.getParent();
  var template = props.globals.getNode("/armament/templates").getChild(type);
  
  if (template != nil) {
    props.copy(template, station, 1);  
  }
}

setlistener("/sim/weight[0]/selected", loadout_handler);
setlistener("/sim/weight[1]/selected", loadout_handler);
setlistener("/sim/weight[2]/selected", loadout_handler);
setlistener("/sim/weight[3]/selected", loadout_handler);
setlistener("/sim/weight[4]/selected", loadout_handler);

# controls.nas overrides.

# No manual spoiler control. This only arms the spoilers.
controls.stepSpoilers = func(step) {
	if (step > 0) {
		spoilers_armed.setValue(1);
	} else {
		spoilers_armed.setValue(0);
	}
}

# Flaps have no detents.
var flaps = props.globals.getNode("/controls/flight/flaps");
var delta = props.globals.getNode("/sim/time/delta-realtime-sec");
controls.flapsDown = func(step) {
	flaps.setValue(flaps.getValue() + step * 0.33 * delta.getValue());
}

# But should be repeatable
var keys = props.globals.getNode("/input/keyboard").getChildren("key");
foreach (var key; keys) {
	var script = key.getNode("binding/script");
	if ((script != nil) and 
            ((script.getValue() == "controls.flapsDown(1)") or
             (script.getValue() == "controls.flapsDown(-1)")  ))
	{
		key.getNode("repeatable", 1).setValue("true");
	}
}

var sticks = props.globals.getNode("/input/joysticks").getChildren("js");
foreach (var js; sticks) {
	var buttons = js.getChildren("button");
	foreach (var button; buttons) {
		var script = button.getNode("binding/script");
		if ((script != nil) and 
        	    ((script.getValue() == "controls.flapsDown(1)") or
	             (script.getValue() == "controls.flapsDown(-1)")  ))
		{
			button.getNode("repeatable", 1).setValue("true");
		}
	}
}

# Gear cannot be raised if wow on left main strut
var gear_pos = props.globals.getNode("gear/gear[0]/position-norm", 1);
controls.gearDown = func(v) {
    if ((v < 0) and (getprop("/gear/gear[1]/wow") == 0)) {
		setprop("/controls/gear/gear-down", 0);
    } elsif (v > 0) {
		setprop("/controls/gear/gear-down", 1);
    }
}

