/* keycaps */
profile = "cherry";

function mxstem() =
  profile == "cherry" ? 6.1 :
  profile == "sa" ? 6.8 :
  assert(false, "unrecognized keycap profile");


/* keyswitch */
switch_travel = 4.0;


/* MX keywell parameters */
innerdia=13.9;
outerdia=17;
thickness=4;

tab_offset = 1.2; // how far from the top the switchholders start
tab_depth = 0.6; // how far tabs stick out
tab_width = 5;

epsilon = .001; // smallest meaningful overlap

// XXX profile dependent?
function spacer() = 1.4; // how close keywells can be


/* side wall width */
wall_width=2;
wall_extra_room = [0,0]; //[5,3];

// bounds
highest_high=40;
lowest_low=60;
