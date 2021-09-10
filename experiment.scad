
use <util.scad>;

thickness=4;
innerdia=13.9;
outerdia=17;
tilt=-10;
spacer = 1.4;
mxstem = 6.1;

highest_high=40;
lowest_low=60;

// functions for computing ratios between chord, radius and angle on a circle
function chord(angle) = 2 * sin(angle/2);
function achord(c,r)  = 2 * asin(c/(2*r));
function chord_from_r(r,a) = r * chord(a);
function r_from_chord(c,a) = c / chord(a);

function normalize_chord_tuple(t) = [t[0] ? t[0] : chord_from_r(t[1], t[2]),
				     t[1] ? t[1] : r_from_chord(t[0],t[2]),
				     t[2] ? t[2] : achord(t[0],t[1])];

module keywell_slug() {
  translate([0,0,-thickness/2]) cube([outerdia, outerdia, thickness], true);
}

// use to cut a keywell into something
module keywell_cavity() {
  union() {
    //translate([0,0,thickness]) cube([outerdia,outerdia,2*thickness],true);
    translate([0,0,-thickness/2])cube([innerdia, innerdia, thickness+.2], true);
    let(depth=.6, width=5,h=2.8, margin=.1){//5*thickness) {
      translate([-width/2,innerdia/2-.1,-thickness-margin]) cube([width, depth+0.1, h+margin]);
      translate([-width/2,-innerdia/2-depth,-thickness-margin]) cube([width, depth+0.1, h+margin]);
    }
  }
}

module keywell_cavity_below() {
  union() {
    //translate([0,0,thickness/4]) cube([outerdia,outerdia,thickness/2],true);
    translate([0,0,-thickness/2]) cube([innerdia, innerdia, thickness+.2], true);
    let(depth=.6, width=5,h=2.8, margin=.1){//5*thickness) {
      translate([-width/2,innerdia/2-.1,-thickness-margin]) cube([width, depth+0.1, h+margin]);
      translate([-width/2,-innerdia/2-depth,-thickness-margin]) cube([width, depth+0.1, h+margin]);
      translate([0,0,-thickness-((thickness-1)/2)]) cube([innerdia, innerdia+(depth*2), thickness-1], true);
    }

  }
}

// the basic unit of this keyboard. symmetrical along x and y. below the z axis.
module keywell() {
  difference() {
    keywell_slug();
    keywell_cavity();
  }
}

// messing around with a uniform curve
module column(keys=4) {
  angle=8;
  spacing=18.5;
  union() {
    for (i = [-1:2]) {
      translate([0,i*spacing,abs(i)*sin(angle/2)*(spacing/2)])
	translate([0,i == 0 ? 0 : (-i/abs(i))*(outerdia/2),0])
	rotate([i*8,0,0])
	translate([0,i == 0 ? 0 : (i/abs(i))*(outerdia/2),0]) keywell();
    }
  }
}


include <../KeyV2/includes.scad>

//  another experiment, with key caps to show spacing
module key_column() {
  cherry_row(3) key();
  translate([0,18.5,-2]) rotate([3,0,0]) cherry_row(2) key();
  translate([0,2*18.5,-3]) rotate([7,0,0]) cherry_row(1) key();
}

/* a keywell, along with the additional material above and below we need to connect them in a column,
 *  and, optionally, a side wall so that, after shaping, it can be freestanding. side wall is only on
 *  one side (as this is how it is more commonly used), so we need to mirror the assembly to have
 *  walls on both sides. well is positioned below so the keycap will sit directly on the origin.
 */

module show_travel(travel_advisory=true) {
    how_low = 4;
    children();
    if (travel_advisory) {
      color("yellow", 0.25) translate([0,0,-how_low]) linear_extrude(how_low) projection() children();
    }
}
module key_assembly_old(row=3,keys=false,well=true, sides=false,header=true,footer=true, travel_advisory=true) {

  effective_row = (row >= 5) ? 4 : ((row < 1) ? 1 : row);
  wall = (outerdia-innerdia)/2;
  union(){
    if (keys) {
      if ($preview) {
	show_travel(travel_advisory) cherry_row(effective_row) key($fn=6);
      } else {
	show_travel(travel_advisory) cherry_row(effective_row) key();
      }
    }
    translate([0,0,-mxstem]) union(){
      if (well) {
	if (header) {
	  height=4.8;
	  translate([0,(outerdia/2)-wall/2,-height/2-thickness]) cube([outerdia,wall,height],true);
	}
	keywell();
	if(footer) {
	  length=6.8;
	  dia=wall*2-.5;
	  translate([0,-(outerdia/2)-(length/2),-(thickness/2)]) cube([outerdia,length,thickness],true);
	  translate([0,-(outerdia/2)-(length), dia/2-thickness]) rotate([0,90,0]) cylinder(h=outerdia, d=dia,center=true);
	}
	if (sides) {
	  height = 4.5+thickness+60;
	  width = (outerdia-innerdia)/2;

	  translate([outerdia/2-width/2,0,-((height)/2)]) cube([width,outerdia,height], true);
	  //mirror([1,0,0]) translate([outerdia/2-width/2,0, -((height)/2)+thickness]) cube([width,outerdia,height], true);
	  if (row <4) {
	    translate([outerdia/2-width/2,-(outerdia/2) -1,-((height)/2)]) cube([width,outerdia+17,height], true);
	    //mirror([1,0,0]) translate([outerdia/2-width/2,-(outerdia/2) -1,-((height)/2)+thickness]) cube([width,outerdia+2,height], true);
	  }
	}
      }
    }
  }
}

module key_assembly(row=3,keys=false,well=true,sides=false, header=false,footer=false,travel_advisory=true) {
  effective_row = (row >= 5) ? 4 : ((row < 1) ? 1 : row);

  if (keys) {
      if ($preview) {
	show_travel(travel_advisory) cherry_row(effective_row) key($fn=6);
      } else {
	show_travel(travel_advisory) cherry_row(effective_row) key();
      }
    }
  if (well) {
    length=spacer/2;
    if (header) {
      translate([0,(outerdia/2)+(length/2),-(thickness/2)-mxstem]) cube([outerdia,length,thickness],true);
    }

    translate([0,0,-mxstem]) keywell();//key_assembly_old(row,keys=false,well,sides=false, header=false,footer=false);

    // footer can be use to prevent keycap from colliding with the the joining material
    if (footer) {;
      translate([0,-(outerdia/2)-(length/2),-(thickness/2)-mxstem]) cube([outerdia,length,thickness],true);
    }
  }
}

module cherry_key_flat(row=3,keys=false,well=true) {
  effective_row = (row >= 5) ? 4 : row;

  cherry_position_row_flat(effective_row) {
    if (keys) {
      if ($preview) {
	cherry_row(effective_row) key($fn=6);
      } else {
	cherry_row(effective_row) key();
      }
    }
    if (well) {
      translate([0,0,-mxstem]) {
	keywell();
      }
    }
  }
}
module cherry_position_row_flat(row) {
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

*cherry_key_flat(row=1, keys=true);

// removes excess side wall material to make key_column_tightest freestanding, or just to avoid stray projections
module trimmer() {
 difference() {
   children();

   depth=200;
   //if (sides) {
   translate([0,0,-13-depth/2]) cube([depth,depth,depth],true);
   translate([0,49+depth/2,0]) cube([depth,depth,depth],true);
   //   if (rows == 5) {
   //	translate([0,-39-depth/2,0]) cube([outerdia+10,depth,depth],true);
   //   } else if (rows == 4) {
   translate([0,-28-depth/2,0]) cube([depth,depth,depth],true);
   //   }
 }
}

// hand positioned column for cherry keycaps, curved so the tops of the keycaps are nearly touching
module position_row(row) {
  assert(row > 0 && row < 6 );

