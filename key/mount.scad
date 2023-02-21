/* The most basic component of the keyboard, the key switch holder, AKA key_mount.
 * and bounding boxes for the key_mount's sides, used for joining them.
 * keyswitch is centered in XY and positioned so that the keycap on the switch sits at the origin in Z.
 * this is the 'neutral' position, prior to flattening of the keycaps
 */

use <../settings.scad>;

// demo of the coordination of well shapes and bounding boxes
let(header=false,footer=true,rightside=true,leftside=false, $fn=60) {
  key_mount(header=header,footer=footer,leftside=leftside,rightside=rightside);


  for (i=[-1,1]) {
    #key_mount_side_bounding_box(x=i,header=header,footer=footer,leftside=leftside,rightside=rightside);
  }
  for (j=[-1,1]) {
    #key_mount_side_bounding_box(y=j,header=header,footer=footer,leftside=leftside,rightside=rightside);
  }

  for (i=[-1,1]) {
    for (j=[-1,1]) {
      #key_mount_corner_bounding_box(x=i,y=j,show=true,header=header,footer=footer,leftside=leftside,rightside=rightside);
    }
  }


  gap=5;
  translate ([gap+(outerdia()+spacer()),gap+(outerdia()+spacer()),0]) {
    key_mount(header=header,footer=footer,leftside=leftside,rightside=rightside);

    #sidewall_bounding_box(rightwall=true, leftwall=true, topwall=true, bottomwall=true, header=header,footer=footer,leftside=leftside,rightside=rightside);
  }

  translate ([-(gap+(outerdia()+spacer())),-(gap+(outerdia()+spacer())),0]) {
    key_mount(header=header,footer=footer,leftside=leftside,rightside=rightside);
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

  translate ([-(gap+(outerdia()+spacer())),(gap+(outerdia()+spacer())),0]) {
    key_mount(header=header,footer=footer,leftside=leftside,rightside=rightside);
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

  translate ([(gap+(outerdia()+spacer())),-(gap+(outerdia()+spacer())),0]) {
    key_mount(header=header,footer=footer,leftside=leftside,rightside=rightside);
    for (i=[-1,1]) {
      for (j=[-1,1]) {
	#key_mount_corner_spheres(x=i, y=j, header=header,footer=footer,leftside=leftside,rightside=rightside);
      }
    }
    for (i=[-1,1]) {
      #key_mount_corner_spheres(x=i, header=header,footer=footer,leftside=leftside,rightside=rightside);
      #key_mount_corner_spheres(y=i, header=header,footer=footer,leftside=leftside,rightside=rightside);
    }

    for (i=[-1,1]) {
      #key_mount_corner_spheres(x=i, extra_room=[5,0,0], header=header,footer=footer,leftside=leftside,rightside=rightside);
      #key_mount_corner_spheres(y=i, extra_room=[0,5,0], header=header,footer=footer,leftside=leftside,rightside=rightside);
    }
  }
  *translate ([3*(gap+(outerdia()+spacer())),-(gap+(outerdia()+spacer())),0]) {
    key_mount(header=header,footer=footer,leftside=leftside,rightside=rightside);
    for (i=[-1,1]) {
      #key_mount_corner_spheres(x=i, header=header,footer=footer,leftside=leftside,rightside=rightside);
      #key_mount_corner_spheres(y=i, header=header,footer=footer,leftside=leftside,rightside=rightside);
    }

    for (i=[-1,1]) {
      #key_mount_corner_spheres(x=i, extra_room=[5,0,0], header=header,footer=footer,leftside=leftside,rightside=rightside);
      #key_mount_corner_spheres(y=i, extra_room=[0,5,0], header=header,footer=footer,leftside=leftside,rightside=rightside);
    }
  }
}

/* the basic unit of this keyboard. symmetrical along x and y, unless addition spacing is added.
 * sits below the z axis.
 */
module key_mount(header=false,footer=false,leftside=false,rightside=false) {
  difference() {
    translate([0, 0, -stem_height()]) key_mount_slug(header=header,footer=footer,leftside=leftside,rightside=rightside);
    key_mount_cavity();
  }
}

module hotswap() {
  translate([0, 0, -stem_height()]) {
    let(x=10.9, y=4, x2=5.3, y2=6, z=3.1)
      translate([0, innerdia()/2 - 2 - 1, -thickness() -3.1/2]) {
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

/* use to cut a key_mount into something. 0.1 mm margins so previews show a proper cavity
 * optionally clears space above and below the well also.
 */
module key_mount_cavity(above=false, below=false) {
  margin=.1;

  translate([0, 0, -stem_height()]) union() {
    if (above) {
      height=25;
      translate([0,0,height/2]) cube([outerdia(),outerdia(),height], true);
    }

    // main cavity
    translate([0, 0, -thickness()/2]) cube([innerdia(), innerdia(), thickness() + 2*margin], true);

    // cutouts for switch tabs
    let(depth=mx_tab_depth(), width=mx_tab_width(), h=thickness() - mx_tab_offset()){
      translate([-width/2, innerdia()/2 - margin, -thickness() - margin]) cube([width, depth + margin, h +margin]);
      translate([-width/2, -innerdia()/2 - depth, -thickness() - margin]) cube([width, depth + margin, h +margin]);

      if (below) {
	translate([0,0,-thickness() - (thickness() - 1)/2]) cube([innerdia(), innerdia(), thickness() - 1], true);
      }
    }
  }
}

function optional_sum(a,b) = (a ? spacer()/2 : 0) + (b ? spacer()/2 : 0);
function optional_diff(a,b) = (a ? spacer()/4 : 0) - (b ? spacer()/4 : 0);

// the outer dimensions of the key_mount, top face sits at originx
module key_mount_slug(header=false,footer=false,leftside=false,rightside=false) {
  translate([optional_diff(rightside,leftside), optional_diff(header,footer), -thickness()/2])
    cube([outerdia() + optional_sum(leftside, rightside), outerdia() + optional_sum(header, footer), thickness()],
	 true);
}


/* position an object at the corner of a key_mount so any parts in positive X and Y overlap the key_mount
 *  and any parts in negative X or Y extend away from the key_mount in that axis, possibly mirrored.
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
module position_key_mount_corner(x,y,header=false,footer=false,leftside=false,rightside=false, extra_room=[0,0,0]) {
  assert(x != 0 && y != 0);

  /* "default" position is -X,-Y corner, where no rotation is required, just translation.
   *  other corners are populated with mirroring
   */
  mirror([x > 0 ? 1 : 0, 0, 0]) mirror([0, y > 0 ? 1 : 0, 0])
    translate([-outerdia()/2 - ((x > 0 && rightside) || (x < 0 && leftside) ? spacer()/2 : 0),
	       -outerdia()/2 - ((y > 0 && header)    || (y < 0 && footer)   ? spacer()/2 : 0),
	       -stem_height()-thickness()] - (is_undef(extra_room) ? [0,0,0] : extra_room))
    children();
}

// wraps the next two functions for convenience
module key_mount_bounding_box(x,y,header=false,footer=false,leftside=false,rightside=false) {
  assert(!is_undef(x) || !is_undef(y));

  if (is_undef(x) || is_undef(y)) {
    key_mount_side_bounding_box(x=is_undef(x)?0:x,y=is_undef(y)?0:y,header=header,footer=footer,leftside=leftside,rightside=rightside);
  } else {
    key_mount_corner_bounding_box(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside);
  }
}

/* places a small bounding box overlapping the indicated corner of a key_mount.
 *  used to define the 4 corners at the intersection of 4 switches, so we can hull them together.
 */
module key_mount_corner_bounding_box(x=0,y=0,header=false,footer=false,leftside=false,rightside=false, show=false) {
  assert((x==1 || x==-1) && (y==1 || y==-1));

  overlap = show ? .5 : .001;

  position_key_mount_corner(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside)
    cube([overlap,overlap,thickness()]);
}

/* create and position bounding box around a key_mount side,
 *  position can be positive or negative side on the x or y axis
 */
module key_mount_side_bounding_box(x=0,y=0,header=false,footer=false,leftside=false,rightside=false) {
  assert(((x==1 || x==-1) && y==0) || ((y==1 || y==-1) && x ==0));

  overlap = epsilon();

  if (!is_undef(x) && x != 0) {
    position_key_mount_corner(x=x,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside)
      cube([overlap, outerdia() + optional_sum(header,footer), thickness()]);
  } else {
    position_key_mount_corner(x=-1,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside)
      cube([outerdia() + optional_sum(rightside,leftside), overlap, thickness()]);
  }
}

module key_mount_corner_spheres(x,y,width=thickness(), header=false,footer=false,leftside=false,rightside=false, extra_room=[0,0,0]) {
  position_key_mount_corner(x=is_undef(x)?-1:x,y=is_undef(y)?-1:y,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room) translate([0,0,width/2]){
    if (is_undef(x) || x == 0){
      h = outerdia() + optional_sum(rightside,leftside);
      if (extra_room == [0,0,0]) {
	rotate([0,90,0]) difference() {
	  cylinder(d=width, h=h);
	  if (extra_room == [0,0,0]) translate([-width/2,0,0]) cube([width, width,h]);
	}
      } else {
	sphere(d=width);
	translate([outerdia() + optional_sum(rightside,leftside), 0 , 0]) sphere(d=width);
      }
    } else if (is_undef(y) || y == 0) {
      h=outerdia() + optional_sum(header,footer);
      if (extra_room == [0,0,0]) {
	rotate([-90,0,0]) difference() {
	  cylinder(d=width, h=h);
	  if (extra_room == [0,0,0]) translate([0,-width/2,0]) cube([width, width,h]);
	}
      } else {
	sphere(d=width);
	translate([0, outerdia() + optional_sum(header,footer), 0]) sphere(d=width);
      }
    } else {
      difference() {
	sphere(d=width);
	if (extra_room == [0,0,0]) {
	  //translate([0,0,-width/2]) cube([width,width,width]);
	  translate([0,-width/2,-width/2]) cube([width,width,width]);
	  translate([-width/2,0,-width/2]) cube([width,width,width]);
	}
      }
    }
  }
}

function directional_decoder(v,x,y) = !is_list(v) ? v :
  x != 0 ? is_list(v.x) ? v.x[(x+1)/2] : v.x :
  is_list(v.y) ? v.y[(y+1)/2] : v.y;


// XXX need to plumb x,y for directional_decoder
module wall_bbox(length=epsilon(),underhang,x_aligned=false) {
  module bbox_helper (length) {
    if (x_aligned) {
      translate([0,-wall_width()/2,-wall_width()/2]) rotate([0,90,0]) cylinder(d=wall_width(),h=length);
    } else {
      translate([-wall_width()/2,0,-wall_width()/2]) rotate([-90,0,0]) cylinder(d=wall_width(),h=length);
    }
  }

  if (underhang) {
    /* if the wall is wider than the side of the key_mount, overlap the whole thing, if the wall is narrow,
     * align with the outside, not inside edge
     */
    underneath = (outerdia()-innerdia())/2;
    displacement = (wall_width() >= underneath) ? underneath : wall_width();

    if (x_aligned) {
      translate([0,displacement,0]) bbox_helper(length);
    } else {
      translate([displacement,0,0]) bbox_helper(length);
    }
  } else {
    if (x_aligned) {
      translate([0, -directional_decoder(wall_extra_room().y,0), 0]) bbox_helper(length);
    } else {
      translate([-directional_decoder(wall_extra_room().x,0), 0, 0]) bbox_helper(length);
    }
  }
}

module sidewall_bounding_box(leftwall=false,rightwall=false,topwall=false,bottomwall=false,header=false,footer=false,leftside=false,rightside=false, extra_room=[0,0,0]){

  if (leftwall) {
    position_key_mount_corner(x=-1,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room)
      wall_bbox(outerdia() + optional_sum(header,footer), !leftside);
  }

  if (rightwall) {
    position_key_mount_corner(x=1,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room)
      wall_bbox(outerdia() + optional_sum(header,footer), !rightside);
  }

  if (topwall) {
    position_key_mount_corner(x=-1,y=1,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room)
      wall_bbox(outerdia() + optional_sum(rightside,leftside), !header, x_aligned=true);
  }

  if (bottomwall) {
    position_key_mount_corner(x=-1,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room)
      wall_bbox(outerdia() + optional_sum(rightside,leftside), !footer, x_aligned=true);
  }
}

module sidewall_edge_bounding_box(x=0,y=0,x_aligned=true, header=false,footer=false,leftside=false,rightside=false, extra_room=[0,0,0]) {
  assert((x==1 || x==-1) && (y==1 || y==-1));

  position_key_mount_corner(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room)
    if (x_aligned) {
      wall_bbox(underhang=!((x == -1 && leftside) || (x == 1 && rightside)));
    } else {
      wall_bbox(underhang=!((y == -1 && footer) || (y == 1 && header)),x_aligned=true);
    }
}

/* eventually we'd like to support at least 4 topper styles:
 *  - one thats just a rectangular prism, flush with the top of the switchmount
 *  - one thats angled, rather than squared off, connecting the top edge of the switchmount to the
 *     furthest outside edge of the sidewall cylinder
 *  - one thats a half cylinder adjacent to the switchmount, linked to the sidewall cylinder with
 *     a prism, ie a rounded version of the above that automatically moves the wall to be flush
 *  - one that adds a bezel around the keys, with a configurable bezel width and distance, smoothly
 *     uniting the bezel bottom to the sidewall cylinder. round top bezel or squared off?
 */
module sidewall_topper(x=0,y=0, header=false,footer=false,leftside=false,rightside=false, bounding_box=false, extra_room=[0,0,0], underhang) {
  module top(overhang, length, underhang) {
    angled_topper=false;
    let(overhang = overhang - (underhang ? (outerdia() - innerdia())/2 : 0)) {
      mirror(y != 0 ? [1,-1,0] : [0,0,0]) translate([-overhang, 0, 0]) {
	difference() {
	  cube([overhang,length,thickness()]);

	  if (angled_topper)
	    rotate([0,-atan(thickness()/overhang),0])
	      translate([-1, -1, 0]) // clean margins
	      cube([overhang+10, 2 + length,20]);
	}
	translate([0, 0, -wall_width()/2]) cube([wall_width(),length,wall_width()/2]);
      }
    }
  }

  // need x_aligned or equivalent to replace sidewall_topper_bounding_box with this
  if (x != 0 && y != 0) {
    position_key_mount_corner(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room)
      top(wall_width() + directional_decoder(wall_extra_room(),x,y), epsilon());
  } else if (x != 0) {
    let (underhang = !is_undef(underhang) ? underhang : (x == 1 && !rightside) || (x == -1 && !leftside))
      position_key_mount_corner(x=x,y=-1,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room)
      top(wall_width() + directional_decoder(wall_extra_room(),x,y), outerdia() + optional_sum(header,footer), underhang);
  } else {
    let (underhang = !is_undef(underhang) ? underhang : (y == 1 && !header) || (y == -1 && !footer))
      position_key_mount_corner(x=1,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room)
      top(wall_width() + directional_decoder(wall_extra_room(),x,y), outerdia() + optional_sum(rightside,leftside), underhang);
  }
}

module sidewall_topper_bounding_box(x=0,y=0, x_aligned=true, header=false,footer=false,leftside=false,rightside=false, bounding_box=false, extra_room=[0,0,0], underhang) {
  module top(overhang, length, underhang) {
    angled_topper=false;
    let(overhang = overhang - (underhang ? (outerdia() - innerdia())/2 : 0)) {
      mirror(!x_aligned ? [1,-1,0] : [0,0,0]) translate([-overhang, 0,0]) {
        difference() {
	  cube([overhang,length,thickness()]);

	  if (angled_topper)
	    rotate([0,-atan(thickness()/overhang),0])
	      translate([-1,-1,0]) cube([overhang+10, 2 + length,20]);
	}

	translate([0, 0, -wall_width()/2]) cube([wall_width(),length,wall_width()/2]);
      }
    }
  }

  let (underhang = !is_undef(underhang) ? underhang :
       x_aligned ? (x == 1 && !rightside) || (x == -1 && !leftside) :
       (y == 1 && !header) || (y == -1 && !footer))
    position_key_mount_corner(x=x,y=y,header=header,footer=footer,leftside=leftside,rightside=rightside,extra_room=extra_room)
    top(wall_width() + directional_decoder(wall_extra_room(),x_aligned?x:0,y), epsilon(), underhang);
}
