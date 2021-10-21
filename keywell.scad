/* The most basic component of the keyboard, the key switch holder, AKA keywell.
 * and bounding boxes for the keywell's sides, used for joining them.
 * keyswitch is centered in XY and positioned so that the keycap on the switch sits at the origin in Z.
 * this is the 'neutral' position, prior to flattening of the keycaps
 */

include <settings.scad>;

// demo of the coordination of well shapes and bounding boxes
let(header=false,footer=true,rightside=true,leftside=false) {
  keywell(header=header,footer=footer,leftside=leftside,rightside=rightside);


  for (i=[-1,1]) {
    #keywell_side_bounding_box(x=i,header=header,footer=footer,leftside=leftside,rightside=rightside);
  }
  for (j=[-1,1]) {
    #keywell_side_bounding_box(y=j,header=header,footer=footer,leftside=leftside,rightside=rightside);
  }

  for (i=[-1,1]) {
    for (j=[-1,1]) {
      #keywell_corner_bounding_box(x=i,y=j,show=true,header=header,footer=footer,leftside=leftside,rightside=rightside);
    }
  }


  gap=5;
  translate ([gap+(outerdia+spacer()),gap+(outerdia+spacer()),0]) {
    keywell(header=header,footer=footer,leftside=leftside,rightside=rightside);

    #sidewall_bounding_box(rightwall=true, leftwall=true, topwall=true, bottomwall=true, header=header,footer=footer,leftside=leftside,rightside=rightside);
  }

  translate ([-(gap+(outerdia+spacer())),-(gap+(outerdia+spacer())),0]) {
    keywell(header=header,footer=footer,leftside=leftside,rightside=rightside);
    sidewall_bounding_box(rightwall=true, leftwall=true, topwall=true, bottomwall=true, header=header,footer=footer,leftside=leftside,rightside=rightside);
    for (i=[-1,1]) {
      for (j=[-1,1]) {
	#sidewall_edge_bounding_box(x=i,y=j,header=header,footer=footer,leftside=leftside,rightside=rightside);
	#sidewall_edge_bounding_box(x=i,y=j,x_aligned=false,header=header,footer=footer,leftside=leftside,rightside=rightside);

	*if (j == 1) {
	 sidewall_topper(y=i,header=header,footer=footer,leftside=leftside,rightside=rightside);
	}
      }
      *sidewall_topper(x=i,header=header,footer=footer,leftside=leftside,rightside=rightside);
    }
  }

  translate ([-(gap+(outerdia+spacer())),(gap+(outerdia+spacer())),0]) {
    keywell(header=header,footer=footer,leftside=leftside,rightside=rightside);
    sidewall_bounding_box(rightwall=true, leftwall=true, topwall=true, bottomwall=true, header=header,footer=footer,leftside=leftside,rightside=rightside);
    for (i=[-1,1]) {
      for (j=[-1,1]) {
	for (aligned=[true,false]) {
	  #sidewall_topper_bounding_box(x=i,y=j,x_aligned=aligned,header=header,footer=footer,leftside=leftside,rightside=rightside);
	}
      }
      sidewall_topper(x=i,header=header,footer=footer,leftside=leftside,rightside=rightside);
      sidewall_topper(y=i,header=header,footer=footer,leftside=leftside,rightside=rightside);
    }
  }
}

/* the basic unit of this keyboard. symmetrical along x and y, unless addition spacing is added.
 * sits below the z axis.
 */
module keywell(header=false,footer=false,leftside=false,rightside=false) {
  difference() {
    translate([0, 0, -mxstem()]) keywell_slug(header=header,footer=footer,leftside=leftside,rightside=rightside);
    keywell_cavity();
  }
}

module hotswap() {
  translate([0, 0, -mxstem()]) {
    let(x=10.9, y=4, x2=5.3, y2=6, z=3.1)
      translate([0, innerdia/2 - 2 - 1, -thickness -3.1/2]) {
      color("orange",.2) {
	cube([10.9,4,3.1], true);
	translate([-(x/2-x2/2), y/2 - y2/2,0]) cube([x2,y2,z],true);
      }
      let(x3=(14.5-x)/2, y3=1.8, z3 = 1.95) translate([0, 0, z3/2])
	color("silver", .2) {
	translate([-(x/2 + x3/2), -.5  - 2.55, 0]) cube([x3, y3, z3],true);
	translate([(x/2 + x3/2), -.5, 0]) cube([x3, y3, z3],true);
      }
    }
  }
}