  if (row == 1) {
    translate([0,2*18.5-.1,12.3]) rotate([55,0,0]) translate([0,0,thickness]) children();
  } else if (row == 2) {
    translate([0,18.5+1.3,1.9]) rotate([28,0,0]) translate([0,0,thickness]) children();
  } else if (row == 3) {
    translate([0,0,thickness]) children();
  } else if (row == 4) {
    translate([0,-18.5-.1,7.2]) rotate([-32,0,0]) translate([0,0,thickness]) children();
  } else if (row == 5) {
    translate([0,-2*18.5+8.2,24]) rotate([-60,0,0]) translate([0,0,thickness]) children();
  }
}


// hand positioned column for cherry keycaps, curved so the tops of the keycaps are nearly touching
module key_column_tightest(rows=4,keys=false,well=true, sides=true,tilt=[-10,0,0]) {
  rotate(tilt) union() {
    if (rows == 5) {
      position_row(5) key_assembly_old(5,keys,well,sides,footer=false);
    }
    position_row(4) key_assembly_old(4,keys,well,sides,footer=(rows > 4) );

    position_row(3) key_assembly_old(3,keys,well,sides);
    position_row(2) key_assembly_old(2,keys,well,sides, header=(rows > 3) );
    if (rows > 3) {
      position_row(1) key_assembly_old(1,keys,well,sides,header=false);
    }
  }
}



// a less ad hoc key column where all the joining material and sides are computed rather than predefined
module key_column_hulled(rows=4,keys=false,well=true, sides=true,footer=false,tilt=[-10,0,0], widesides=true) {
  union() {
    for(i=[((rows>3)?1:2):(rows==5?5:4)]) {
      side_helper(tilt,sides,widesides) position_row(i) {
	// no header needed because in practice join always decends above the keywell
	//translate([0,(outerdia/2)+(length/2),(thickness/2)]) cube([outerdia,length,thickness],true);

	key_assembly_old(i,keys,well,sides=false, header=false,footer=false);

	// footer can be use to prevent keycap from colliding with the the joining material
	if (i < rows && footer) {
	  length=spacer/2;
	  translate([0,-(outerdia/2)-(length/2),(thickness/2)-mxstem]) cube([outerdia,length,thickness],true);
	}
      }

      // joins the keywell of this row to the next
      if (i < rows && well) {
	side_helper(tilt,sides,widesides) column_hull(i,footer);
	/*hull() {
	  position_row(i) translate([-outerdia/2,-(outerdia+(footer?spacer:0))/2,-mxstem]) cube([outerdia,.01,thickness]);
	  position_row(i+1) translate([-(outerdia)/2,outerdia/2-.01,-mxstem]) cube([outerdia,.01,thickness]);
	  }*/
      }
    }
  }
}

  /* clones the child object and, if sides are enabled, projects its intersection with a large plane
   *  the width of the side and uses a hull between that projection and a duplicate intersection to
   *  produce a side. we have to use the helper on each peice of the column, rather than the final
   *  product, because the column is concave and the hull operaation will will fill in the side above
   *  the column. for side it be properly oriented child must have already had any x rotation (tilt)
   *  applied, so we take it as a parameter to ensure consistency. the side itself should not be
   *  tilted. side height is excessive because we will use a difference on the final model to remove
   *  extraneous material below the desired height.
   */
module side_helper(tilt, sides, widesides=true,left=false, offset=[0,0,0]) {
  module stack() {
    children();
    if(widesides) {
      translate([1,0,0]) children();
    }
  }
  // this makes the side exactly as wide as the keywell itself
  width = (outerdia-innerdia)/2;
  // globals that must be hand set to estimate the largest values we might encounter.
  height = highest_high+lowest_low;

  difference() {
    union() {
      // pass through the child object, even is no side is added
      rotate(tilt) children();

      if (sides) {

	// the computed side
	stack() translate([widesides?width:0,0,0]) hull() {
	  // just the edge of the child
	  intersection() {
	    rotate(tilt) children();
	    translate(offset) mirror([left?1:0,0,0]) translate([outerdia/2-width/2,0,0]) cube([width,200,height], true);
	  }

	  // this computes the projection of edge of child in the xy plane (i.e. your desk)
	  translate([0,0,-lowest_low]) linear_extrude(height=1) projection() intersection() {
	    rotate(tilt) children();
	    translate(offset) mirror([left?1:0,0,0]) translate([outerdia/2-width/2,0,0]) cube([width,200,height], true);
	  }
	}
      }
    }
    if (offset != [0,0,0]) {
      translate(offset) mirror([left?1:0,0,0]) translate([outerdia/2-width/2,0,0]) cube([width,200,height], true);
    }
  }
}

module flat_cherry_column(rows=4,keys=false,well=true, sides=true,footer=false,tilt=[0,0,0], widesides=false) {
  union() {
    for(i=[((rows>3)?1:2):(rows==5?5:4)]) {
      translate([0,(3-i)*(outerdia+2*spacer),0]) {
	side_helper(tilt,sides,widesides) cherry_position_row_flat(i) {
	  //translate([0,(outerdia/2)+(length/2),(thickness/2)]) cube([outerdia,length,thickness],true);
	  key_assembly_old(i,keys,well,sides=false, header=false,footer=false);

	  // footer can be use to prevent keycap from colliding with the the joining material
	  if (i < rows && footer) {
	    length=spacer/2;
	    translate([0,-(outerdia/2)-(length/2),(thickness/2)-mxstem]) cube([outerdia,length,thickness],true);
	  }
	}

	// joins the keywell of this row to the next
	if (i < rows && well) {
	  side_helper(tilt,sides,widesides) {
	    hull() {
	      cherry_position_row_flat(i) translate([0,(footer?-spacer/2:0),0]) keywell_side_bounding_box(y=-1);
	      translate([0,-(outerdia+2*spacer),0]) cherry_position_row_flat(i+1) keywell_side_bounding_box(y=1);
	    }
	  }
	}
      }
    }
  }
}


module position_curve(row, chord_descriptor, col=0, reverse=false) {
  chord_tuple = is_list(chord_descriptor[0])?chord_descriptor[col]:chord_descriptor;
  // must have 2 of the 3 parameters
  assert((chord_tuple[0] != 0 && chord_tuple[1]) || (chord_tuple[0] != 0 && chord_tuple[2]) || (chord_tuple[1] != 0 && chord_tuple[2]));
  t = normalize_chord_tuple(chord_tuple);
  translate([0,0,t[1]]) rotate([(reverse?-1:1)*((3-row)*t[2]),0,0]) translate([0,0,-t[1]]) children();
}

/*module position_curve_reverse(row, chord_tuple) {
  // must have 2 of the 3 parameters
  assert((chord_tuple[0] != 0 && chord_tuple[1]) || (chord_tuple[0] != 0 && chord_tuple[2]) || (chord_tuple[1] != 0 && chord_tuple[2]));
  t = normalize_chord_tuple(chord_tuple);
  translate([0,0,t[1]]) rotate([-((3-row)*t[2]),0,0]) translate([0,0,-t[1]]) children();
}*/

module position_curve_row(col, chord_tuple,row=3) {
  // must have 2 of the 3 parameters
  assert((chord_tuple[0] != 0 && chord_tuple[1]) || (chord_tuple[0] != 0 && chord_tuple[2]) || (chord_tuple[1] != 0 && chord_tuple[2]));
  t = normalize_chord_tuple(chord_tuple);
  translate([0,0,t[1]]) rotate([/*col==1?-.75:*/0,col*t[2] /*-(col*t[2]/8)*abs(3-row)*/,0]) translate([0,0,-t[1]]) children();
}

/*module position_curve_row_reverse(col, chord_tuple) {
  // must have 2 of the 3 parameters
  assert((chord_tuple[0] != 0 && chord_tuple[1]) || (chord_tuple[0] != 0 && chord_tuple[2]) || (chord_tuple[1] != 0 && chord_tuple[2]));
  t = normalize_chord_tuple(chord_tuple);
  translate([0,0,t[1]]) rotate([0,col*t[2],0]) translate([0,0,-t[1]]) children();
}*/


module curved_cherry_column(rows=4,chord_tuple,keys=false,well=true, sides=true,footer=false,tilt=[0,0,0], widesides=true) {
  union() {
    for(i=[((rows>3)?1:2):(rows>=5?rows:4)]) {
      //  {
       side_helper(tilt,sides, widesides) position_curve(i,chord_tuple) cherry_position_row_flat(i) {
	//translate([0,(outerdia/2)+(length/2),(thickness/2)]) cube([outerdia,length,thickness],true);
	key_assembly_old(i,keys,well,sides=false, header=false,footer=false);

	// footer can be use to prevent keycap from colliding with the the joining material
	if (i < rows && footer) {
	  length=spacer/2;
	  translate([0,-(outerdia/2)-(length/2),-(thickness/2)-mxstem]) cube([outerdia,length,thickness],true);
	}
      }

      // joins the keywell of this row to the next
      if (i < rows && well) {
	side_helper(tilt,sides,widesides) position_curve(i,chord_tuple)
	  hull() {
	  cherry_position_row_flat(i) translate([0,(footer?-spacer/2:0),0]) keywell_side_bounding_box(y=-1);
	  position_curve(4/* this is one down from 'home' which is where we are until positioning functions are applided*/,
			 chord_tuple) cherry_position_row_flat(i+1) keywell_side_bounding_box(y=1);
	}
      }
    }
  }
}


module spherical_cherry_column_pair(rows=4,col_chord, row_chord, columns=2,keys=false,well=true, sides=true,header=false,footer=false,tilt=[0,0,0], widesides=true, z_correct=true, trackpoint=true, trackpoints=[0,[[3.7,1.7],[4.8,4.3,4.5,-1.5]]]) {
  tilt_x=[tilt.x,0,0];
  module position_helper(i,j,sides=false) {
    z_correction = z_correct ? -row_chord[2]/2 : 0;

