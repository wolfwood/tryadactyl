/* utilities shared by columns */

use <../settings.scad>;
use <../key/cap.scad>;

/* utility for making case walls */
module drop(){
  hull() {
    children();
    translate([0,0,-lowest_low()]) linear_extrude(height=1) projection() children();
 }
}


/* rotations:
 *  - tilt is for rotation of the each finger's columns relative to each other and is compensated for by walls
 *  - tent is applied after final positioning to the keyboard as a whole
 * positions:
 *  - displacement is used to refine row and column placement of keys, trackpoints and mountings.
 *     e.g. for a circulare placement an x or y displacement follows the curvature rather than
 *     happening before placement
 * - offsets are used after placement to adjust relative position of columns, but happens before x and y tilt
 * - position is used to do final positioning of groups of columns
 */

function layout_placement_params(row_spacing, col_spacing, profile_rows, homerow=2, homecol=0, tent=[0,0,0], tilt=[0,0,0], position=[0,0,0], offsets=[0,0,0], displacement=[0,0,0], row_first=false) =
  [[row_spacing_enum, row_spacing],
   [col_spacing_enum, col_spacing],
   [profile_rows_enum, profile_rows],
   [homerow_enum, homerow],
   [homecol_enum, homecol],
   [tilt_enum, tilt],
   [offsets_enum, offsets],
   [displacement_enum, displacement],
   [position_enum, position],
   [tent_enum, tent],
   [row_first_enum,row_first]
   ];

/* :/ these variables aren't exported with `use` so params is effectively opaque in intervening functions
 *    if callers seem to need access it probably means layout_placement needs to be enhanced instead
 */
row_spacing_enum = "a";
col_spacing_enum = "b";
profile_rows_enum = "c";
homerow_enum = "d";
homecol_enum = "e";
tilt_enum = "f";
offsets_enum = "g";
displacement_enum = "h";
position_enum = "i";
tent_enum = "j";
row_first_enum = "k";

/* variables are not exported when we `use` this file, so we make a this a function */
function default_layout_placement_params() =
  layout_placement_params(row_spacing=create_flat_placement(outerdia()+2*spacer()),
			  col_spacing=create_flat_placement(outerdia()+spacer()),
			  profile_rows=effective_rows());

/* it would be possible to treat enums as integers and use them as array indexes, but then there is the risk of
 *  off-by-one errors as keys are added and removed which might not be immediately obvious. I think a hashtable
 *  will more robust as code evolves, and the performance costs are negligible in the face of render overheads */
function match(key, params) = params[search(key,params)[0]][1];
function match_override(key, params, override) = !is_undef(override) ? override : match(key,params);

module get_homes(params, homerow,homecol, col) {
  $homerow = optional_index(match_override(homerow_enum, params, homerow), col);
  $homecol = match_override(homecol_enum, params, homecol);

  children();
}

function get_homerow(params, homerow, col) = optional_index(match_override(homerow_enum, params, homerow), col);

// for the rare case we don't want any translation, we only want to be oriented at the same angle
module rotation_only(row, col, tilt, tent, params=default_layout_placement_params()) {
  let(tent = match_override(tent_enum, params, tent),
      tilt = optional_vector_index(match_override(tilt_enum, params, tilt), col, row)){
    rotate([0,tent.y,0])
      rotate([tent.x,0,0])
      rotate([0,0,tent.z])
      rotate([0,tilt.y,0])
      rotate([tilt.x,0,0])
      rotate([0,0,tilt.z])
      children();
  }
}

// this cancels out the rotations, giving the effect of translation only
module reverse_rotation(row, col, tilt, tent, params=default_layout_placement_params()) {
  let(tent = match_override(tent_enum, params, tent),
      tilt = optional_vector_index(match_override(tilt_enum, params, tilt), col, row)){
    rotate([0,0,-tilt.z])
      rotate([-tilt.x,0,0])
      rotate([0,-tilt.y,0])
      rotate([0,0,-tent.z])
      rotate([-tent.x,0,0])
      rotate([0,-tent.y,0])
      children();
  }
}


