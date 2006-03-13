
# ==================================== timer stuff ===========================================

# set the update period

UPDATE_PERIOD = 0.3;

# set the timer for the selected function

registerTimer = func {
	
    settimer(arg[0], UPDATE_PERIOD);

} # end function 

# =============================== end timer stuff ===========================================

# =============================== Gear stuff======================================

caster_angle = props.globals.getNode("gear/gear/caster-angle-deg", 1);
roll_speed = props.globals.getNode("gear/gear/rollspeed-ms", 1);
wow = props.globals.getNode("gear/gear/wow", 1);
timeratio = props.globals.getNode("gear/gear/timeratio", 1);
caster_angle_damped = props.globals.getNode("gear/gear/caster-angle-deg-damped", 1);

caster_angle.setDoubleValue(0); 
roll_speed.setDoubleValue(0); 
timeratio.setDoubleValue(0.1); 
caster_angle_damped.setDoubleValue(0);
wow.setBoolValue(1); 

angle_damp = 0;

updateCasterAngle = func {
		var n = timeratio.getValue(); 
		var angle = caster_angle.getValue() ;
		var speed = roll_speed.getValue();
		var _wow = wow.getValue();
		
		if ( _wow ) {  
		  n = (0.02 * speed) + 0.001;
		} else {
		  n = 0.5;
		}
		
		angle_damp = ( angle * n) + (angle_damp * (1 - n));
		
		caster_angle_damped.setDoubleValue(angle_damp);
		timeratio.setDoubleValue(n); 

# print(sprintf("caster_angle_damped in=%0.5f, out=%0.5f", angle, angle_damp));
        
        settimer(updateCasterAngle, 0.1);

} #end func updateCasterAngle()

#fire it up
updateCasterAngle();

tailwheel_lock = props.globals.getNode("/controls/gear/tailwheel-lock", 1);
launchbar_state = props.globals.getNode("/gear/launchbar/state", 1);

tailwheel_lock.setDoubleValue(1);
launchbar_state.setValue("Disengaged");  

updateTailwheelLock = func {
		var lock = tailwheel_lock.getValue(); 
		var state = launchbar_state.getValue() ;
		
		if ( state != "Disengaged" ) {   
		  lock = 0;
		} else {
		  lock = 1;
		}
		
		tailwheel_lock.setDoubleValue(lock);
		
# print("tail-wheel-lock " , lock , " state " , state);
        
} #end func updateTailwheelLock()

setlistener( launchbar_state , updateTailwheelLock ());

#setlistener("gear/launchbar/strop", func { print("New strop: " ~ cmdarg().getValue()) }); 


# ======================================= end Gear stuff ============================



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

# ================================== Chute Stuff ===========================================

chute_control = props.globals.getNode("controls/flight/drag-chute/state", 1);
chute_state = props.globals.getNode("surface-positions/drag-chute/state", 1);
chute_release = props.globals.getNode("controls/flight/drag-chute/release", 1);
chute_lever = props.globals.getNode("controls/flight/drag-chute/lever", 1);
chute_weight = props.globals.getNode("yasim/weights/drag-chute", 1);
aircraft_speed = props.globals.getNode("velocities/airspeed-kt", 1);
aircraft_pitch_deg = props.globals.getNode("orientation/pitch-deg", 1);
aircraft_roll_deg = props.globals.getNode("orientation/roll-deg", 1);
aircraft_yaw_deg = props.globals.getNode("orientation/side-slip-deg", 1);
chute_pitch_deg = props.globals.getNode("orientation/chute/pitch-deg", 1);
chute_roll_deg = props.globals.getNode("orientation/chute/roll-deg", 1);
chute_yaw_deg = props.globals.getNode("orientation/chute/yaw-deg", 1);


chute_control.setValue("ready");
chute_state.setValue("ready");
chute_release.setBoolValue(0);
chute_lever.setBoolValue(0);
chute_pitch_deg.setDoubleValue(0);
chute_roll_deg.setDoubleValue(0);
chute_yaw_deg.setDoubleValue(0);
var wait = 2;
var chuteyawdamp = 0;


updateControlState = func{
	var chutelever = chute_lever.getValue();
	
	if (chutelever == 1) {
		chute_control.setValue("open");
	}
	
} #end func
		

updateChuteState = func {
  var chutecontrol = chute_control.getValue();
	var chutestate = chute_state.getValue();
	var chuterelease = chute_release.getValue();		
	
#	print ("chutecontrol " , chutecontrol , " wait " , wait ," chutestate " , chutestate , " release " ,chuterelease );
	
	if ( chutecontrol == "open" and chutestate == "ready" ){
			chute_state.setValue("deployed");
			chute_weight.setDoubleValue(1); #use for weight/drag YASim implementatiom
			settimer(updateChuteState, wait);
			return;
	} elsif(chutecontrol == "open" and chutestate == "deployed" ) {
			chute_state.setValue("opened");
			updateOverSpeed();
			return;
	} elsif (chutecontrol == "open" ){
		chute_control.setValue("ready");
		return;
	}
	
	if ( chutecontrol == "jettison" and chutestate != "ready" ){
	    chute_release.setBoolValue(1);
			chute_state.setValue("jettisoned");
			chute_lever.setDoubleValue(0);
			chute_weight.setDoubleValue(0);
			return;
	} elsif ( chutecontrol == "jettison" ){
			chute_control.setValue("ready");
			return;
	}
	
	if ( chutecontrol == "repack" and chutestate == "jettisoned"){
			chute_state.setValue("ready");
			chute_control.setValue("ready");
			chute_release.setBoolValue(0);
			chute_weight.setDoubleValue(0);
			#wait = 5;
	} elsif (chutecontrol == "repack" and 
					( chutestate == "deployed" or chutestate == "opened") ) {
			chute_control.setValue("open");
			return;
	} elsif (chutecontrol == "repack"){
			chute_control.setValue("ready");
	}
		
} # end function


calculateChuteAngle = func{

	var aircraftpitch = aircraft_pitch_deg.getValue() ;
	var aircraftroll = aircraft_roll_deg.getValue() ;
	var aircraftyaw = aircraft_yaw_deg.getValue() ;
	var n = 0.01;
	
#	print ("acyaw " , aircraftyaw); 
	
	if (aircraftyaw == nil) {aircraftyaw = 0;}
		
	chuteyawdamp = ( aircraftyaw * n) + ( chuteyawdamp * (1 - n));
	
	chute_pitch_deg.setDoubleValue(aircraftpitch * -1);
	chute_roll_deg.setDoubleValue(aircraftroll);
	chute_yaw_deg.setDoubleValue(chuteyawdamp);
	settimer(calculateChuteAngle, 0);
		
} # end func	


updateOverSpeed = func {

	var chutestate = chute_state.getValue();
	var speed = aircraft_speed.getValue();
	
 #print ("acspeed " , speed); 
 
	if (speed > 210 and chutestate == "opened") {# Model Shear Pin
			chute_control.setValue("jettison");
			return;
	}
	
	settimer(updateOverSpeed, 0.3);
	
} # end func


# fire it all up

calculateChuteAngle();
setlistener( chute_lever , updateControlState);	
setlistener( chute_control , updateChuteState);	

		
# ================================== End Chute Stuff =====================================	

# end 