    module helpers_helper(i,j) {
      position_curve(i,col_chord,j) position_curve_row(j,row_chord,i) rotate([0,0,j*(rows-i-1)*z_correction]) children();
    }

    if (sides) {
      /* applies position_curve() so we can use side_helper() with the correct x rotation but then reverses it so
       *  helpers_helper() can apply position_curve_row() first, then position_curve(), otherwise we get a big gap
       */

      // XXX: not really sure why the tilt correcton is needed but the sidewalls aren't straight without it
      temp = is_list(col_chord[0])?col_chord[j]:col_chord;
      col_c= [temp[0],temp[1],temp[2]+(j>0?tilt.x:0)];

      helpers_helper(i,j) position_curve(i,col_c,reverse=true) rotate(-tilt_x) side_helper(tilt_x,sides&&(((columns-1)==j)||j==0), widesides,left=(j==columns-1)) position_curve(i,col_c)  cherry_position_row_flat(i) children();
    } else {
      helpers_helper(i,j) cherry_position_row_flat(i) children();
    }
  }

  /*module position_trackpoint(pos, i){
    /* we want to tilt the trackpoint by half the amount of the row and column angle (and remove half of
     * any tenting: tilt.y) because it is in between rows and columns. if each column has its own
     * col_chord, use the larger of the two (which should be the second)
     *
    a_x= i==4? -tilt.x/2:(is_list(col_chord[0]) ? col_chord[1][2] : col_chord[2])/2 +(i==3?tilt.x:0);
    a_y=row_chord[2]/2-tilt.y/2;
    let(x=pos.x,y=pos.y) {
      translate([-(outerdia/2+x),y+innerdia/2,-mxstem]) rotate([a_x,a_y,0]) children();
    }
  }
  */

  module position_trackpoint(pos, i){
    rc = normalize_chord_tuple([row_chord[0]/2 + pos.x,row_chord[1],0]);
    let(temp = is_list(col_chord[0])?col_chord[0]:col_chord){
      cc = normalize_chord_tuple([temp[0]/2+pos.y,temp[1],0]);

      z_correction = z_correct ? -rc[2]/4 : 0;
       translate([0,0,cc[1]]) rotate([(((3-i)*2)-1)*cc[2],0,0]) translate([0,0,-cc[1]]) position_curve_row(1,rc)
	 rotate([0,0,(2*(3-i)-1)*z_correction]) children();
    }
  }

  first_row = ((rows>3)?1:2);
  last_row = (rows>=5?rows:4);
  difference() {
    //union() {
    for(j=[0:(columns-1)]) {
      for(i=[first_row:last_row]) {
	  let(has_footer = footer || i == last_row, has_header = header || i == first_row) {
	    rotate([0,j==0?tilt.y:0.0]) rotate(tilt_x) position_helper(i,j,sides=sides) {
	      if (has_header && well) {
		length=spacer/2;
		translate([0,(outerdia/2)+(length/2),-(thickness/2)-mxstem]) cube([outerdia,length,thickness],true);
	      }

	      /*if (trackpoint && well) {
		translate([0,0,-mxstem]) keywell_slug();
		} else {*/
		key_assembly_old(i,keys,well,sides=false, header=false,footer=false);
		//}

	      // footer can be use to prevent keycap from colliding with the the joining material
	      if (has_footer && well) {
		length=spacer/2;
		translate([0,-(outerdia/2)-(length/2),-(thickness/2)-mxstem]) cube([outerdia,length,thickness],true);
	      }

	      /*if(trackpoint && well && j==0) {
	      if (is_list(trackpoints) && len(trackpoints) >= (i) && is_list(trackpoints[i-1]) && is_list(trackpoints[i-1][0]) && is_list(trackpoints[i-1][1])) {
	        position_trackpoint(trackpoints[i-1][0],i) trackpoint_mount(trackpoints[i-1][1][0],trackpoints[i-1][1][1],stem=trackpoints[i-1][1][2],up=trackpoints[i-1][1][3]);
		}
		}*/
	    }

	    // joins the keywell of this row to the next
	    if (i < rows && well) {
	      // XXX: get rotated left side working
	      rotate([0,j==0?tilt.y:0.0]) side_helper(tilt_x,sides&&(columns-1==j||j==0),widesides,left=(j==columns-1))
		hull() {
		position_helper(i,j) translate([0,((has_footer)?-spacer/2:0),0]) keywell_side_bounding_box(y=-1);
		position_helper(i+1, j) keywell_side_bounding_box(y=1);
	      }
	    }
	    // joins the keywell of this column to the next
	    if (j < columns-1 && well){
	      hull() {
		rotate([0,j==0?tilt.y:0.0]) rotate(tilt_x) position_helper(i,j) keywell_side_bounding_box(x=-1, header=has_header,footer=has_footer);
		rotate(tilt_x) position_helper(i,j+1) keywell_side_bounding_box(x=1, header=has_header,footer=has_footer);
	      }
	    }
	    // fills in the gap between row and column hulls
	    if (i < rows && j < columns-1 && well){
	      hull() {
		rotate([0,j==0?tilt.y:0.0]) rotate(tilt_x) position_helper(i,j)  keywell_corner_bounding_box(x=-1,y=-1, footer=has_footer);
		rotate(tilt_x) position_helper(i,j+1)  keywell_corner_bounding_box(x=1,y=-1, footer=has_footer);

		rotate([0,j==0?tilt.y:0.0]) rotate(tilt_x) position_helper(i+1,j)  keywell_corner_bounding_box(x=-1,y=1, footer=has_footer);
		rotate(tilt_x) position_helper(i+1,j+1)  keywell_corner_bounding_box(x=1,y=1, footer=has_footer);
	      }
	    }
	  }
	}
      }

    // cut holes for trackpoint stem
    if(trackpoint && well) {
      for(i=[first_row:last_row]) {
	for(j=[0]) {
	  if(j==0 && is_list(trackpoints) && len(trackpoints) >= (i) && is_list(trackpoints[i-1]) && is_list(trackpoints[i-1][0]) && is_list(trackpoints[i-1][1])) {
	    rotate(tilt_x) position_trackpoint(trackpoints[i-1][0],i) translate([0,0,-14]) cube([7,7,15],true);//cylinder(h=8,d=7,center=true);
	  }
	}
      }
    }
  }

