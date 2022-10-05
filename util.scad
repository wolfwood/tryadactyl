// utility functions

function xor(a,b) = (a && !b) || (!a && b);

// makes a number of clones of a supbtreem/ rotated and spaced evenly around the origin
module rotational_clone(clones=2) {
  for(i=[0:clones-1] ) {
    rotate([0,0,i * (360/clones)]) children();
  }
}

/* one take on 'loft' - takes pairs of bounding boxes and then the model as the final child.
 *  joins the parts of the model within the bounding pairs, ideally connecting convex surfaces,
 *  while preserving the concavity of the model */
module bounded_hull() {
  end=$children-1;
  union() {
    children(end);
    for(i=[0:2:end-1-(end%2)]) {
      difference() {
	hull() {
	  intersection() {
	    children(end);
	    children(i);
	  }
	  intersection() {
	    children(end);
	    children(i+1);
	  }
	}
	hull() intersection() {
	  children(end);
	  children(i);
	}
	hull() intersection() {
	  children(end);
	  children(i+1);
	}
      }
    }
  }
}

/* similar to bounded hull, but instead of taking pairs of bounds, connects all the bounds in sequence,
 *  wrapping at the end, to make a hamiltonian circuit. */
module bounded_hull_circuit() {
  function nextwrap(i) = i+1 == $children-1 ? 0 : i+1;
  end=$children-1;
  union() {
    children(end);
    for(i=[0:end-1]) {
      difference() {
	hull() {
	  intersection() {
	    children(end);
	    children(i);
	  }
	  intersection() {
	    children(end);
	    children(nextwrap(i));
	  }
	}
	hull() intersection() {
	  children(end);
	  children(i);
	}
	hull() intersection() {
	  children(end);
	  children(nextwrap(i));
	}
      }
    }
  }
}

/* similar to bounded hull, but takes an array of vectors, each of which specifies 2 or more
 *  bounding boxes to be connected. can be upsed with pairs similarly to bounded_hull, but without
 *  having to potentially duplicate bounding boxes, or in a more free-form manner to build a
 *  non-convex hull out of convex subsets of bounds.
 */
module bounded_hull_stipulated(sets=[]) {
  end=$children-1;
  union() {
    children(end);
    for(set=sets){
      difference() {
	hull() intersection() {
	  children(end);
	  children(set);
	}
	for(i=set) {
	  hull() intersection() {
	    children(end);
	    children(i);
	  }
	}
      }
    }
    /*for(i=pair) {
      difference() {
	hull() {
	  intersection() {
	    children(end);
	    children(i[0]);
	  }
	  intersection() {
	    children(end);
	    children(i[1]);
	  }
	}
	hull() intersection() {
	  children(end);
	  children(i[0]);
	}
	hull() intersection() {
	  children(end);
	  children(i[1]);
	}
      }
      }*/
  }
}

// adds a mount for a cup magnet at a given position
module magnetize(position=[0,0,0], cut_height=9, post_height=12) {
  union() {
    difference() {
      /* idk why you would call this on a set of objects since there is only one position, but just
       *  in case union the children because otherwise the difference will subtract the subsequent
       *  children from the first one
       */
      union(){
        children();
      }

      /* a loose fitting hole for the magnet, bringing it is closer to the work surface (force is
       *  proportional to the square of distance), maybe also provides some support when moving laterally
       */
      translate(position) cylinder(cut_height,d=33,$fn=64);
    }
    // change diameter if you need to accomodate a different screw size
    translate(position) cylinder(post_height,d=3.5,$fn=64);
  }
}

// adds a mount for a cup magnet at a given position
module magnetize_screwed(position=[0,0,0], cut_height=9) {
  epsilon=.1;

  difference() {
    /* idk why you would call this on a set of objects since there is only one position, but just
     *  in case union the children because otherwise the difference will subtract the subsequent
     *  children from the first one
     */
    union(){
      children();
    }

    /* a loose fitting hole for the magnet, bringing it is closer to the work surface (force is
     *  proportional to the square of distance), maybe also provides some support when moving laterally
     */
    translate(position+[0,0,2]) cylinder(cut_height,d=33,$fn=60);

    translate(position) cylinder(h=cut_height, d=3.8, $fn=60);
    translate(position+[0,0,-epsilon]) cylinder(h=2+epsilon, d1=7.1, d2=3.8, $fn=60);
  }
}

*magnetize_screwed() translate([0,0,2])  cube([75,75,4], true);

