
use <util.scad>;

thickness=4;
innerdia=13.9;
outerdia=17;
tilt=-10;


module keywell_cavity() {
  union() {
    translate([0,0,thickness/2]) cube([innerdia, innerdia, thickness+.01], true);
    translate([-2.5,innerdia/2,0]) cube([5, 0.6, 2.8]);
    translate([-2.5,-innerdia/2-0.6,0]) cube([5, 0.6, 2.8]);
  }
}


module keywell() {
  difference() {
    translate([0,0,thickness/2]) cube([outerdia, outerdia, thickness], true);
    keywell_cavity();
  }
}

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

module key_column() {
  cherry_row(3) key();
  translate([0,18.5,-2]) rotate([3,0,0]) cherry_row(2) key();
  translate([0,2*18.5,-3]) rotate([7,0,0]) cherry_row(1) key();
}

module key_assembly(row=3,keys=false,well=true, sides=false,header=true,footer=true) {
  mxstem = 6.1;
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

module key_column_tightest(rows=4,keys=false,well=true, sides=true) {
  rotate([tilt,0,0]) union() {
    if (rows == 5) {
      translate([0,-2*18.5+8.2,24]) rotate([-60,0,0]) key_assembly(5,keys,well,sides,footer=false);
    }
    translate([0,-18.5-.1,7.2]) rotate([-32,0,0]) key_assembly(4,keys,well,sides,footer=(rows > 4) );

    key_assembly(3,keys,well,sides);
    translate([0,18.5+1.3,1.9]) rotate([28,0,0]) key_assembly(2,keys,well,sides);
    translate([0,2*18.5-.1,12.3]) rotate([55,0,0]) key_assembly(1,keys,well,sides,header=false);
  }
}

module column_pair(rows=4,keys=false,sides=false, spacer=1.4, pos=[0,0,0], rotation=[0,0,0], center="auto") {
  assert(center == "right" || center == "left" || center == "auto");
  right_align = center == "right" || (center == "auto" && rotation.z >= 0);
  overlap=0.1;

  translate([pos.x,pos.y, 0]) rotate(rotation) trimmer() translate([0,0,pos.z]) translate(right_align ? [0,0,0] : [(outerdia+spacer),0,0]) union() {
    translate([-(outerdia+spacer),0,0]) mirror([1,0,0]) key_column_tightest(rows=rows,keys=keys,sides=sides);
    key_column_tightest(rows=rows,keys=keys,sides=sides);
    translate([-(outerdia/2) + overlap,0,0]) rotate([0,-90,0]) linear_extrude(spacer+2*overlap) projection() rotate([0,90,0]) key_column_tightest(rows=rows, sides=false);
  }
}

module finger_plates(rows=4,keys=false,sides=false,spacer=1.4) {
  union() {
    num=4;
    spacing = outerdia+spacer;

    // index
    column_pair(rows=rows,keys=keys,sides=sides,spacer=spacer,pos=[-(outerdia+4),-4,6], rotation=[0,0,5]);

    middle = [0,4,3];
    // middle+ring
    union() {
      //middle
      translate([0,middle.y,0]) trimmer () {
	mirror([1,0,0]) translate([0,0,middle.z]) key_column_tightest(rows=num,keys=keys,sides=sides);

	// side wall to connect to ring
	difference() {
	  translate([0,0,middle.z]) key_column_tightest(rows=num,keys=keys);
	  translate([outerdia/2+.1,-middle.y,0]) difference() {
	    rotate([0,-90,0]) linear_extrude(outerdia-innerdia+.2) projection() rotate([0,90,0]) key_column_tightest(rows=num, sides=true);
	    rotate([0,-90,0]) linear_extrude(outerdia-innerdia+.2) projection() rotate([0,90,0]) key_column_tightest(rows=num, sides=false);
	  }
	  *translate([outerdia/2+.1,-middle.y,0]) rotate([0,-90,0]) linear_extrude(outerdia-innerdia+.2) projection() rotate([0,90,0]) difference() {
	    key_column_tightest(rows=num, sides=true);
	    key_column_tightest(rows=num, sides=false);
	  }
	}
      }
      // ring
      trimmer() translate([18.4,0,0]) {
	key_column_tightest(rows=num,keys=keys,sides=sides);
	//mirror([1,0,0]) key_column_tightest(rows=num,keys=keys);
      }