  // generate trackpoint mounts and remove any parts that collide with the keywell cavity or space below
  if (trackpoint && well) {
    difference() {
      for(i=[first_row:last_row]) {
	for(j=[0]) {
	  if(trackpoint && well && j==0) {
	    if (is_list(trackpoints) && len(trackpoints) >= (i) && is_list(trackpoints[i-1]) && is_list(trackpoints[i-1][0]) && is_list(trackpoints[i-1][1])) {
	      rotate(tilt_x) position_trackpoint(trackpoints[i-1][0],i) trackpoint_mount(trackpoints[i-1][1][0],trackpoints[i-1][1][1],stem=trackpoints[i-1][1][2],up=trackpoints[i-1][1][3], tilt=tilt_x);
	    }
	  }
	}
      }
      for(i=[first_row:last_row]) {
	for(j=[0:(columns-1)]) {
	  rotate([0,j==0?tilt.y:0.0]) rotate(tilt_x) position_helper(i,j) {
	    translate([0,0,-mxstem]) keywell_cavity_below();
	  }
	}
      }
    }
  }
}

module sphere_orbit_cherry_column_pair(rows=4,col_chord, row_chord, columns=2,keys=false,well=true, sides=true,footer=false,tilt=[0,0,0], widesides=true) {
  side_helper([0,0,0], sides=true, left=true, offset=[-34.5,0,0])
    union() {
    for(i=[((rows>3)?1:2):(rows>=5?rows:4)]) {
      for(j=[0:(columns-1)]) {

	rotate([tilt.x,j==0?tilt.y:0,0]) position_curve_row(j,row_chord) rotate(-[tilt.x,0,0]) side_helper([tilt.x,0,0],sides&&(((columns-1)==j)||j==0), widesides,left=(j==columns-1)) position_curve(i,col_chord) cherry_position_row_flat(i) {
	  //translate([0,(outerdia/2)+(length/2),(thickness/2)]) cube([outerdia,length,thickness],true);
	  key_assembly_old(i,keys,well,sides=false, header=false,footer=false);

	  // footer can be use to prevent keycap from colliding with the the joining material
	  if (i < rows && footer) {
	    length=spacer/2;
	    translate([0,-(outerdia/2)-(length/2),-(thickness/2)-mxstem]) cube([outerdia,length,thickness],true);
	  }
	}

	// joins the keywell of this row to the next
	if (i < rows && well) {
	  // XXX: get rotated left side working
	  rotate([0,j==0?tilt.y:0,0]) side_helper([tilt.x,0,0],sides&&(columns-1==j||j==0),widesides,left=(j==columns-1))
	    hull() {
	    position_curve_row(j,row_chord) position_curve(i,col_chord) cherry_position_row_flat(i) translate([0,((footer && i < rows)?-spacer/2:0),0]) keywell_side_bounding_box(y=-1);
	     position_curve_row(j,row_chord) position_curve(i+1,col_chord) cherry_position_row_flat(i+1) keywell_side_bounding_box(y=1);
	  }
	}
	// XXX: hull column hulls
	if (j < columns-1 && well){
	   hull() {
	     rotate([tilt.x,j==0?tilt.y:0,0]) position_curve_row(j,row_chord) position_curve(i,col_chord) cherry_position_row_flat(i) keywell_side_bounding_box(x=-1, footer=(footer && i < rows));
	    rotate([tilt.x,0,0]) position_curve_row(j+1,row_chord) position_curve(i,col_chord) cherry_position_row_flat(i) keywell_side_bounding_box(x=1, footer=(footer && i < rows));
	  }
	}
      }
    }
  }
}

module flat_cherry_tester(keys=false) {
  difference(){
    union(){
      if (keys && $preview) {
	flat_cherry_column(4, well=false,keys=true,sides=false);
      }
      flat_cherry_column(4, keys=false);
      mirror([1,0,0]) flat_cherry_column(4, keys=false);
    }
    translate([0,0,-24-40]) cube([200,200,80],true);
    version=0;
    translate([-outerdia/2+.4,45,-22.5]) rotate([90,0,-90]) linear_extrude(.5) text(str("CHERRY FLAT v",version), size=6);
  }
}

module curved_cherry_tester(chord_tuple,rows=4,keys=false,footer=false,tilt=[0,0,0]) {
  // must have 2 of the 3 parameters
  assert((chord_tuple[0] != 0 && chord_tuple[1]) || (chord_tuple[0] != 0 && chord_tuple[2]) || (chord_tuple[1] != 0 && chord_tuple[2]));
  t = normalize_chord_tuple(chord_tuple);

  if ($preview) {
    #rotate(tilt) translate([0,0,t[1]]) rotate([0,90,0]) cylinder($fn=120,r=t[1],h=15,center=true);
  }

  difference(){
    union(){
      if (keys && $preview) {
	curved_cherry_column(rows,t,well=false,keys=true,sides=false,tilt=tilt, widesides=false);
      }
      curved_cherry_column(rows,t,keys=false,footer=footer,tilt=tilt, widesides=false);
      mirror([1,0,0]) curved_cherry_column(rows,t,keys=false,footer=footer,tilt=tilt, widesides=false);
    }
    translate([0,0,-21-40]) cube([200,200,80],true);

    version=0;
    translate([-outerdia/2+.4,42,-20]) rotate([90,0,-90]) linear_extrude(.5) text(str("CHERRY v",version, " tilt ", tilt.x), size=5);
    translate([outerdia/2-.4,-26,-19.4]) rotate([90,0,90]) linear_extrude(.5) text(str("chord ",t), size=4);
  }
}

module trackpoint_mount(h1,h2,stem=0,up=0,tilt=[-5,0,0], bottom=false){
  width=23+.4;
  depth=9.5;
  flange_z=2;


  cap_len = 5;

  tp_depth = 16+stem+ cap_len;
  stem_depth = 0;
  stem_len = 16+stem+up+stem_depth;


  translate([0,0,-tp_depth]) difference(){
    union() {
      color("purple",.2) if ($preview) {
	union(){
	  translate([0,0,stem_depth])cylinder(d=4,h=stem_len);
	  translate([0,0,stem_depth+stem_len])cylinder(d=6.4,h=cap_len-1);
	  translate([0,0,stem_depth+(cap_len-1)+stem_len])cylinder(d=8,h=1);
	  echo(str("you need a ",stem_len," mm stem"));
	}
      }

      // mount flanges
      let(x=3.8,y=depth,z=flange_z) {
	rotational_clone() translate([-width/2,-y/2,-z]) cube([x,y,z]);
	//mirror([1,0,0]) translate([-width/2,-y/2,-z]) cube([x,y,z]);
	if (bottom){
	  translate([0,0,-5*z/4])cube([width+4,y,z],center=true);
	}
      }


      // verticals
      let(x=2,y=depth,z=thickness) {
        translate([width/2,-y/2,-flange_z]) cube([x,y,h1+z]);
	mirror([1,0,0]) translate([width/2,-y/2,-flange_z]) cube([x,y,h2+z]);
	//translate([width/2,-y/2,-flange_z]) cube([x,y,z]);
      }
    }

    //screw holes
    let(h=flange_z*5,d=2.5,slop=.3) {
      rotational_clone() translate([19/2,0,-h/2])cylinder(h=h,d=d+slop);

    }
  }
}

*trackpoint_mount(3,3,bottom=true);

module sphere_cherry_tester(row_chord, col_chord,rows=4,keys=false,footer=false,tilt=[0,0,0], z_correct=true,trackpoints=[0,[[3.7,1.7],[4.8,4.3,4.5,-1.5]]], fitting=true) {
  // must have 2 of the 3 parameters
  //assert((row_chord[0] != 0 && row_chord[1]) || (row_chord[0] != 0 && row_chord[2]) || (row_chord[1] != 0 && row_chord[2]));
  //assert((col_chord[0] != 0 && col_chord[1]) || (col_chord[0] != 0 && col_chord[2]) || (col_chord[1] != 0 && col_chord[2]));
  cy = normalize_chord_tuple(is_list(row_chord[0])?row_chord[0]:row_chord);
  cx = normalize_chord_tuple(col_chord);