// private, but external so we don't accidentally inherit an undeclared parameter from layout_placements()'s scope
// **plz don't use**, we just need this because of the rare case (thumb clusters) where we might want to place keys
//  around a sphere on the X-Y plane instead of Y-Z
module place_row_and_or_col(row, col, row_spacing, col_spacing, homecol, homerow, corners, displacement, row_first=false,reverse=false){
  if(!row_first){
      place_row(row, col, row_spacing, homerow, corners=corners, displacement=displacement, reverse=reverse)
	place_col(row, col, col_spacing, homecol, homerow, corners=corners, displacement=displacement, reverse=reverse)
	children();
  } else {
    place_col(row, col, col_spacing, homecol, homerow, corners=corners, displacement=displacement, reverse=reverse)
      place_row(row, col, row_spacing, homerow, corners=corners, displacement=displacement, reverse=reverse)
      children();
  }
}

module layout_placement(row, col,
			row_spacing, col_spacing, profile_rows, homerow, homecol, tilt, tent, offsets,
			displacement=[0,0,0],
	 		params=default_layout_placement_params(),
	 	        corners=false, flatten=true, stay_upright=false) {

  let(row_spacing = match_override(row_spacing_enum, params, row_spacing),
      col_spacing = match_override(col_spacing_enum, params, col_spacing),
      profile_rows = match_override(profile_rows_enum, params, profile_rows),
      homerow = optional_index(match_override(homerow_enum, params, homerow), col),
      homecol = match_override(homecol_enum, params, homecol),
      tent = match_override(tent_enum, params, tent),
      tilt = optional_vector_index(match_override(tilt_enum, params, tilt), col, row),
      position = match(position_enum, params),
      offsets = optional_vector_index(match_override(offsets_enum, params, offsets), col, row),
      displacement = match(displacement_enum, params) + displacement,
      row_first = match(row_first_enum,params)) {
    assert(!is_undef(tilt.x),str(tilt," ",col," ", row," ", match(tilt_enum,params)))

    rotate([0,tent.y,0])
    rotate([tent.x,0,0])
    translate(position)
      rotate([0,0,tent.z]) rotate([0,tilt.y,0])
      translate(offsets) rotate([tilt.x,0,0])
      rotate([0,0,tilt.z])
      // usually we place col first (i.e. closer to the children(), second in right-to-left, top-to-bottom reading order)
      //  but this can be overridden
      place_row_and_or_col(row, col, row_spacing, col_spacing, homecol, homerow, corners=corners,
			   displacement=displacement, row_first=row_first)
      translate([0,0,displacement.z])
      //place_z_correct(row, col, row_spacing, col_spacing, homerow, homecol, corners=corners)
      if(stay_upright) {
	// this case is used for things like struts where we want the positioning effects, but want to cancel out
	//  any rotation in X or Y so the strut stays completely vertical
	//  we have to do the reversal in the opposite order as above, so we invert whatever row_first is set to
	place_row_and_or_col(row, col, row_spacing, col_spacing, homecol, homerow, corners=corners,
			     displacement=displacement, row_first=!row_first,reverse=true)
	  reverse_rotation(row, col, tilt, tent)
	  children();
      } else if(flatten) {
	// this is the 'normal' case for key caps/switches/holders

	/* using params bundle makes profile rows opaque to callers. so we use a special var to pass through
	 *  $effective_row so we can use it to get the right keycap */
	$effective_row = optional_index(profile_rows, row, col);
	position_flat($effective_row) children();
      } else {
	// this case is for items that opt out of key flattening transformations, e.g. the trackpoint mount
	children();
      }
  }
}

/* dispatch for placement styles, so we don't have to re-write layout_columns for each style combo */
module place_row(row,col,row_spacing,homerow, corners=false, reverse=false, displacement=[0,0,0]) {
  assert(len(row_spacing) == 3, "not a properly formatted col_spacing, use a create_*_placement() function");
  style = row_spacing[0];
  args = row_spacing[1];
  spacing = row_spacing[2];

  if (style == "flat") {
    place_flat_row(row=row, col=col, row_spacing=spacing, homerow=homerow, corners=corners, reverse=reverse, args=args, displacement=displacement) children();
  } else if (style == "circular") {
    place_circular_row(row=row, col=col, row_spacing=spacing, homerow=homerow, corners=corners, reverse=reverse, args=args, displacement=displacement) children();
  } else if (style == "arc") {
    place_arc_row(row=row, col=col, row_spacing=spacing, homerow=homerow, corners=corners, reverse=reverse, args=args, displacement=displacement) children();
  } else {
    assert(false, str("unknown placement style: ", style));
  }
}