module bar_magnetize_below(position=[0,0,0], rotation=[0,0,0], spacer=0, walls=2, ceiling=2, washer=0, grow=[0,0,0]) {
  bar = [14, 60.5, 5.5+1];
  epsilon=.1;

  outer = bar+[2*walls,2*walls,ceiling+spacer];
  difference() {
    union(){
      children();

      translate(position) rotate(rotation)
	translate([-outer.x/2+min(grow.x,0),-outer.y/2+min(grow.y,0),0])
	cube(outer+[abs(grow.x),abs(grow.y),abs(grow.z)]);
    }
    translate(position) rotate(rotation) {
      translate([0,0,(bar.z/2 + spacer - epsilon)]) cube(bar+[0,0,epsilon*2], true);
      rotational_clone() translate([0,45/2,0]) cylinder($fn=60,h=2*(outer.z+epsilon), d=3.6, center=true);
    }
    if (washer>0) {
      translate(position) rotate(rotation) {
	rotational_clone() translate([0,45/2,outer.z]) cylinder($fn=60,h=100, d=washer);
      }
    }
  }
}

*bar_magnetize_below() translate([0,0,2])  cube([50,75,4], true);

module bar_magnetize(position=[0,0,0], spacer=2) {
  bar = [14, 60.5, 5.5];
  epsilon=.1;

  difference() {
    children();

    translate(position) rotate(rotation) {
      translate([0,0,(bar.z/2 + spacer + epsilon)]) cube(bar+[0,0,epsilon*2], true);

      rotational_clone() translate([0,45/2,-epsilon]) cylinder($fn=60,h=spacer+2*epsilon, d=3.4);
      rotational_clone() translate([0,45/2,-epsilon]) cylinder($fn=60,h=2+2*epsilon, d1=5.6, d2=3.4);
    }
  }
}

*bar_magnetize() translate([0,0,2])  cube([50,75,4], true);

module mount_teensy20pp(position=[0,0,0], rotation=[0,0,0], spacer=2, walls=2, diode=false) {
  slop =.1;
  bar = [18.2+slop, 51.2+slop, 8+spacer];
  epsilon=.1;

  outer = bar+[2*walls,2*walls,0];

  if ($preview) {

    translate(position) rotate(rotation) let(z1=18.5,z2=23-18.5) translate([0,0,spacer]) {
      color("black", .2) translate([0,0,z1/2]) cube(bar + [0,0,z1 - bar.z], true);
      color("blue", .2) translate([0,0,z1+z2/2]) cube(bar + [0,0,z2 - bar.z], true);
    }
  }

  pitch=2.54;
  difference() {
    union(){
      children();

      translate(position) rotate(rotation)
	translate([0,0,(outer.z/2)]) cube(outer, true);
    }

    translate(position) rotate(rotation) {
      // cavity for teensy
      translate([0,0,(bar.z/2 + spacer + epsilon)]) cube(bar+[0, 0, epsilon*2], true);

      // for pin headers
      rotational_clone() translate([bar.x/2-1, 0, spacer]) cube([2, bar.y, 2],true);
      // bonus interior pins
      translate([0, -pitch/2-3*pitch, spacer]) cube([2, 4*pitch+2, 2], true);
      translate([pitch, -pitch/2-3*pitch, spacer]) cube([2, 4*pitch+2, 2], true);
      // reversed for when reflected for opposite hand
      translate([-pitch, -pitch/2-3*pitch, spacer]) cube([2, 4*pitch+2, 2], true);
      // reset pins
      translate([0,-pitch/2 - 9*pitch, spacer]) cube([bar.x, 2 , 2], true);

      // usb
      translate([0, bar.y/2, bar.z/2+spacer+7/2]) cube([11, 40, bar.z+7],true);

      // for VBUS detect shottky
      if (diode) translate([0,(pitch/2)+(4*pitch)+(pitch*3/2),spacer]) cube([8,pitch*3,4],true);
    }
  }
}

*mount_teensy20pp() translate([0,0,2])  cube([50,75,4], true);

module mount_trrs(position=[0,0,0], rotation=[0,0,0], spacer=2, walls=2) {
  slop = .1;
  bar = [6.5+slop, 12.5+slop, 8 + spacer];
  epsilon=.1;

  outer = bar + [2*walls,2*walls,0];

