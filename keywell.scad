
use <util.scad>;

thickness=4;
innerdia=13.9;
outerdia=17;
tilt=-10;
spacer = 1.4;
mxstem = 6.1;

// use to cut a keywell into something
module keywell_cavity() {
  union() {
    translate([0,0,thickness/2]) cube([innerdia, innerdia, thickness+.01], true);
    translate([-2.5,innerdia/2,0]) cube([5, 0.6, 2.8]);
    translate([-2.5,-innerdia/2-0.6,0]) cube([5, 0.6, 2.8]);
  }
}

// the basic unit of this keyboard. symmetrical along x and y
module keywell() {
  difference() {
    translate([0,0,thickness/2]) cube([outerdia, outerdia, thickness], true);
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
module key_assembly(row=3,keys=false,well=true, sides=false,header=true,footer=true) {
  wall = (outerdia-innerdia)/2;
  union(){
    if (keys) {
      if (row < 5) {
	cherry_row(row) key();
      } else {
	cherry_row(4) key();
      }
    }
    translate([0,0,-mxstem]) union(){
      if (well) {
	if (header) {
	  height=4.8;
	  translate([0,(outerdia/2)-wall/2,-height/2]) cube([outerdia,wall,height],true);
	}
	keywell();
	if(footer) {
	  length=6.8;
	  dia=wall*2-.5;
	  translate([0,-(outerdia/2)-(length/2),(thickness/2)]) cube([outerdia,length,thickness],true);
	  translate([0,-(outerdia/2)-(length), dia/2]) rotate([0,90,0]) cylinder(h=outerdia, d=dia,center=true);
	}
	if (sides) {
	  height = 4.5+thickness+60;
	  width = (outerdia-innerdia)/2;

	  translate([outerdia/2-width/2,0,-((height)/2)+thickness]) cube([width,outerdia,height], true);
	  //mirror([1,0,0]) translate([outerdia/2-width/2,0, -((height)/2)+thickness]) cube([width,outerdia,height], true);
	  if (row <4) {
	    translate([outerdia/2-width/2,-(outerdia/2) -1,-((height)/2)+thickness]) cube([width,outerdia+17,height], true);
	    //mirror([1,0,0]) translate([outerdia/2-width/2,-(outerdia/2) -1,-((height)/2)+thickness]) cube([width,outerdia+2,height], true);
	  }
	}
      }
    }
  }
}


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

// hand positioned column for cherry keycaps, cuprved so the tops of the keycaps are nearly touching
module position_row(row) {
  assert(row > 0 && row < 6 );

  if (row == 1) {
    translate([0,2*18.5-.1,12.3]) rotate([55,0,0]) children();
  } else if (row == 2) {
    translate([0,18.5+1.3,1.9]) rotate([28,0,0]) children();
  } else if (row == 3) {
    children();
  } else if (row == 4) {
    translate([0,-18.5-.1,7.2]) rotate([-32,0,0]) children();
  } else if (row == 5) {
    translate([0,-2*18.5+8.2,24]) rotate([-60,0,0]) children();
  }
}


// hand positioned column for cherry keycaps, cuprved so the tops of the keycaps are nearly touching
module key_column_tightest(rows=4,keys=false,well=true, sides=true,tilt=[-10,0,0]) {
  rotate(tilt) union() {
    if (rows == 5) {
      position_row(5) key_assembly(5,keys,well,sides,footer=false);
    }
    position_row(4) key_assembly(4,keys,well,sides,footer=(rows > 4) );

    position_row(3) key_assembly(3,keys,well,sides);
    position_row(2) key_assembly(2,keys,well,sides, header=(rows > 3) );
    if (rows > 3) {
      position_row(1) key_assembly(1,keys,well,sides,header=false);
    }
  }
}


module column_pair(rows=4,keys=false,sides=false, spacer=1.4, pos=[0,0,0], rotation=[0,0,0], center="auto", leftside=false, rightside=false) {
  assert(center == "right" || center == "left" || center == "auto");
  right_align = center == "right" || (center == "auto" && rotation.z >= 0);
  overlap=0.1;

  tilt=[rotation.x, 0,0];
  translate([pos.x,pos.y, 0]) rotate([0,0,rotation.z]) trimmer() translate([0,0,pos.z]) rotate([0,rotation.y,0]) translate(right_align ? [0,0,0] : [(outerdia+spacer),0,0]) union() {
    translate([-(outerdia+spacer),0,0]) mirror([1,0,0]) key_column_tightest(rows=rows,keys=keys,sides=sides||leftside,tilt=tilt);
    key_column_tightest(rows=rows,keys=keys,sides=sides||rightside,tilt=tilt);

    // spacer to fill the gap between the two columns
    translate([-(outerdia/2) + overlap,0,0]) rotate([0,-90,0]) linear_extrude(spacer+2*overlap) projection() rotate([0,90,0]) key_column_tightest(rows=rows, sides=false,tilt=tilt);
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
    translate([0,offset.y,0]) trimmer() rotate([0,rotation.y,0]) {
      mirror([1,0,0]) translate([0,0,offset.z]) key_column_tightest(rows=rows,keys=keys,sides=sides,tilt=tilt);

      // side wall to connect vertically to spacer
      difference() {
	translate([0,0,offset.z]) key_column_tightest(rows=rows,keys=keys, sides=true,tilt=tilt);
	translate([outerdia/2+.1,-offset.y,0]) difference() {
	  rotate([0,-90,0]) linear_extrude(outerdia-innerdia+.2) projection() rotate([0,90,0]) key_column_tightest(rows=rows, sides=true,tilt=tilt);
	  rotate([0,-90,0]) linear_extrude(outerdia-innerdia+.2) projection() rotate([0,90,0]) key_column_tightest(rows=rows, sides=false,tilt=tilt);
	}
	translate([outerdia/2+.1,-offset.y,0]) rotate([0,-90,0]) linear_extrude(outerdia-innerdia+.2) projection() rotate([0,90,0]) difference() {
	  key_column_tightest(rows=rows, sides=true,tilt=tilt);
	  key_column_tightest(rows=rows, sides=false,tilt=tilt);
        }
      }
    }
    // ring
    trimmer() translate([outerdia+spacer,0,0]) {
      key_column_tightest(rows=rows,keys=keys,sides=sides,tilt=tilt);
    }

    // spacer
    difference () {
      // spacer should be the intersection of ring and middle on top (low as the lowest of either)
      // but as long as ring on bottom. so we intersect with sides walls to get the top
      trimmer() translate([outerdia/2+1.5,0,0]) intersection() {
        rotate([0,-90,0]) linear_extrude(1.6) projection() rotate([0,90,0]) key_column_tightest(rows=rows, sides=true,tilt=tilt);
        translate([0,offset.y, offset.z]) rotate([0,-90,0]) linear_extrude(1.6) projection() rotate([0,90,0]) key_column_tightest(rows=rows, sides=true,tilt=tilt);
      }

      // then remove the part of the wall below ring from the bottom
      translate([outerdia/2+1.6,0,0]) difference() {
        rotate([0,-90,0]) linear_extrude(1.8) projection() rotate([0,90,0]) key_column_tightest(rows=rows, sides=true,tilt=tilt);
        rotate([0,-90,0]) linear_extrude(1.8) projection() rotate([0,90,0]) key_column_tightest(rows=rows, sides=false,tilt=tilt);
      }
    }
  }
}

module key_adjacent_bounding_box(row, pos, rotation, left=false) {
  // place bounding box on left or right side of keywell
  x_offset = (outerdia/2) * (left ? -1 : 1) + (left ? 0 : -.01);
  // for all but the last row add the footer length
  y_offset = (row < 4) ? 6.8: 0;

  translate([pos.x,pos.y,0])  rotate([0,0,rotation.z]) translate([0,0,pos.z]) rotate([rotation.x,rotation.y,0]) position_row(row)
    translate([x_offset,-outerdia/2-y_offset,-mxstem]) cube([.01,outerdia+y_offset,thickness]);
}

module connect_column_pairs(pos1,rotation1,pos2,rotation2,rows=[1:4]) {
  if (is_list(rows[0])) {
        for (i=rows) {
      hull(){
	key_adjacent_bounding_box(i[0], pos1,rotation1);
	key_adjacent_bounding_box(i[1], pos2,rotation2,left=true);
      }
    }
  } else {
    for (i=rows) {
      hull(){
	key_adjacent_bounding_box(i, pos1,rotation1);
	key_adjacent_bounding_box(i, pos2,rotation2,left=true);
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
      rows=[1,4];
      connect_column_pairs(index_pos,index_rotation, middle_offset,middle_rotation,rows=rows);
      connect_column_pairs([outerdia+spacer,0,0],middle_rotation,pinkie_pos,pinkie_rotation,rows=rows);
      //*translate(middle_offset+[-(outerdia/2),0,0]) rotate([0,-90,0]) linear_extrude(0.1) projection() rotate([0,90,0]) key_column_tightest(rows=rows, sides=false);

    }

    // middle+ring
    difference() {
      offset_column_pair(rows=rows,keys=keys,sides=sides,spacer=spacer,offset=middle_offset,rotation=middle_rotation);

      // shave off the bottom so we can be closer to the plate
      translate([-20,-10,-12.5]) cube([50,70,3]);
    }
    // pinky
    column_pair(rows=rows,keys=keys,sides=sides,spacer=spacer,pos=pinkie_pos, rotation=pinkie_rotation, rightside=shell);
  }

}

module assembly(keys=false,shell=false) {
  difference() {
    // bottom plate params
    z_offset = -10;
    thickness = 4.5;

    if (shell) {
      finger_plates(keys=keys,spacer=spacer,shell=shell);
    } else {
      magnetize([30,-14,2+z_offset-thickness],cut_height=6)
	bounded_hull_stipulated(/*sets=[[1,2,3],[0,1,3,4,5]]*/){
	#translate([-40,-30,z_offset-thickness]) cube([20,20,thickness]);
	#translate([0,-15,z_offset-thickness]) cube([10,10,thickness]);
	#translate([35,-55,z_offset-thickness]) cube([20,20,thickness]);
	#translate([40,5,z_offset-thickness]) cube([20,20,thickness]);
	#translate([0,40,z_offset-thickness]) cube([20,25,thickness]);
	#translate([-45,15,z_offset-thickness]) cube([20,20,thickness]);

	//index plate mounting
	//screw_mounting([-33,29.5,-11.5],[10,0,0],height=12, headroom=0, headroom2=6, headroom2_thickness=2)
	//screw_mounting([-29,-18.6,-11.5],[-10,0,0],height=15, headroom=0, headroom2=5, headroom2_thickness=2)

	//middle plate mounting
	//heatset_mounting([5,-9,-4.5],[-5,0,0],height=6)
	//heatset_mounting([7.7,41.5,-5],[45,0,0],height=6, headroom=14, headroom_thickness=3)

	// pinky plate mounting
	//screw_mounting([53,15,-11.5],[10,0,0],height=15, headroom=0, headroom2=5, headroom2_thickness=2)
	screw_mounting([45.6,-36-7.0,-11],[-30,0,0],height=20, spacer=3, spacer2=2, headroom=0, headroom2=8, headroom2_thickness=3) {
	  finger_plates(keys=keys,spacer=spacer,shell=shell);


	  //bottom plate
	  //translate([0,0,z_offset-thickness]) magnetize([30,-15,2]) linear_extrude(height=thickness) hull() projection() heatset_mounting([7.7,41.5,-5],[45,0,0],height=6, headroom=13, headroom_thickness=3) screw_mounting([45.6,-36-7.0,-11],[-30,0,0],height=20, spacer=3, spacer2=2, headroom=0, headroom2=7, headroom2_thickness=3) finger_plates();
	}
      }
    }
    //  prune any part of the mounting model that sticks through bottom plate
    translate([0,0,z_offset-thickness-10]) cube([200,200,20], center=true);
  }
}

assembly(shell=true);

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