/* use to cut a keywell into something. 0.1 mm margins so previews show a proper cavity
 * optionally clears space above and below the well also.
 */
module keywell_cavity(above=false, below=false) {
  margin=.1;

  translate([0, 0, -mxstem()]) union() {
    if (above) {
      height=25;
      translate([0,0,height/2]) cube([outerdia,outerdia,height], true);
    }

    // main cavity
    translate([0, 0, -thickness/2]) cube([innerdia, innerdia, thickness + 2*margin], true);

    // cutouts for switch tabs
    let(depth=tab_depth, width=tab_width, h=thickness - tab_offset){
      translate([-width/2, innerdia/2 - margin, -thickness - margin]) cube([width, depth + margin, h +margin]);
      translate([-width/2, -innerdia/2 - depth, -thickness - margin]) cube([width, depth + margin, h +margin]);

      if (below) {
	translate([0,0,-thickness - (thickness - 1)/2]) cube([innerdia, innerdia, thickness - 1], true);
      }
    }
  }
}

function optional_sum(a,b) = (a ? spacer()/2 : 0) + (b ? spacer()/2 : 0);
function optional_diff(a,b) = (a ? spacer()/4 : 0) - (b ? spacer()/4 : 0);

// the outer dimensions of the keywell, top face sits at originx
module keywell_slug(header=false,footer=false,leftside=false,rightside=false) {
  translate([optional_diff(rightside,leftside), optional_diff(header,footer), -thickness/2])
    cube([outerdia + optional_sum(leftside, rightside), outerdia + optional_sum(header, footer), thickness],
	 true);
}


/* position an object at the corner of a keywell so any parts in positive X and Y overlap the keywell
 *  and any parts in negative X or Y extend away from the keywell in that axis, possibly mirrored.
 * corners are named as either positive or negative in the X axis and y axis. I prefer using either -1 or 1
 *
 *               | Y
 *               |
 * (x=-1,y= 1)=======(x= 1,y= 1)
 *          ||   |   ||
 *   -------||---+---||-------- X
 *          ||   |   ||
 * (x=-1,y=-1)=======(x= 1,y=-1)
 *               |
 */
module position_keywell_corner(x,y,header=false,footer=false,leftside=false,rightside=false) {
  assert(x != 0 && y != 0);

  /* "default" position is -X,-Y corner, where no rotation is required, just translation.
   *  other corners are populated with mirroring
   */
  mirror([x > 0 ? 1 : 0, 0, 0]) mirror([0, y > 0 ? 1 : 0, 0])
    translate([-outerdia/2 - ((x > 0 && rightside) || (x < 0 && leftside) ? spacer()/2 : 0),
	       -outerdia/2 - ((y > 0 && header)    || (y < 0 && footer)   ? spacer()/2 : 0),
	       -mxstem()-thickness])
    children();
}

// wraps the next two functions for convenience
module keywell_bounding_box(x,y,header=false,footer=false,leftside=false,rightside=false) {
  assert(!is_undef(x) || !is_undef(y));

  if (is_undef(x) || is_undef(y)) {
    keywell_side_bounding_box(x=is_undef(x)?0:x,y=is_undef(y)?0:y,header=header,footer=footer,leftside=leftside,rightside=rightside);
  } else {
    keywell_corner_bounding_box(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside);
  }
}

/* places a small bounding box overlapping the indicated corner of a keywell.
 *  used to define the 4 corners at the intersection of 4 switches, so we can hull them together.
 */
module keywell_corner_bounding_box(x=0,y=0,header=false,footer=false,leftside=false,rightside=false, show=false) {
  assert((x==1 || x==-1) && (y==1 || y==-1));

  overlap = show ? .5 : .001;

  position_keywell_corner(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside)
    cube([overlap,overlap,thickness]);
}

/* create and position bounding box around a keywell side,
 *  position can be positive or negative side on the x or y axis
 */
module keywell_side_bounding_box(x=0,y=0,header=false,footer=false,leftside=false,rightside=false) {
  assert(((x==1 || x==-1) && y==0) || ((y==1 || y==-1) && x ==0));

  overlap = epsilon;

  if (!is_undef(x) && x != 0) {
    position_keywell_corner(x=x,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside)
      cube([overlap, outerdia + optional_sum(header,footer), thickness]);
  } else {
    position_keywell_corner(x=-1,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside)
      cube([outerdia + optional_sum(rightside,leftside), overlap, thickness]);
  }
}

