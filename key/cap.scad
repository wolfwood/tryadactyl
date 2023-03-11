/* support for models of keycaps in various profiles
 * and placement functions for orienting keycaps "flat", i.e. perpendicular to the positive Z axis and centered in XY
 */


use <../settings.scad>;

include <../../KeyV2/includes.scad> // you can ignore this warning if prerendered_keycaps is true

module keycap(row=3, travel_advisory=true) {
  // KeyV2 will warn for an unsupported profile. good enough?
  //assert(profile=="cherry"||profile="sa", "unrecognized keycap profile");

  if ($preview || ! disable_keycap_render()) {
    if (is_string(row)) {
      // XXX separate modules for nav caps (and encoders)?
      if (row == "SKRH") {
	cap_len=5;
	color("red", .2) {
	  cylinder(d=6.4,h=cap_len-1);
	  translate([0,0,(cap_len-1)]) cylinder(d=8,h=1);
	}
      }
    } else {

      use_profile = profile();

      effective_row = (row >= 5) ? 5 : ((row < 1) ? 1 : row);

      show_travel() {
	if (use_profile == "lpx") {
	  translate([-1.605,-29.001,-9.02 + 2.7644]) rotate([48.5,0,90]) import("prerendered/LPX/LPX.stl");
	}else if (prerendered_keycaps()) {
	  import(str("prerendered","/",use_profile,"/",row,".stl"));
	} else {
	  blank() key_profile(use_profile, effective_row)
	    if ($preview && fast_keycap_preview()) {
	      key($fn=6);
	    } else if (! $preview&& fast_keycap_render()) {
	      key($fn=60);
	    } else {
	      key();
	    }
	}
      }
    }
  }

  module show_travel() {
    how_low = switch_travel();
    children();
    if (travel_advisory && $preview) {
      color("yellow", 0.25) translate([0,0,-how_low]) linear_extrude(how_low) projection() children();
    }
  }
}


module cherry_position_flat(row) {
  assert(row > 0 && row < 5 );

  if (row == 1) {
    translate([0,-2.032,-9.2]) rotate([0,0,0]) children();
  } else if (row == 2) {
    translate([0,-1.71,-6.93]) rotate([2.5,0,0]) children();
  } else if (row == 3) {
    translate([0,-1.47,-6.1]) rotate([5,0,0]) children();
  } else { // if (row == 4) {
    translate([0,-.615,-7.011]) rotate([11.5,0,0]) children();
  }
}

module lpx_position_flat(row) {
  //assert(row > 0 && row < 5 );

  translate ([0,0,-2.7644]) children();
}

/* use this to dial in *_position_flat() for each row
 *  first lower the Z height of the switch until the origin sits on its top face
 *  next adjust rotation, using a side view, until the top face of the switch is level. then you may need to go back
 *   and tweak the Z. raise the keycap until the X and Y axes and scale markers disappear, then lower until they
 *   just become visible, using at least 2 decimal digits
 *  finally, select a top view and then lower the Y to center the origin on the top face
 */
let(row=1,$profile="cherry") {
  position_flat(row) keycap($fast_keycap_preview=true, $prerendered_keycaps=false, row);
}


// wish I had macros right about now ;)
module position_flat(row) {
  use_profile = profile();

  // strings override global profile row numbers
  if (is_string(row) && row == "SKRH") {
    // XXX should navcaps have custom *_position_flat() modules?
    translate ([0,0,-5+1]) children();
  } else if (use_profile == "cherry") {
    cherry_position_flat(row) children();
  } else if (use_profile == "lpx") {
    lpx_position_flat(row) children();
  } else if (use_profile == "sa") {
    sa_position_flat(row) children();
  } else if (use_profile == "dsa") {
    dsa_position_flat(row) children();
  } else if (use_profile == "oem") {
    oem_position_flat(row) children();
  } else if (use_profile == "dcs") {
    dcs_position_flat(row) children();
  } else if (use_profile == "g20") {
    g20_position_flat(row) children();
  } else if (use_profile == "dss") {
    dss_position_flat(row) children();
  } else if (use_profile == "hipro") {
    hipro_position_flat(row) children();
  } else if (use_profile == "grid") {
    grid_position_flat(row) children();
  } else {
    assert(false, "unknown keycap profile");
  }
}

/* most keycap profiles have 4 (cherry) or 5 distinct rows, and double up the top and bottom row if needed.
 *  (some profiles count bottom up, rather than top down, we always count top down, as does KeyV2, I believe)
 * this is a rough heuristic to use to meet the following common cases:
 *  - alphas only, "30%"ish; 3 rows with homerow as 1 (counting from 0): R2, *R3, R4
 *  - alphas and symbols/mods below, "40%"ish; 4 rows with homerow as 1: R2, *R3, R4, R5
 *  - alphanumeric, "60%"ish; 4 rows with homerow as 2 :  R1, R2, *R3, R4
 *  - alphanumeric+function keys, "TKL"; 5 rows with homerow as 3 : R1, R1, R2, *R3, R4
 *  - alphanumeric and symbols/mods below, "ergodox"; 5 rows with homerow as 2 : R1, R2, *R3, R4, R5
 *  - alphanumeric+function keys and symbols/mods below; 6 rows with homerow as 3 : R1, R1, R2, *R3, R4, R5
 *
 *  rather than shoehorning other layouts in, it's reccomended to define a new function
 *   and pass it as a function literal to effective_rows()
 */
function effective_row(row,maxrows=4,homerow=2,col=0) =
  let (effective = 3 + (row - (homerow+1)))
  profile_is_uniform() ? 1 :
  profile() == "cherry" && effective > 4 ? 4 :
  effective > 5 ? 5 :
  effective < 1 ? 1 :
  effective;


/* make a vector of the appropriate keycap profile row for each key row of a full column
 *  for something like SA R3, where only a single row of the profile is used for all keys,
 *  just pass the number 3 instead of using this function to make a vector
 */
function effective_rows(maxrows=4, homerow=2, func=function (r,m,h) effective_row(r,m,h)) =
  profile_is_uniform() ? 1 :
  [ for(i=[1:maxrows]) func(i, maxrows, homerow) ];

//echo(effective_rows(4,3, function (r,m,h) effective_row(r,m,h)));
