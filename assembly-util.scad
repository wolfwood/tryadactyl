include <settings.scad>;
use <column-util.scad>;


module screw_mounting(row,col, row_spacing, col_spacing, profile_rows, homerow, homecol=0,
		      tilt=[0,0,0], offsets=[0,0,0], displacement=[0,0,-15],
		      height=20, strut_dia=6.5, screw_dia=3.2, washer_dia=6.4,
		      headroom=[[2,0,0],[2,0,2]], footroom=[2,0,2], spacer=3
		      ) {

  $fn=60;
  assert(height==6 || height==10 || height==12 || height==15 || height==16 || height==18 || height==20 || height==21 || height==22 || height==24 || height==25 || height==26 || height==27 || height==28 || height>=30);

  difference() {
    union() {
      layout_placement(row, col, row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows, homerow=homerow, homecol=homecol, tilt=tilt, offsets=offsets, displacement=displacement,corners=true, flatten=false) {
	cylinder(h=optional_vector_index(headroom,0).z, d=washer_dia + optional_vector_index(headroom, 0).x);

	translate([0,0,-optional_index(spacer,0)]) {
	  cylinder(h=optional_index(spacer,0), d=max(washer_dia + optional_vector_index(headroom, 0).x,
						     strut_dia + optional_vector_index(footroom, 0).x));

	  translate([0,0,-optional_vector_index(footroom,0).z]){
	    cylinder(h=optional_vector_index(footroom,0).z, d=strut_dia + optional_vector_index(footroom,0).x);
	  }

	  translate([0,0,-height]) {
	    idx=1;
	    spacer_h = optional_index(spacer,idx);
	    cylinder(optional_vector_index(footroom,idx).z,
		     d=strut_dia + optional_vector_index(footroom,idx).x);
	    translate([0,0,-spacer_h]) {
	      cylinder(h=spacer_h, d=max(washer_dia + optional_vector_index(headroom, idx).x,
					 strut_dia + optional_vector_index(footroom, idx).x));
	      headroom_h = optional_vector_index(headroom,idx).z;
	      translate([0,0,-headroom_h]) cylinder(h=headroom_h, d=strut_dia + optional_vector_index(headroom,idx).x);
	    }
	  }
	}
      }
      children();
    }
    layout_placement(row, col, row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows, homerow=homerow, homecol=homecol, tilt=tilt, offsets=offsets, displacement=displacement,corners=true, flatten=false) {

      cylinder(h=height,d=washer_dia);

      let(z=height+optional_index(spacer,0)+optional_index(spacer,1)) {
	translate([0,0,-(z+.1)]) cylinder(h=z+2*.1, d=screw_dia);
	 headroom_h = optional_vector_index(headroom,1).z;
	 translate([0,0,-(z+height-headroom_h)]) cylinder(h=height, d=washer_dia);
      }
      let(z=height) {
	translate([0,0,-(z+optional_index(spacer,0))]) cylinder(h=z, d=strut_dia);
      }
    }
  }
}