module place_col(row,col,col_spacing,homecol, homerow, corners=false, reverse=false, displacement=[0,0,0]) {
  assert(len(col_spacing) == 3, "not a properly formatted col_spacing, use a create_*_placement() function");
  style = col_spacing[0];
  args = col_spacing[1];
  spacing = col_spacing[2];

  if (style == "flat") {
    place_flat_col(row=row, col=col, col_spacing=spacing, homecol=homecol, homerow=homerow, corners=corners, reverse=reverse, args=args, displacement=displacement) children();
  } else if (style == "circular") {
    place_circular_col(row=row, col=col, col_spacing=spacing, homecol=homecol, homerow=homerow, corners=corners, reverse=reverse, args=args, displacement=displacement) children();
  } else if (style == "arc") {
    place_arc_col(row=row, col=col, col_spacing=spacing, homecol=homecol, homerow=homerow, corners=corners, reverse=reverse, args=args, displacement=displacement) children();
  } else {
    assert(false, str("unknown placement style: ", style));
  }
}

module place_z_correct(row, col, row_spacing, col_spacing, homerow, homecol, corners=false){
  assert(len(row_spacing) == 3, "not a properly formatted col_spacing, use a create_*_placement() function");
  row_style = row_spacing[0];
  row_args = row_spacing[1];
  r_spacing = row_spacing[2];

  assert(len(col_spacing) == 3, "not a properly formatted col_spacing, use a create_*_placement() function");
  col_style = col_spacing[0];
  col_args = col_spacing[1];
  c_spacing = col_spacing[2];

  if (row_style == "circular" && col_style == "circular"){
    place_circular_z_correct(row, col, r_spacing, c_spacing, homerow, homecol, row_args, col_args, corners) children();
  } else {
    children();
  }
}

/* flat style */
module place_flat_row(row, col, row_spacing, homerow, corners=false, reverse=false, args=[], displacement=[0,0,0]){
  /*if (row == homerow && !corners) {
    children();
    } else {*/
    translate([0, (reverse?0:1) *
	       (calculate_displacement(row_spacing, row, col, homerow, corners=corners) + displacement.y), 0]) children();
    //}
}

module place_flat_col(row, col, col_spacing, homecol, homerow, corners=false, reverse=false, args=[], displacement=[0,0,0]){
  /*if (col == homecol && !corners) {
    children();
    } else {*/
    translate([(reverse?0:1) *
	       (calculate_displacement(col_spacing, col, row, homecol, corners=corners) + displacement.x), 0, 0]) children();
    //}
}

function create_flat_placement(v) = ["flat", [], v];

/* circular style - rows in XZ plane, columns in YZ */
// XXX doesn't use ranged_sum(), so individually tuned key spacing won't properly reflect neighbor's positions
module place_circular_row(row, col, row_spacing, homerow, corners=false, reverse=false, args=[], displacement=[0,0,0]){
  temp_chord = optional_vector_index(row_spacing, row, col);
  chord = normalize_chord([temp_chord[0]+displacement.y,temp_chord[1],0]);

  z_correct = args[0];

  count = homerow-row;

  if (corners) {
    translate([0,0,reverse?0:chord[1]]) rotate([(reverse?-1:1)*((2*count-1)*chord[2]/2),0,0]) translate([0,0,reverse?0:-chord[1]])
      if (z_correct) {
	rotate([0,0,-col*(count/2-1)*chord[2]/2/2]) children();
      } else {
	children();
      }
  } else {
    translate([0,0,reverse?0:chord[1]]) rotate([(reverse?-1:1)*((homerow-row)*chord[2]),0,0]) translate([0,0,reverse?0:-chord[1]])
       if (is_num(z_correct) && z_correct == 0) {
	children();
      } else {
	rotate([0,0,count*(homerow-row)*optional_index(z_correct,row,col)]) children();
      }
  }
}

module place_circular_col(row, col, col_spacing, homecol, homerow, corners=false, reverse=false, args=[], displacement=[0,0,0]){
  temp_chord = optional_vector_index(col_spacing, col, row);
  chord = normalize_chord([temp_chord[0]+displacement.x,temp_chord[1],0]);

  z_correct = args[0];

  count = homecol-col;

