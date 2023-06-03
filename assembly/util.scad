use <../settings.scad>;
use <../column/util.scad>;


//keys for param "dictionary"
height_enum = "a";
strut_dia_enum = "b";
screw_dia_enum = "c";
washer_dia_enum = "d";
headroom_enum = "e";
footroom_enum = "f";
spacer_enum = "g";
stay_upright_enum = "h";
//tent_enum = "i";
displacement_enum = "j";
row_enum = "k";
col_enum = "l";
layout_params_enum = "m";
offsets_enum = "n";


// diy stuct for marshalling all the params together
// cylinders are described with a 2D vector, x as diameter and y as height
function screw_mounting_params(row, col, height=20, strut_dia=6.5, screw_dia=3.2, washer_dia=6.4,
			       headroom=[[0,0],[2,7]], footroom=[2,2], spacer=3, stay_upright=true, displacement=[0,0,-15], offsets=[0,0,0], layout_params=default_layout_placement_params()) =
  [[height_enum, height],
   [strut_dia_enum, strut_dia],
   [screw_dia_enum, screw_dia],
   [washer_dia_enum, washer_dia],
   [headroom_enum, headroom],
   [footroom_enum, footroom],
   [spacer_enum, spacer],
   [stay_upright_enum, stay_upright],
   //[tent_enum, tent],
   [displacement_enum, displacement],
   [offsets_enum, offsets],
   [row_enum, row],
   [col_enum, col],
   [layout_params_enum, layout_params]];

default_screw_mounting_params = screw_mounting_params();

function absolute_screw_mounting_params(placement=[0,0,0],
					height=match(height_enum,default_screw_mounting_params),
					strut_dia=match(strut_dia_enum,default_screw_mounting_params),
					screw_dia=match(screw_dia_enum,default_screw_mounting_params),
					washer_dia=match(washer_dia_enum,default_screw_mounting_params),
					headroom=match(headroom_enum, default_screw_mounting_params),
					footroom=match(footroom_enum, default_screw_mounting_params),
					spacer=match(spacer_enum, default_screw_mounting_params)
					) =
  screw_mounting_params(row=0, col=0,
			height=height,
			strut_dia=strut_dia, screw_dia=screw_dia, washer_dia=washer_dia,
			headroom=headroom, footroom=footroom, spacer=spacer,
			displacement=placement,
			layout_params=layout_placement_params(row_spacing=create_flat_placement(0),
							      col_spacing=create_flat_placement(0), profile_rows=1)
			);


module screw_mounting_blank(params, idx) {
  strut_dia = match(strut_dia_enum, params);
  screw_dia = match(screw_dia_enum, params);
  washer_dia = match(washer_dia_enum, params);
  headroom = optional_vector_index(match(headroom_enum, params), idx);
  footroom = optional_vector_index(match(footroom_enum, params), idx);
  spacer = optional_index(match(spacer_enum, params), idx);

  rotate([idx*180,0,0]) {
    headroom_dia = washer_dia + headroom.x;
    footroom_dia = strut_dia + footroom.x;
    // envelops screwhead and washer
    cylinder(h=headroom.y, d=headroom_dia);
    /* washer sit on this, and it 'spaces' out the cuts for the washer and the strut if we need to
     *  avoid cutting into switch plate too deeply */
    translate([0,0,-spacer]) {
      cylinder(h=spacer, d2=headroom_dia, d1=footroom_dia);
      // envelops strut to provice a bit more stability
      translate([0,0,-footroom.y]) {
	cylinder(h=footroom.y, d=footroom_dia);
      }
    }
  }
}

module mount_bounding_box(z, thickness, mounting_params=default_screw_mounting_params) {
  let(row=match(row_enum, mounting_params),
      col=match(col_enum, mounting_params),
      displacement=match(displacement_enum, mounting_params),
      offsets=match(offsets_enum, mounting_params),
      layout_params=match(layout_params_enum, mounting_params),
      strut_dia = match(strut_dia_enum, mounting_params),
      washer_dia = match(washer_dia_enum, mounting_params),
      headroom_0 = optional_vector_index(match(headroom_enum, mounting_params), 0),
      headroom_1 = optional_vector_index(match(headroom_enum, mounting_params), 1),
      footroom_0 = optional_vector_index(match(footroom_enum, mounting_params), 0),
      footroom_1 = optional_vector_index(match(footroom_enum, mounting_params), 1),
      x = max(strut_dia + max(headroom_0.x, headroom_1.x), washer_dia + max(footroom_0.x, footroom_1.x))
      ){

    translate([0,0,z])
      linear_extrude(thickness)
      projection()
      layout_placement(row, col, params=layout_params, offsets=offsets, displacement=displacement,
		       corners=true, flatten=false, stay_upright=true)
      cube([x,x,1],center=true);
  }
}