  if ($preview && fitting) {
    #rotate([tilt.x,0,0]) translate([0,0,cy[1]]) scale([cx[1]/cy[1],1,1]) sphere($fn=120,r=cy[1]);
  }

  if (keys && $preview) {
    spherical_cherry_column_pair(rows,row_chord,cx,well=false,keys=true,sides=false,footer=footer,tilt=tilt, widesides=false, z_correct=z_correct);
  }
  difference(){
    spherical_cherry_column_pair(rows,row_chord,cx,keys=false,sides=true,footer=footer,tilt=tilt, widesides=false, z_correct=z_correct,trackpoints=trackpoints);
      //mirror([1,0,0]) spherical_cherry_column_pair(rows,cy,cx,keys=false,footer=footer,tilt=tilt, widesides=false);

    translate([0,0,-24-40]) cube([200,200,80],true);

    version=2;
    rotate([0,tilt.y,0]) translate([innerdia/2+.4,29.5,-20]) rotate([90,0,-90]) linear_extrude(.5) text(str("CHERRY sphere v",version, " tilt ", tilt), size=3);
    rotate([0,tilt.y,0]) translate([outerdia/2-.4,-32.5,-19]) rotate([90,0,90]) linear_extrude(.5) text(str(row_chord, cx), size=3);
  }
}


module orbit_cherry_tester(row_chord, col_chord,rows=4,keys=false,footer=false,tilt=[0,0,0]) {
  // must have 2 of the 3 parameters
  assert((row_chord[0] != 0 && row_chord[1]) || (row_chord[0] != 0 && row_chord[2]) || (row_chord[1] != 0 && row_chord[2]));
  assert((col_chord[0] != 0 && col_chord[1]) || (col_chord[0] != 0 && col_chord[2]) || (col_chord[1] != 0 && col_chord[2]));
  cy = normalize_chord_tuple(row_chord);
  cx = normalize_chord_tuple(col_chord);

  if ($preview) {
    #rotate(tilt) translate([0,0,cy[1]]) rotate([0,90,0]) sphere($fn=120,r=cy[1]);
  }

  difference(){
    union(){
      if (keys && $preview) {
	sphere_orbit_cherry_column_pair(rows,cy,cx,well=false,keys=true,sides=false,footer=footer,tilt=tilt, widesides=false);
      }
      sphere_orbit_cherry_column_pair(rows,cy,cx,keys=false,sides=true,footer=footer,tilt=tilt, widesides=false);
      //mirror([1,0,0]) spherical_cherry_column_pair(rows,cy,cx,keys=false,footer=footer,tilt=tilt, widesides=false);
    }
    translate([0,0,-21-40]) cube([200,200,80],true);

    version=0;
    //translate([-outerdia/2+.4,42,-20]) rotate([90,0,-90]) linear_extrude(.5) text(str("CHERRY sphere v",version, " tilt ", tilt.x), size=5);
    translate([outerdia/2-.4,-32.5,-19]) rotate([90,0,90]) linear_extrude(.5) text(str(cy, cx), size=4);
  }
}


module tightest_cherry_tester(d=25,rows=4,keys=false,footer=false,tilt=[0,0,0]) {
  if ($preview) {
    #rotate(tilt) translate([0,5,d+10]) rotate([0,90,0]) cylinder($fn=120,r=d,h=15,center=true);
  }

   difference(){
    trimmer() union(){
      if (keys && $preview) {
	key_column_tightest(rows,well=false,keys=true,sides=false,tilt=tilt);
      }
      key_column_tightest(rows,keys=false,tilt=tilt);
      mirror([1,0,0]) key_column_tightest(rows,keys=false,tilt=tilt);
    }
    translate([0,0,-21-40]) cube([200,200,80],true);
  }
}

module column_hulled_tester(d=26.8,rows=4,keys=false,footer=false,tilt=[0,0,0]) {
  if ($preview) {
    #rotate(tilt) translate([0,5.2,d+9.9]) rotate([0,90,0]) cylinder($fn=120,r=d,h=15,center=true);
  }

  difference(){
    union(){
      if (keys && $preview) {
	key_column_hulled(rows,well=false,keys=true,sides=false,tilt=tilt, widesides=false);
      }
      key_column_hulled(rows,keys=false,footer=footer,tilt=tilt, widesides=false);
      mirror([1,0,0]) key_column_hulled(rows,keys=false,footer=footer,tilt=tilt, widesides=false);
    }
    translate([0,0,-14-40]) cube([200,200,80],true);

    version=0;
    translate([-outerdia/2+.4,48,-12]) rotate([90,0,-90]) linear_extrude(.5) text(str("Cherry Manual v",version," tilt ", tilt.x), size=5);
  }
}

*column_hulled_tester(keys=true,tilt=[-10,0,0]);
*tightest_cherry_tester(keys=true,tilt=[-5,0,0]);
*flat_cherry_tester(keys=true);
*curved_cherry_tester([0,25,34], keys=true,footer=true,tilt=[-10,0,0]);
*curved_cherry_tester([14.2,0,36], keys=true,footer=true,tilt=[-10,0,0]);

*union(){
  cy =  normalize_chord_tuple([17.8,25,0]);
  cx = normalize_chord_tuple([15,cy[1],0]);
  sphere_cherry_tester(cy,cx, keys=true,footer=false,tilt=[-5,0,0]);
}

*union(){
  cy =  normalize_chord_tuple([17.8,35,0]);
  cx = normalize_chord_tuple([16,cy[1],0]);
  sphere_cherry_tester(cy,cx, keys=true,footer=false,tilt=[-5,0,0]);
}

*union(){
  cy =  normalize_chord_tuple([18.9,35,0]);
  cx = normalize_chord_tuple([15.45,cy[1],0]);
  sphere_cherry_tester(cy,cx, keys=true,footer=false,tilt=[-5,0,0], z_correct=false);
}

*union(){
  cy =  normalize_chord_tuple([15.9,35,0]);
  cx = normalize_chord_tuple([24.9,cy[1],0]);
  orbit_cherry_tester(cy,cx, keys=true,footer=false,tilt=[-5,10,0]);
}

*union(){
  cy1 = normalize_chord_tuple([15.8,35,0]);
  cy2 = normalize_chord_tuple([18.4,cy1[1],0]);
  cx = normalize_chord_tuple([19,cy1[1],0]);
  sphere_cherry_tester([cy1,cy2],cx, keys=true,footer=false,tilt=[-5,10,0],
		       trackpoints=[0,
				    [[4.3,4.4],[5.5,5,4.5,-1.2]],
				    [[4.1,1.2],[6,5,3.5,-2.5]],
				    [[4.8,-3.6],[6,5,3,-2]] ]);
}

// XXX: TESTME
*!union(){
  cy1 = normalize_chord_tuple([15.8,35,0]);
  cy2 = normalize_chord_tuple([18.7,cy1[1],0]);
  cx = normalize_chord_tuple([19,cy1[1],0]);
  sphere_cherry_tester([cy1,cy2],cx, keys=true,footer=false,tilt=[-5,10,0],
		       trackpoints=[
				    [[0,1.4],[5.5,5,4,0]],
				    [[1.2,2.5],[6,5,0,0]],
				    [[1.22,2.4],[6,5,-.5,.5]] ], fitting=false);
}
// XXX: PRINTME 2
!union(){
  cy1 = normalize_chord_tuple([17.6,25,0]);
  cy2 = normalize_chord_tuple([17.6,cy1[1],0]);
  cx = normalize_chord_tuple([19,cy1[1]*3,0]);
  sphere_cherry_tester(cy1/*[cy1,cy2]*/,cx, keys=true,footer=false,tilt=[-5,0,0],//z_correct=false,
		       trackpoints=[
				    [[-.1,.1],[5.5,5,2,0]],
				    [[0,0],[5,4,0,0]],
				    [[-.1,.3],[6,5,0.5,-.5]]] , fitting=false);
}

*union(){
  cy =  normalize_chord_tuple([17.8,35,0]);
  cx = normalize_chord_tuple([16.4,cy[1],0]);
  sphere_cherry_tester(cy,cx, keys=true,footer=false,tilt=[-5,10,0],t1=[3.7,1.7]);
}

*union(){
  cy =  normalize_chord_tuple([16.9,35,0]);
  cx = normalize_chord_tuple([17,60,0]);
  sphere_cherry_tester(cy,cx, keys=true,footer=false,tilt=[-5,0,0]);
}

*union(){
  cy =  normalize_chord_tuple([17.5,35,0]);
  cx = normalize_chord_tuple([17,cy[1]*2,0]);
  sphere_cherry_tester(cy,cx, keys=true,footer=false,tilt=[-5,0,0], z_correct=false);
}

module column_pair(rows=4,keys=false,sides=false, spacer=1.4, pos=[0,0,0], rotation=[0,0,0], center="auto", leftside=false, rightside=false) {
  assert(center == "right" || center == "left" || center == "auto");
  right_align = center == "right" || (center == "auto" && rotation.z >= 0);
  overlap=0.001;