  if (corners) {
    translate([0,0,reverse?0:chord[1]]) rotate([0,(reverse?-1:1)*-((2*count-1)*chord[2]/2),0]) translate([0,0,reverse?0:-chord[1]])
      /*if (z_correct != 0 ) {
	rotate([0,0,(count/2-1)*(homerow)*z_correct/2]) children();
	} else {*/
	children();
    //}
  } else {
    translate([0,0,reverse?0:chord[1]]) rotate([0,(reverse?-1:1)*-((homecol-col)*chord[2]),0]) translate([0,0,reverse?0:-chord[1]])
      if (is_num(z_correct) && z_correct == 0) {
	children();
      } else {
	rotate([0,0,count*(homerow-row)*optional_index(z_correct,row,col)]) children();
      }
  }
}

module place_circular_z_correct(row, col, row_spacing, col_spacing, homerow, homecol, row_args, col_args, corners) {
  row_chord = optional_vector_index(row_spacing, row, col);
  col_chord = optional_vector_index(col_spacing, col, row);
  row_z_correct = false;//row_args[0];

  row_count = homerow-row;
  col_count = homecol-col;

  if (row_z_correct) {
    //rotate([0,0,2*row_count*col_count*(row_chord[2] - (col_chord[2]))]) children();
    rotate([0,0,row_count*col_count*(31)/*row_chord[2] - (col_chord[2]))*/]) children();
  } else {
    children();
  }
}

function create_circular_placement(v, z_correct=0) = ["circular", [z_correct], optional_normalize(v)];

/* arc style - circular in the XY plane */
// XXX doesn't use ranged_sum(), so individually tuned key spacing won't properly reflect neighbor's positions
module place_arc_row(row, col, row_spacing, homerow, corners=false, reverse=false, args=[], displacement=[0,0,0]){
  temp_chord = optional_vector_index(row_spacing, row, col);
  chord = normalize_chord([temp_chord[0]+displacement.y,temp_chord[1],0]);

  if (chord == [0,0,0]) {
    children();
  } else {
    z_correct = args[0];

    count = homerow-row;

    if (corners) {
      translate([reverse?0:chord[1],0,0]) rotate([0,0,(reverse?-1:1)*-((2*count-1)*chord[2]/2)]) translate([reverse?0:-chord[1],0,0])
	if (z_correct) {
	  rotate([0,0,-col*(count/2-1)*chord[2]/2/2]) children();
	} else {
	  children();
	}
    } else {
      translate([reverse?0:chord[1],0,0]) rotate([0,0,(reverse?-1:1)*-(count*chord[2])]) translate([reverse?0:-chord[1],0,0])
	if (is_num(z_correct) && z_correct == 0) {
	  children();
	} else {
	  rotate([0,0,count*(homerow-row)*optional_index(z_correct,row,col)]) children();
	}
    }
  }
}

module place_arc_col(row, col, col_spacing, homecol, homerow, corners=false, reverse=false, args=[], displacement=[0,0,0]){
  temp_chord = optional_vector_index(col_spacing, col, row);
  chord = normalize_chord([temp_chord[0]+displacement.x,temp_chord[1],0]);

  if (chord == [0,0,0]) {
    children();
  } else {
    z_correct = args[0];

    count = homecol-col;

    if (corners) {
      translate([0,reverse?0:-chord[1],0]) rotate([0,0,(reverse?-1:1)*-((2*count-1)*chord[2]/2)]) translate([0,reverse?0:chord[1],0])
	/*if (z_correct != 0 ) {
	  rotate([0,0,(count/2-1)*(homerow)*z_correct/2]) children();
	  } else {*/
	children();
      //}
    } else {
      translate([0,reverse?0:-chord[1],0]) rotate([0,0,(reverse?-1:1)*-(count*chord[2])]) translate([0,reverse?0:chord[1],0])
	if (is_num(z_correct) && z_correct == 0) {
	  children();
	} else {
	  rotate([0,0,count*(homerow-row)*optional_index(z_correct,row,col)]) children();
	}
    }
  }
}

function create_arc_placement(v, z_correct=0) = ["arc", [z_correct], optional_normalize(v)];


function optional_normalize(v) = !is_list(v[0]) ? normalize_chord(v) :
				     [ for(e=v) optional_normalize(e) ];


/* used for flexible column parameters without a lot of boilerplate, allows us to pass:
 *  - a scalar (if we want all keys treated the same)
 *  - an array (for treating each key in a column (row) differently, but all columns (rows) identically)
 *  - a 2d array (to be able to configure each key individually
 */
//function optional_index(v, row, col) = !is_list(v) ? v : !is_list(v[0]) ? v[row] :
  //  len(v[col]) == 1 ? v[col][0] : v[col][row];
