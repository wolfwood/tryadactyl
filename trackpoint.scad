
include <settings.scad>;
use <util.scad>;
use <column-util.scad>;
use <keywell.scad>;
use <keycap.scad>;


module install_trackpoint(row,col, row_spacing, col_spacing, profile_rows, homerow,
			  h1=4,h2=4, stem=0,up=0,tilt, displacement=[0,0,0], params=default_layout_placement_params(), square_hole=false, access=true,w1=0,w2=0, use_shield=false, shield=[4,11,12.3], shield_angle=[-65,-5]) {
  module helper(row, col, corners=false, d=displacement) {
    layout_placement(row,col, row_spacing, col_spacing, profile_rows=profile_rows, homerow=homerow, tilt=tilt,displacement=d,params=params, corners=corners, flatten=!corners) children();
  }

  // visualize trackpoint
  helper(row,col,corners=true) trackpoint_mount($fn=60, h1, h2, stem, up, tilt, stemonly=true);

  // cutting holes in case
  difference() {
    union() {
      children();

      difference() {
	helper(row,col,corners=true) trackpoint_mount($fn=60, h1, h2, stem, up, tilt, w1=w1,w2=w2);

	// remove any material that might interfere with adjacent key switches
	above=true;
	for (i=[0,1]) {
	  for (j=[0,1]) {
	    helper(row+i,col+j,d=[0,0,0]) keywell_cavity(above=above,below=true);
	  }
	}
      }

      if (use_shield) {
	helper(row,col,corners=true) translate([0,0,-shield.z]) if (square_hole) {
	  //cube([7,7,stem_h*2],true);
	} else {
	  difference() {
	    cylinder($fn=120,d=13+shield.x*2,h=shield.y);
	    rotate([0,0,shield_angle[0]]) translate([-50,0,-0.1]) cube([100,100,shield.y*2]);
	    rotate([0,0,shield_angle[1]]) translate([-50,0,-0.1]) cube([100,100,shield.y*2]);
	  }
	}
      }
    }

    // trackpoint stem hole
    stem_h=5+stem+16;
    helper(row,col,corners=true) translate([0,0,-stem_h]) if (square_hole) {
      cube([7,7,stem_h*2],true);
    } else {
      cylinder($fn=60,d=15,h=stem_h*2,center=true);
    }

    if (access) {
      // screw holes for attaching stem extension
      access_dia=4;
      helper(row,col,corners=true) translate([0,0,-(21+stem-access_dia/2)]) rotate([0,90,0]) cylinder($fn=60,d=access_dia,h=100,center=true);
    }
  }
}

module trackpoint_cap() {

}

module trackpoint_mount(h1,h2,stem=0,up=0,tilt=[-5,0,0], bottom=false, stemonly=false, w1=0,w2=0){
  width=23+.4;
  depth=9.5;
  flange_z=3;


  cap_len = 5;

  tp_depth = 16+stem+ cap_len;
  stem_depth = 0;
  stem_len = 16+stem+up+stem_depth;

  translate([0,0,-tp_depth]) {
    if (stemonly) {
      echo(str("you need a ",stem_len," mm stem"));

      color("red",.2) if ($preview) {
	union(){
	  cylinder(d=11,h=4.5);
	  translate([0,0,stem_depth]) cylinder(d=4,h=stem_len);
	  translate([0,0,stem_depth+stem_len]) cylinder(d=6.4,h=cap_len-1);
	  translate([0,0,stem_depth+(cap_len-1)+stem_len]) cylinder(d=8,h=1);
	}
      }
    } else {
      difference(){
	union() {
	  // mount flanges
	  let(x=3.8,y=depth,z=flange_z) {
	    translate([-width/2-w2,-y/2,-z]) cube([x+w2,y,z]);
	    mirror([1,0,0]) translate([-width/2-w1,-y/2,-z]) cube([x+w1,y,z]);
	    if (bottom){
	      translate([0,0,-5*z/4])cube([width+4,y,z],center=true);
	    }
	  }

	  // verticals
	  let(x=flange_z,y=depth,z=flange_z) {
	    translate([width/2+w1,-y/2,-z]) cube([x,y,h1+z]);
	    mirror([1,0,0]) translate([width/2+w2,-y/2,-z]) cube([x,y,h2+z]);
	  }
	}

	//screw holes
	let(h=flange_z*5,d=2.5,slop=.3) {
	  rotational_clone() translate([19/2,0,-h/2])cylinder(h=h,d=d+slop);
	}
      }
    }
  }
}

place_col(2,1,col_spacing,corners=true) place_row(1,1,row_spacing) trackpoint_mount($fn=60,3,3,bottom=true);
col_spacing=create_flat_placement(outerdia+spacer());
row_spacing=create_flat_placement(outerdia+spacer());