  tilt=[rotation.x, 0,0];
  translate([pos.x,pos.y, 0]) rotate([0,0,rotation.z]) /*trimmer()*/ translate([0,0,pos.z]) rotate([0,rotation.y,0]) translate(right_align ? [0,0,0] : [(outerdia+spacer),0,0]) union() {
    if (keys) {      translate([-(outerdia+spacer),0,0]) mirror([1,0,0]) key_column_hulled(rows=rows,keys=true,well=false,sides=false,tilt=tilt);
      key_column_hulled(rows=rows,keys=true,well=false,sides=false,tilt=tilt);

    }
    translate([-(outerdia+spacer),0,0]) mirror([1,0,0]) key_column_hulled(rows=rows,keys=false,sides=sides||leftside,tilt=tilt);
    key_column_hulled(rows=rows,keys=false,sides=sides||rightside,tilt=tilt);

    // spacer to fill the gap between the two columns
    translate([-(outerdia/2) + overlap,0,0]) rotate([0,-90,0]) linear_extrude(spacer+2*overlap) projection() rotate([0,90,0]) key_column_hulled(rows=rows, sides=false,tilt=tilt);
  }
}

module noncolliding_offset_column_pair(rows=4,keys=false,sides=false, spacer=1.4, offset=[0,0,0], pos=[0,0,0], rotation=[-10,0,0], center="left") {
  assert(center == "right" || center == "left" || center == "auto");
  right_align = center == "right" || (center == "auto" && rotation.z >= 0);
  overlap=0.1;

  tilt=[rotation.x, 0,0];
  // middle+ring
  translate([pos.x,pos.y, 0]) rotate([0,0,rotation.z]) union() {
    //middle
    translate([0,offset.y,0]) trimmer() rotate([0,rotation.y,0]) {
      mirror([1,0,0]) translate([0,0,offset.z]) key_column_hulled(rows=rows,keys=keys,sides=sides,tilt=tilt);

      // side wall to connect vertically to spacer
      difference() {
	translate([0,0,offset.z]) key_column_hulled(rows=rows,keys=keys, sides=true,tilt=tilt);
	translate([outerdia/2+.1,-offset.y,0]) difference() {
	  rotate([0,-90,0]) linear_extrude(outerdia-innerdia+.2) projection() rotate([0,90,0]) key_column_hulled(rows=rows, sides=true,tilt=tilt);
	  rotate([0,-90,0]) linear_extrude(outerdia-innerdia+.2) projection() rotate([0,90,0]) key_column_hulled(rows=rows, sides=false,tilt=tilt);
	}
	translate([outerdia/2+.1,-offset.y,0]) rotate([0,-90,0]) linear_extrude(outerdia-innerdia+.2) projection() rotate([0,90,0]) difference() {
	  key_column_hulled(rows=rows, sides=true,tilt=tilt);
	  key_column_hulled(rows=rows, sides=false,tilt=tilt);
        }
      }
    }
    // ring
    trimmer() translate([outerdia+spacer,0,0]) {
      key_column_hulled(rows=rows,keys=keys,sides=sides,tilt=tilt);
    }

    // spacer
    difference () {
      // spacer should be the intersection of ring and middle on top (low as the lowest of either)
      // but as long as ring on bottom. so we intersect with sides walls to get the top
      trimmer() translate([outerdia/2+1.5,0,0]) intersection() {
        rotate([0,-90,0]) linear_extrude(1.6) projection() rotate([0,90,0]) key_column_hulled(rows=rows, sides=true,tilt=tilt);
        translate([0,offset.y, offset.z]) rotate([0,-90,0]) linear_extrude(1.6) projection() rotate([0,90,0]) key_column_hulled(rows=rows, sides=true,tilt=tilt);
      }

      // then remove the part of the wall below ring from the bottom
      translate([outerdia/2+1.6,0,0]) difference() {
        rotate([0,-90,0]) linear_extrude(1.8) projection() rotate([0,90,0]) key_column_hulled(rows=rows, sides=true,tilt=tilt);
        rotate([0,-90,0]) linear_extrude(1.8) projection() rotate([0,90,0]) key_column_hulled(rows=rows, sides=false,tilt=tilt);
      }
    }
  }
}

module offset_column_pair(rows=4,keys=false,sides=false, spacer=1.4, offset=[0,0,0], pos=[0,0,0], rotation=[-10,0,0], center="left") {
  assert(center == "right" || center == "left" || center == "auto");
  right_align = center == "right" || (center == "auto" && rotation.z >= 0);
  overlap=0.1;

  tilt=[rotation.x, 0,0];
  // middle+ring
  translate([pos.x,pos.y, 0]) rotate([0,0,rotation.z]) union() {
    //middle
    translate([0,offset.y,0]) /*trimmer()*/ rotate([0,rotation.y,0]) {
      mirror([1,0,0]) translate([0,0,offset.z]) key_column_hulled(rows=rows,keys=keys,sides=sides,tilt=tilt);
    }
    // ring
    trimmer() translate([outerdia+spacer,0,0]) {
      key_column_hulled(rows=rows,keys=keys,sides=sides,tilt=tilt);
    }

    connect_columns(pos+offset,rotation,pos+[outerdia+spacer,0,0],rotation);
  }
}

// create and position bounding box around a keywell side, position can be positive or negative side on the x or y axis
module keywell_side_bounding_box(x=0,y=0,header=false,footer=false) {
  assert(((x==1 || x==-1) && y==0) || ((y==1 || y==-1) && x ==0));

  width=.001;

  mirror([x==-1?1:0,0,0]) rotate([0,0,(y==0?0:y*90)])
    translate([outerdia/2 - width + ( ((footer && y==-1) || (header && y==1)) ? spacer/2 : 0) ,
	       -outerdia/2- ( (footer && (x != 0)) ? spacer/2 : 0),
	       -mxstem-thickness])
    cube([width,outerdia + ((footer && x != 0)? spacer/2:0) + ((header && x != 0)? spacer/2:0),thickness]);
}

module keywell_corner_bounding_box(x=0,y=0,header=false,footer=false) {
  assert((x==1 || x==-1) && (y==1 || y==-1));

  width=.001;


  mirror([x==-1?1:0,0,0]) translate([outerdia/2 - width,(y==-1)?(-outerdia/2 - (footer ? spacer/2 : 0)):(outerdia/2 - width + (header ? spacer/2 : 0)),-mxstem-thickness]) cube([width,width,thickness]);
}

module key_adjacent_bounding_box(row, pos, rotation, left=false) {
  // place bounding box on left or right side of keywell
  //x_offset = (outerdia/2) * (left ? -1 : 1) + (left ? 0 : -.01);
  // for all but the last row add the footer length
  //y_offset = 0;//(row < 4) ? 6.8: 0;