//function optional_vector_index(v, row, col) = !is_list(v[0]) ? v : !is_list(v[0][0]) ? v[row] :
//  len(v[col]) == 1 ? v[col][0] : v[col][row];

function _optional_index_or_last(v,idx) =
  !is_list(v)   ? v :
  len(v) == 1   ? v[0] :
  //len(v) <= idx ? v[len(v)-1] :
                  v[idx];

function optional_index(v, row, col, leaf = function (l) l) =
  !is_list(leaf(v))    ? v :
  !is_list(leaf(v[0])) ? _optional_index_or_last(v, row) :
                         _optional_index_or_last(_optional_index_or_last(v, col), row);
  //len(v) == 1          ? v[0] :
  //len(v) <= row        ? v[len(v)-1] :
  //                       v[row] :
  //len(v[col]) == 1     ? v[col][0] :
  //len(v) == 1          ? len(v[0]) == 1 ? v[0][0]  : v[0][row] :
  //len(v[col]) <= row   ? v[col][len(v[col])-1] :
  //                       v[col][row];

function optional_vector_index(v, row, col) = optional_index(v, row, col, leaf = function(l) l[0]);

// column major vs row major data
// (eg, if expanding values from a scalar, which dimension are we most likely to customize)
/* Column-major (the basic unit of a columnar stagger is the columns, so this is the default)
 *  col_spacing
 *  offset
 *  tilt
 *  # rows and possibly homerow (ergodox/dactyl/DM all have columns with fewer rows)
 */
/* Row-major
 *  row_spacing
 *  profile_rows (rarely a scalar, usually a vector already)
 */
/* Both
 *  walls - if I want to tune them its probably for a specific key
 *  headers/footers and sides? maybe row or column respectively but probably a key specific workaround
 *  wider modifier keys - this is column major, but also usually varies with row (ergodox has a 1u key in the last row)
 *  vertical keys and horizontal spacebars - maybe just a combo of offset and varying # rows per column?
 */
/* so how to handle?
 *  first dimension is always the same:
 *     - clumsy for data oriented differently, needs to know how many replicas to create
 *  by convention:
 *     - straightforward unless you guess wrong
 *     - might need two copies of helper functions (and to remember which to use)
 *  wrapper with metadata saying column or row major:
 *     - might need to use a constructor even if I just want a scalar (adds complexity)
 *     - gives a place to stash other metadata
 */
/* right now, I only see 2 row-first data types which are both strongly row associated,
 *  so sticking to convention for now
 */

//utils for accumulating multiple columns (rows) worth of the above structures
function range_sum(v, start, stop, other, sum=0) =
  start != stop ? range_sum(v, start+1, stop, other, sum + optional_index(v, start, other)) :
  sum + optional_index(v, start, other);

function calculate_displacement(v, idx, other, home=0, corners=false) =
  corners == true ? calculate_displacement_halved_tail(v, idx, other, home) :
  idx == home ? 0 :
  idx < home ? range_sum(v, idx, home - 1, other) : -range_sum(v, home + 1, idx, other);

function range_sum_halved_tail(v, start, stop, other, sum=0) =
  start != stop ? range_sum_halved_tail(v, start+1, stop, other, sum + optional_index(v, start, other)) :
  sum + optional_index(v, start, other)/2;

function calculate_displacement_halved_tail(v, idx, other, home=0) =
  //idx == home ? optional_index(v, idx+1, other)/2 :
  idx +1 == home ? optional_index(v, idx, other)/2 :
  idx < home ? optional_index(v, idx, other)/2 + range_sum(v, idx+1, home - 1, other) :
  -range_sum_halved_tail(v, home + 1, idx+1, other);



// functions for computing ratios between chord, radius and angle on a circle
function chord(angle) = 2 * sin(angle/2);
function achord(c, r) = 2 * asin(c/(2*r));
function chord_from_r(r, a) = r * chord(a);
function r_from_chord(c, a) = c / chord(a);

function normalize_chord(t) = t == [0,0,0] ? t :
                              [t[0] ? t[0] : chord_from_r(t[1], t[2]),
                               t[1] ? t[1] : r_from_chord(t[0], t[2]),
                               t[2] ? t[2] : achord(t[0], t[1])];


/*module apply() {
  children(0) children(1);
}

apply() {
  translate([5,5,5]);
  sphere(r=1);
  }*/

//sphere(r=1);