      // spacer
      difference () {
	// spacer should be the intersection of ring and middle on top (low as the lowest of either)
	// but as long as ring on bottom. so we intersect with sides walls to get the top
	trimmer() translate([outerdia/2+1.5,0,0]) intersection() {
	  rotate([0,-90,0]) linear_extrude(1.6) projection() rotate([0,90,0]) key_column_tightest(rows=num, sides=true);
	  translate([0,middle.y, middle.z]) rotate([0,-90,0]) linear_extrude(1.6) projection() rotate([0,90,0]) key_column_tightest(rows=num, sides=true);
	}

	// then remove the part of the wall below ring from the bottom
	translate([outerdia/2+1.6,0,0]) difference() {
	  rotate([0,-90,0]) linear_extrude(1.8) projection() rotate([0,90,0]) key_column_tightest(rows=num, sides=true);
	  rotate([0,-90,0]) linear_extrude(1.8) projection() rotate([0,90,0]) key_column_tightest(rows=num, sides=false);
	}
      }
    }

    // pinky
    column_pair(rows=rows,keys=keys,sides=sides,spacer=spacer,pos=[outerdia+spacer+20,-18,10], rotation=[0,0,-10]);
  }

}

module assembly() {
  difference() {
    // bottom plate params
    z_offset = -12.5;
    thickness = 4;

    //index plate mounting
    ff_mounting([-33,29.5,-11.5],[10,0,0],height=12, headroom=0, headroom2=5, headroom2_thickness=2)
      ff_mounting([-29,-18.6,-11.5],[-10,0,0],height=15, headroom=0, headroom2=5, headroom2_thickness=2)

      //middle plate mounting
      fm_mounting([5,-9,-4.5],[-5,0,0],height=6)
      fm_mounting([7.7,41.5,-5],[45,0,0],height=6, headroom=13, headroom_thickness=3)

      // pinky plate mounting
      ff_mounting([53,15,-11.5],[10,0,0],height=15, headroom=0, headroom2=5, headroom2_thickness=2)
      ff_mounting([45.6,-36-7.0,-11],[-30,0,0],height=20, spacer=3, spacer2=2, headroom=0, headroom2=7, headroom2_thickness=3)
      {
	finger_plates();

	//bottom plate
	%translate([0,0,z_offset-thickness]) magnetize([30,-15,2]) linear_extrude(height=thickness) hull() projection() fm_mounting([7.7,41.5,-5],[45,0,0],height=6, headroom=13, headroom_thickness=3) ff_mounting([45.6,-36-7.0,-11],[-30,0,0],height=20, spacer=3, spacer2=2, headroom=0, headroom2=7, headroom2_thickness=3) finger_plates();
      }
    //  prune any part of the mounting model that sticks through bottom plate
    translate([0,0,z_offset-thickness-10]) cube([200,200,20], center=true);
  }
}

assembly();

function substitute(a2, a) = a2 < 0 ? a : a2;

module ff_mounting(pos=[0,0,0], rotation=[0,0,0], height=20, strut_dia=6.5, screw_dia=3.2, washer_dia=6.4,headroom=2,spacer=2,footroom=2, headroom_thickness=0,footroom_thickness=2, headroom2=-1,headroom2_thickness=-1, spacer2=-1) {
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

module fm_mounting(pos=[0,0,0], rotation=[0,0,0], height=20, strut_dia=6.5, screw_dia=3.2, washer_dia=6.4,headroom=5,spacer=2,footroom=2, headroom_thickness=2,footroom_thickness=2) {
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
      translate([0,0,-.01]) cylinder(d1=3.9,d2=3.2,h=h);
      translate([0,0,sphere_h]) sphere(d=4.5);
    }
    translate([0,0,sphere_h+3.4]) cube([10,10,4],true);
  }
}
module heatset_block(){
    cylinder(d=7,h=6.3);
}