module screw_mounting(row,col,height, displacement,
		      row_spacing, col_spacing, profile_rows, homerow, homecol, tilt, offsets,
		      mounting_params=default_screw_mounting_params,
		      layout_params, idx=-1, clearance=true, blank=false) {

  module clearance(washer=[6, .55], screwhead=[5.55, 2.55], indicator=0) {
    color("silver", .3) {
      cylinder(d=washer.x, h=washer.y);
      translate([0,0,washer.y]) cylinder(d=screwhead.x, h=screwhead.y);
      if (indicator != 0) {
	translate([0,0,washer.y+screwhead.y]) difference() {
	  cylinder(d=indicator+4, h=.1);
	  cylinder(d=indicator, h=.1);
	}
      }
    }
  }

  let(row=match_override(row_enum, mounting_params, row),
      col=match_override(col_enum, mounting_params, col),
      height=match_override(height_enum, mounting_params, height),
      displacement=match_override(displacement_enum, mounting_params, displacement),
      offsets=match_override(offsets_enum, mounting_params, offsets),
      layout_params=match_override(layout_params_enum, mounting_params, layout_params),
      strut_dia = match(strut_dia_enum, mounting_params),
      screw_dia = match(screw_dia_enum, mounting_params),
      washer_dia = match(washer_dia_enum, mounting_params),
      spacer_0 = optional_index(match(spacer_enum,mounting_params), 0),
      spacer_1 = optional_index(match(spacer_enum,mounting_params), 1),
      headroom_0 = optional_vector_index(match(headroom_enum,mounting_params), 0),
      headroom_1 = optional_vector_index(match(headroom_enum,mounting_params), 1)
      ){

    assert(height==0 || height==6 || height==10 || height==12 || height==15 || height==16 || height==18 || height==20 ||
	   height==21 || height==22 || height==24 || height==25 || height==26 || height==27 || height==28 || height>=30,
	   "Height must be a combination of 6, 10, 15 and 20 mm struts");

    difference() {
      union() {
	layout_placement(row, col, params=layout_params,row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows, homerow=homerow, homecol=homecol, tilt=tilt, offsets=offsets, displacement=displacement,corners=true, flatten=false, stay_upright=true) {
	  $fn=60;

	  if(idx != 1)
	    screw_mounting_blank(mounting_params,0);

	  if (idx != 0)
	    translate([0,0,-height-spacer_0-spacer_1]) {
	      screw_mounting_blank(mounting_params,1);
	    }
	}

	children();
      }

      if (!blank) {
	layout_placement(row, col, params=layout_params, row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows, homerow=homerow, homecol=homecol, tilt=tilt, offsets=offsets, displacement=displacement,corners=true, flatten=false, stay_upright=true) {
	  $fn=60;
	  cylinder(h=height+7,d=washer_dia);

	  let(z=height+spacer_0+spacer_1) {
	    translate([0,0,-(z+.1)]) cylinder(h=z+2*.1, d=screw_dia);
	    translate([0,0,-(z+height+7)]) cylinder(h=height+7, d=washer_dia);
	  }
	  let(z=height) {
	    translate([0,0,-(z+spacer_0)]) cylinder(h=z, d=strut_dia);
	  }
	}
      }
    }

    if ($preview && clearance && !blank) {
      layout_placement(row, col, params=layout_params, row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows, homerow=homerow, homecol=homecol, tilt=tilt, offsets=offsets, displacement=displacement,corners=true, flatten=false, stay_upright=true) {
	$fn=60;
	if(idx != 1)	  clearance();
	if(idx != 0)
	  translate([0,0,-(height+spacer_0+spacer_1)]) rotate([180,0,0]) clearance(indicator=washer_dia+headroom_1.x);
      }
    }
  }
}