  difference() {
    union(){
      children();

      translate(position) rotate(rotation)
	translate([0,0,(outer.z/2)]) cube(outer, true);
    }

    translate(position) rotate(rotation) {
      // cavity for jack
      translate([0,0,(bar.z/2 + spacer + epsilon)]) cube(bar+[0, 0, epsilon*2], true);

      // connector
      translate([0, bar.y/2, bar.z/2+spacer+epsilon/2]) cube([5.5, (epsilon+max(2,walls))*2, bar.z+epsilon],true);

      // plug
      translate([0, bar.y/2+walls, spacer+2.5]) rotate([-90,0,0]) cylinder($fn=60, d=6.25, h=50);
    }
  }
  translate(position) rotate(rotation)
    translate([bar.x/2, 0, 5.4]) rotate([90,0,0]) cylinder($fn=60, d=.3, h=8, center=true);
}

*mount_trrs() translate([0,0,2])  cube([30,30,4], true);

module mount_permaproto_flat(position=[0,0,0], rotation=[0,0,0], spacer=4+2.5, margin=2,washer_dia=6.4, screw_h=2.7) {
  bar = [2,53,33];

  if ($preview) {
    translate(position+[bar.z,0,spacer]+[margin,margin,0]) rotate([0,-90,0]){
      color("white", .4) cube(bar);
      pitch=2.54;
      translate([2,53/2,33/2]) rotate([0,90,0]) translate([0,0,17.5/2]) color("black", .2) cube([12*pitch,15*pitch,17.5], true);
    }
  }

  children();

  translate(position+[margin,margin,0]) let(w=bar.z,l=bar.y) {
    difference() {
      union() {
	translate([-margin,-margin,0]) cube([w+margin*2, l+margin*2, 4]);
	translate([0,l-8,0]) cube([8,8,spacer]);
	translate([w-8,l-8,0]) cube([8,8,spacer]);

	translate([0,0,0]) cube([8,8,spacer]);
	translate([w-8,0,0]) cube([8,8,spacer]);

      }
      translate([4,l-4,0]) {
	cylinder(d=3.4,h=30,center=true,$fn=60);
	cylinder(d=washer_dia,h=screw_h*2,center=true,$fn=60);
      }
      translate([w-4,l-4,0]){
	cylinder(d=3.4,h=30,center=true,$fn=60);
	cylinder(d=washer_dia,h=screw_h*2,center=true,$fn=60);
      }
      translate([4,4,0]){
	cylinder(d=3.4,h=30,center=true,$fn=60);
	cylinder(d=washer_dia,h=screw_h*2,center=true,$fn=60);
      }
      translate([w-4,4,0]){
	cylinder(d=3.4,h=30,center=true,$fn=60);
	cylinder(d=washer_dia,h=screw_h*2,center=true,$fn=60);
      }
    }
  }
}

mount_permaproto_flat();


module mount_permaproto(position=[0,0,0], rotation=[0,0,0], spacer=4.5, walls=2,rail1=15.5, rail2=20) {
  bar = [2,53,33];

  if ($preview) {
    translate(position+[0,0,spacer]) {
      color("white", .4) cube(bar);
      pitch=2.54;
      translate([2,53/2,33/2]) rotate([0,90,0]) translate([0,0,17.5/2]) color("black", .2) cube([12*pitch,15*pitch,17.5], true);
    }
  }

  children();
  let(w=6,l=53-2*4,h=4) {
    translate(position+[2,4,0]){
      // fill in between rails to help prevent peeling
      cube([min(rail1,rail2), l, h]);
      //support the ends of the rails
      //cube([w,l,h]);

      difference() {
	union () {
	  translate([0,-w/2,0]) {
	    cube([w, w, spacer + bar.z]);
	    cube([rail2, w, h]);
	  }
	}
	translate([0,0,spacer+4]) rotate([0,90,0]) cylinder(d=3.4,h=20,center=true,$fn=60);
	translate([0,0,spacer+33-4]) rotate([0,90,0]) cylinder(d=3.4,h=20,center=true,$fn=60);
      }
      translate([0,l,0]){
	difference() {
	  union () {
	    translate([0,-w/2,0]) {
	      cube([w, w, spacer + bar.z]);
	      cube([rail1, w, h]);
	    }
	  }
	  translate([0,0,spacer+4]) rotate([0,90,0]) cylinder(d=3.4,h=20,center=true,$fn=60);
	  translate([0,0,spacer+33-4]) rotate([0,90,0]) cylinder(d=3.4,h=20,center=true,$fn=60);
	}
      }
    }
  }
}

*mount_permaproto();


module mount_foot(position=[0,0,0], rotation=[0,0,0], protrusion=.8) {
  epsilon = .1;
  difference() {
    children();
    translate(position-[0,0,protrusion+epsilon]) rotate(rotation) cylinder(d=8.3, h=2+epsilon);
  }
}