  translate([pos.x,pos.y,0])  rotate([0,0,rotation.z]) translate([0,0,pos.z]) rotate([rotation.x,rotation.y,0]) position_row(row)
    keywell_side_bounding_box(x=(left ? -1 : 1));
    //translate([x_offset,-outerdia/2-y_offset,-mxstem]) cube([.01,outerdia+y_offset,thickness]);
}

module column_hull(row, footer=false) {
  hull() {
    position_row(row) translate([0,(footer?-spacer/2:0),0]) keywell_side_bounding_box(y=-1);//translate([-outerdia/2,-(outerdia+(footer?spacer:0))/2,-mxstem]) cube([outerdia,.01,thickness]);
    position_row(row+1) keywell_side_bounding_box(y=1);//translate([-(outerdia)/2,outerdia/2,-mxstem]) cube([outerdia,.01,thickness]);
  }
}

module column_hull_bounding_box(row, pos, rotation, left=false, footer=false) {
  translate([pos.x,pos.y,0])  rotate([0,0,rotation.z]) translate([0,0,pos.z]) rotate([rotation.x,rotation.y,0])
    translate([(outerdia/2) * (left ? -1 : 1) + (left ? 0 : -.01),0,0])
    rotate([0,90,0]) linear_extrude(.01) projection() rotate([0,-90,0]) column_hull(row,footer);
}

*union() {
  #key_adjacent_bounding_box(1,[0,0,0],[-10,0,0]);
  #column_hull_bounding_box(1,[0,0,0],[-10,0,0]);
  #column_hull_bounding_box(1,[0,0,0],[-10,0,0], left=true);
  key_column_hulled(sides=false);
}

// bridges rows specified in an array, or as a sub-array pair allowing different rows to be connected
// negative values refer to the connecting hull between the given row and the next one, rather than a row itself
module connect_columns(pos1,rotation1,pos2,rotation2,rows=[1,-1,2,-2,3,-3,4]) {
  if ((len(rows) > 0) && is_list(rows[0])) {
    for (i=rows) {
      hull(){
	key_adjacent_bounding_box(i[0], pos1,rotation1);
	key_adjacent_bounding_box(i[1], pos2,rotation2,left=true);
      }
    }
  } else {
    for (i=rows) {
      if (i > 0) {
	hull(){
	  key_adjacent_bounding_box(i, pos1,rotation1);
	  key_adjacent_bounding_box(i, pos2,rotation2,left=true);
	}
      } else {
	hull(){
	  column_hull_bounding_box(-1*i, pos1,rotation1);
	  column_hull_bounding_box(-1*i, pos2,rotation2,left=true);
	}
      }
    }
  }
}


index_pos = [-(outerdia+4),-4,6];
index_rotation = [-10,5,3];
middle_offset = [0,4,1];
middle_rotation = [-10,0,0];
pinkie_pos = [outerdia+spacer+20,-13,8];
pinkie_rotation = [-5,0,-5];

module finger_plates(rows=4,keys=false,sides=false,spacer=1.4,shell=false) {
  union() {
    spacing = outerdia+spacer;

    // index
    column_pair(rows=rows,keys=keys,sides=sides,spacer=spacer,pos=index_pos, rotation=index_rotation,leftside=shell);

    if (shell) {
      rows=[each[1:4], each [-3:-1]];
      echo(rows);
      connect_columns(index_pos,index_rotation, middle_offset,middle_rotation,rows=rows);
      connect_columns([outerdia+spacer,0,0],middle_rotation,pinkie_pos,pinkie_rotation,rows=rows);
      //*translate(middle_offset+[-(outerdia/2),0,0]) rotate([0,-90,0]) linear_extrude(0.1) projection() rotate([0,90,0]) key_column_hulled(rows=rows, sides=false);

    }

    // middle+ring
    difference() {
      offset_column_pair(rows=rows,keys=keys,sides=sides,spacer=spacer,offset=middle_offset,rotation=middle_rotation);

      // shave off the bottom so we can be closer to the plate
      //translate([-20,-10,-12.5]) cube([50,70,3]);
    }
    // pinky
    column_pair(rows=rows,keys=keys,sides=sides,spacer=spacer,pos=pinkie_pos, rotation=pinkie_rotation, rightside=shell);
  }

}

module position_thumb_old(column,tilt=[11,-60,0],displacement=[0,0,-7]) {
  assert (column > 0 && column <= 3);

  thumb_radius = 68;
  thumb_tilt = [0,0,0];
  thumb_arc = [0,0,18];

  rotate([0,tilt.y,0]) translate(displacement) translate([0,-thumb_radius,0]) {
    if (column == 1) {
      rotate(thumb_tilt - thumb_arc) translate([0,thumb_radius,0]) rotate([tilt.x,0,0]) children();
    } else if (column == 2) {
      rotate(thumb_tilt) translate([0,thumb_radius,0]) rotate([tilt.x,0,0]) children();
    } else if (column== 3) {
      rotate(thumb_tilt + thumb_arc) translate([0,thumb_radius,0]) rotate([tilt.x,0,0]) children();
    }
  }
}
module position_thumb(column,tilt=[0,-60,0],chord) {
  thumb_radius = 68;
  thumb_arc = [0,0,0];//18];

  thumb_angle=[0,5,0];
  echo (chord);
  rotate(tilt) translate([0,0,-chord[1]]) rotate((2-column)*[0,chord[2],-5]) translate([0,0,chord[1]]) translate([0,-thumb_radius,0]) {
    if (column == 1) {
      rotate(- thumb_arc) translate([0,thumb_radius,0]) rotate(thumb_angle) cherry_position_row_flat(4) children();
    } else if (column == 2) {
      translate([0,thumb_radius,0])  rotate(thumb_angle) cherry_position_row_flat(4) children();
    } else if (column== 3) {
      rotate(thumb_arc) translate([0,thumb_radius,0])  rotate(thumb_angle) cherry_position_row_flat(4) children();
    }
  }
}


module thumb_plate(keys=false,well=true,angle=-60,chord=[21.5,80,0]) {
  //row4_displacement=[0,0,-7];
  //row4_tilt=11;
  echo ("p ",chord);
  c=normalize_chord_tuple(chord);