function directional_decoder(v,x,y) = !is_list(v) ? v :
  x != 0 ? is_list(v.x) ? v.x[(x+1)/2] : v.x :
  is_list(v.y) ? v.y[(y+1)/2] : v.y;


// XXX need to plumb x,y for directional_decoder
module wall_bbox(length=epsilon,underhang,x_aligned=false) {
  module bbox_helper (length) {
    if (x_aligned) {
      translate([0,-wall_width/2,-wall_width/2]) rotate([0,90,0]) cylinder(d=wall_width,h=length);
    } else {
      translate([-wall_width/2,0,-wall_width/2]) rotate([-90,0,0]) cylinder(d=wall_width,h=length);
    }
  }

  if (underhang) {
    /* if the wall is wider than the side of the keywell, overlap the whole thing, if the wall is narrow,
     * align with the outside, not inside edge
     */
    underneath = (outerdia-innerdia)/2;
    displacement = (wall_width >= underneath) ? underneath : wall_width;

    if (x_aligned) {
      translate([0,displacement,0]) bbox_helper(length);
    } else {
      translate([displacement,0,0]) bbox_helper(length);
    }
  } else {
    if (x_aligned) {
      translate([0, -directional_decoder(wall_extra_room.y,0), 0]) bbox_helper(length);
    } else {
      translate([-directional_decoder(wall_extra_room.x,0), 0, 0]) bbox_helper(length);
    }
  }
}

module sidewall_bounding_box(leftwall=false,rightwall=false,topwall=false,bottomwall=false,header=false,footer=false,leftside=false,rightside=false){

  if (leftwall) {
    position_keywell_corner(x=-1,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside)
      wall_bbox(outerdia + optional_sum(header,footer), !leftside);
  }

  if (rightwall) {
    position_keywell_corner(x=1,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside)
      wall_bbox(outerdia + optional_sum(header,footer), !rightside);
  }

  if (topwall) {
    position_keywell_corner(x=-1,y=1,header=header,footer=footer,leftside=leftside,rightside=rightside)
      wall_bbox(outerdia + optional_sum(rightside,leftside), !header, x_aligned=true);
  }

  if (bottomwall) {
    position_keywell_corner(x=-1,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside)
      wall_bbox(outerdia + optional_sum(rightside,leftside), !footer, x_aligned=true);
  }
}

module sidewall_edge_bounding_box(x=0,y=0,x_aligned=true, header=false,footer=false,leftside=false,rightside=false) {
  assert((x==1 || x==-1) && (y==1 || y==-1));

  position_keywell_corner(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside)
    if (x_aligned) {
      wall_bbox(underhang=!((x == -1 && leftside) || (x == 1 && rightside)));
    } else {
      wall_bbox(underhang=!((y == -1 && footer) || (y == 1 && header)),x_aligned=true);
    }
}

// XXX: overhang needs to be narrowsides aware
module sidewall_topper(x=0,y=0, header=false,footer=false,leftside=false,rightside=false, bounding_box=false) {
  module top(overhang, length) {
    mirror(y != 0 ? [1,-1,0] : [0,0,0]) translate([-overhang, 0,0]) {
      cube([overhang,length,thickness]);
      translate([0, 0, -wall_width/2]) cube([wall_width,length,wall_width/2]);
    }
  }

  if (x != 0 && y != 0) {
    position_keywell_corner(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside)
      top(wall_width + directional_decoder(wall_extra_room,x,y), epsilon);

  } else if (x != 0) {
    position_keywell_corner(x=x,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside)
      top(wall_width + directional_decoder(wall_extra_room,x,y), outerdia + optional_sum(header,footer));
  } else {
    position_keywell_corner(x=1,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside)
      top(wall_width + directional_decoder(wall_extra_room,x,y), outerdia + optional_sum(rightside,leftside));
  }
}

module sidewall_topper_bounding_box(x=0,y=0, x_aligned=true, header=false,footer=false,leftside=false,rightside=false, bounding_box=false) {
  module top(overhang, length) {
    mirror(!x_aligned ? [1,-1,0] : [0,0,0])
    translate([-overhang, 0,0]) {
      cube([overhang,length,thickness]);
      translate([0, 0, -wall_width/2]) cube([wall_width,length,wall_width/2]);
    }

  }

  position_keywell_corner(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside)
    top(wall_width + directional_decoder(wall_extra_room,x_aligned?x:0,y), epsilon);
}