  for (i=[1:3]) {
    position_thumb(i,[0,angle,0],c){
      key_assembly(4, keys=keys, footer=true,header=true);
      if (i==1) {
	translate([outerdia/2,-(outerdia+spacer)/2,-(mxstem+thickness)]) cube([spacer/2, outerdia+spacer,thickness]);
      }
    }

    if (i>1) {
      hull() {
	position_thumb(i,[0,angle,0],c) keywell_side_bounding_box(x=1,header=true,footer=true); //translate([outerdia/2,-outerdia/2,-mxstem]) cube([.01,outerdia,thickness]);
	position_thumb(i-1,[0,angle,0],c) keywell_side_bounding_box(x=-1,header=true,footer=true); //translate([-outerdia/2,-outerdia/2,-mxstem]) cube([.01,outerdia,thickness]);
      }
    }
  }
}

*!thumb_plate(keys=true);


module drop(){
hull() {
  children();
  translate([0,0,-lowest_low]) linear_extrude(height=1) projection() children();
 }
}

module assembly(keys=false,shell=false) {
  difference() {
    // bottom plate params
    z_offset = -10;
    plate_thickness = 4.5;

    union() {

      if (shell) {
	finger_plates(keys=keys,spacer=spacer,shell=shell);

	thumb_pos = [-60,-49,21];
	chord=normalize_chord_tuple([21.5,80,0]);

	  translate(thumb_pos){
	    rotate([0,0,20]) thumb_plate(keys=keys,chord=chord);
	    drop() rotate([0,0,20]) position_thumb(3,chord=chord) keywell_side_bounding_box(x=-1,header=true,footer=true);
	  }


	hull(){
	  translate(thumb_pos) rotate([0,0,20]) position_thumb(1,chord=chord) union() {
	    keywell_side_bounding_box(y=1,header=true,footer=true);
	    translate([outerdia/2, outerdia/2+spacer/2-.001, -(mxstem+thickness)]) cube([spacer/2, .001, thickness]);
	  }
	  translate(index_pos) rotate([0,0,index_rotation.z]) rotate([0,index_rotation.y,0])
	    translate([-(spacer+outerdia),0,0]) rotate([index_rotation.x,0,0]) position_row(4) union() {
	    keywell_side_bounding_box(y=-1);
	    translate([-outerdia/2-2.55, -outerdia/2, -(mxstem+thickness)]) cube([3, .001, thickness]);
	  }
	}

	hull(){
	  translate(thumb_pos) rotate([0,0,20]) position_thumb(3,chord=chord) keywell_side_bounding_box(y=1,header=true,footer=true);
	  translate(index_pos) rotate([0,0,index_rotation.z]) rotate([0,index_rotation.y,0])
	    translate([-(spacer+outerdia),0,0]) rotate([index_rotation.x,0,0]) position_row(3) translate([-(outerdia-innerdia)/2-1,0,0]) keywell_side_bounding_box(x=-1);
	}
	hull(){
	  translate(thumb_pos) rotate([0,0,20]) position_thumb(2,chord=chord) keywell_side_bounding_box(y=1,header=true,footer=true);
	  translate(index_pos) rotate([0,0,index_rotation.z]) rotate([0,index_rotation.y,0])
	    translate([-(spacer+outerdia),0,0]) rotate([index_rotation.x,0,0]) position_row(4) translate([-(outerdia-innerdia)/2-1,0,0]) keywell_side_bounding_box(x=-1);
	}

      } else {
	magnetize([30,-14,2+z_offset-plate_thickness],cut_height=6)
	  bounded_hull_stipulated(/*sets=[[1,2,3],[0,1,3,4,5]]*/){
	  #translate([-40,-30,z_offset-plate_thickness]) cube([20,20,plate_thickness]);
	  #translate([0,-15,z_offset-plate_thickness]) cube([10,10,plate_thickness]);
	  #translate([35,-55,z_offset-plate_thickness]) cube([20,20,plate_thickness]);
	  #translate([40,5,z_offset-plate_thickness]) cube([20,20,plate_thickness]);
	  #translate([0,40,z_offset-plate_thickness]) cube([20,25,plate_thickness]);
	  #translate([-45,15,z_offset-plate_thickness]) cube([20,20,plate_thickness]);

	  //index plate mounting
	  //screw_mounting([-33,29.5,-11.5],[10,0,0],height=12, headroom=0, headroom2=6, headroom2_thickness=2)
	  //screw_mounting([-29,-18.6,-11.5],[-10,0,0],height=15, headroom=0, headroom2=5, headroom2_thickness=2)

	  //middle plate mounting
	  //heatset_mounting([5,-9,-4.5],[-5,0,0],height=6)
	  //heatset_mounting([7.7,41.5,-5],[45,0,0],height=6, headroom=14, headroom_thickness=3)

	  // pinky plate mounting
	  //screw_mounting([53,15,-11.5],[10,0,0],height=15, headroom=0, headroom2=5, headroom2_thickness=2)
	  //screw_mounting([45.6,-36-7.0,-11],[-30,0,0],height=20, spacer=3, spacer2=2, headroom=0, headroom2=8, headroom2_thickness=3) {
	  screw_mounting([45.6,-36-7.0,-11],[-30,0,0],height=20, spacer=3, spacer2=2, headroom=0, headroom2=8, headroom2_thickness=3) {
	    finger_plates(keys=keys,spacer=spacer,shell=shell);


	    //bottom plate
	    //translate([0,0,z_offset-thickness]) magnetize([30,-15,2]) linear_extrude(height=thickness) hull() projection() heatset_mounting([7.7,41.5,-5],[45,0,0],height=6, headroom=13, headroom_thickness=3) screw_mounting([45.6,-36-7.0,-11],[-30,0,0],height=20, spacer=3, spacer2=2, headroom=0, headroom2=7, headroom2_thickness=3) finger_plates();
	  }
	}
      }
    }
    //  prune any part of the mounting model that sticks through bottom plate
    translate([0,0,z_offset-(shell?3:plate_thickness)-(highest_high+lowest_low)/2]) cube([400,400,(highest_high+lowest_low)], center=true);
  }

  *translate([0,-52,2]) thumb_plate(keys=false,angle=0);
}

assembly(keys=false,shell=true);

function substitute(a2, a) = a2 < 0 ? a : a2;

module screw_mounting(pos=[0,0,0], rotation=[0,0,0], height=20, strut_dia=6.5, screw_dia=3.2, washer_dia=6.4,headroom=2,spacer=2,footroom=2, headroom_thickness=0,footroom_thickness=2, headroom2=-1,headroom2_thickness=-1, spacer2=-1) {
  assert(height==6 || height==10 || height==12 || height==15 || height==16 || height==18 || height==20 || height==21 || height==22 || height==24 || height==25 || height==26 || height==27 || height==28 || height==30);

  headroom_dia = washer_dia + headroom_thickness;
  headroom2_dia = washer_dia + substitute(headroom2_thickness, headroom_thickness);
  footroom_dia = strut_dia + footroom_thickness;
  spacer_dia = max(headroom2_dia,footroom_dia);

  headroom2_depth = substitute(headroom2, headroom);
  spacer2_depth=substitute(spacer2, spacer);

  difference() {
    union() {
      translate(pos) rotate(rotation) {
	translate([0,0,-(headroom2_depth+spacer2_depth)]) cylinder(h=headroom2_depth,d=headroom2_dia);
	translate([0,0,-spacer2_depth]) cylinder(h=spacer2_depth,d=spacer_dia);
	cylinder(h=footroom, d=footroom_dia);

	translate([0,0,height+spacer]) cylinder(h=headroom, d=headroom_dia);
	translate([0,0,height]) cylinder(h=spacer, d=spacer_dia);
	translate([0,0,height-footroom]) cylinder(h=footroom, d=footroom_dia);
      }
      children();
    }
    translate(pos) rotate(rotation) {
      translate([0,0,-(spacer2_depth+headroom2_depth)]) cylinder(h=(2*height + spacer + spacer2_depth+headroom+headroom2_depth), d=screw_dia);
      translate([0,0,-(spacer2_depth+headroom+height)]) cylinder(h=height+headroom,d=washer_dia);
      translate([0,0,height + spacer]) cylinder(h=height+headroom,d=washer_dia);
      cylinder(h=height,d=strut_dia);
    }
  }
}

module heatset_mounting(pos=[0,0,0], rotation=[0,0,0], height=20, strut_dia=6.5, screw_dia=3.2, washer_dia=6.4,headroom=5,spacer=2,footroom=2, headroom_thickness=2,footroom_thickness=2) {
  assert(height==6 || height==10 || height==12 || height==15 || height==16 || height==18 || height==20 || height==21 || height==22 || height==24 || height==25 || height==26 || height==27 || height==28 || height==30);

  headroom_dia = washer_dia + headroom_thickness;
  footroom_dia = strut_dia + footroom_thickness;
  spacer_dia = max(headroom_dia,footroom_dia);

  difference() {
    union() {
      translate(pos) rotate(rotation) {
	translate([0,0,-height]) {
	  translate([0,0,-(headroom+spacer)]) cylinder(h=headroom,d=headroom_dia);
	  translate([0,0,-spacer]) cylinder(h=spacer,d=spacer_dia);
	  cylinder(h=footroom, d=footroom_dia);
	}

	heatset_block();
	//cylinder(h=2, d=footroom_dia);
	//translate([0,0,-footroom]) cylinder(h=footroom, d=footroom_dia);
      }
      children();
    }

    translate(pos) rotate(rotation) {
      translate([0,0,-height]) {
	translate([0,0,-(spacer+headroom)]) cylinder(h=(2*height + spacer + spacer+headroom), d=screw_dia);
	translate([0,0,-(spacer+headroom+height)]) cylinder(h=height+headroom,d=washer_dia);

	cylinder(h=height,d=strut_dia);
      }

      heatset_cutout();
    }
  }
}

module heatset_cutout(){
  h=8;
  sphere_h=5.5;
  difference(){
    union(){
      translate([0,0,-.01]) cylinder(d1=4.0,d2=3.8,h=h);
      translate([0,0,sphere_h]) sphere(d=4.5);
    }
    translate([0,0,sphere_h+3.4]) cube([10,10,4],true);
  }
}
module heatset_block(){
    cylinder(d=7,h=6.3);
}
