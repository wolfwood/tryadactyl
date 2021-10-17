/* a flat column. not really a dactyl but someone may like it.
 *  also a good starting place for understanding other columns,
 *  and useful for validating profiles' position_flat() funcitions with the flat_tester()
 */


include <settings.scad>;
use <keywell.scad>;
use <keycap.scad>;
use <column-util.scad>;
use <column-layout.scad>;
use <trackpoint.scad>;

module thumbbowl_tester(rows=2, cols=3, keys=false) {
  row_chord_sides = normalize_chord([19,28,0]);
  row_chord_center = normalize_chord([14.5,row_chord_sides[1],0]);
  rc=[[normalize_chord(row_chord_sides),normalize_chord(row_chord_sides),normalize_chord(row_chord_sides)],
      [row_chord_center,row_chord_center,row_chord_center],
      [normalize_chord(row_chord_sides),normalize_chord(row_chord_sides),normalize_chord(row_chord_sides)]];
  cc = normalize_chord([12,14,0]);
  echo(normalize_chord(cc), normalize_chord(rc));
  row_spacing = create_circular_placement(rc);
  col_spacing = create_circular_placement(cc,z_correct=31.5);
  homerow=0;
  homecol=1;
  profile_rows=[[3,2],[3,"SKRH"],[3,2]];

  tilt=[row_chord_center[2],-45,0];
  offsets=[0,0,0];

  placement_params = layout_placement_params(row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, homecol=homecol, profile_rows=profile_rows, offsets=offsets, tilt=tilt);

  if ($preview) {
    *#rotate(tilt) translate([0,0,optional_vector_index(row_spacing[2],homerow,homecol)[1]])
    scale([cc[1]/row_chord_sides[1],1,1])
    sphere($fn=120,r=optional_vector_index(row_spacing[2],homerow,homecol)[1]);
    layout_columns(rows=rows, cols=cols, keys=true, wells=false, params=placement_params);
    rotate([0,tilt.y,0]) color("darksalmon", .2) translate([0,-2,3.7]) scale([1,1,15/21]) rotate([90,0,0]) cylinder(d=21,h=30);
  }

  difference(){
    //install_trackpoint(1, 0, row_spacing, col_spacing, profile_rows, homerow, h1=6, h2=6, stem=-.5, up=.5, tilt=[-7,0,0], square_hole=false)
    union() {
      layout_columns(rows=rows, cols=cols, keys=false,
		     leftwall=true, rightwall=false, topwall=false, bottomwall=true, narrowsides=false, perimeter=true,
		     params=placement_params);

      layout_walls_only(rows=rows, cols=1, keys=false,
			leftwall=true, rightwall=false, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
			row_spacing=create_circular_placement(row_chord_center), homecol=0, profile_rows=profile_rows[homecol],
			params=placement_params);
      layout_walls_only(rows=1, cols=1, keys=false,
			leftwall=true, rightwall=false, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
			homecol=1, profile_rows=profile_rows[0],
			params=placement_params);
    }
    translate([0,0,-28-40]) cube([500,500,80],true);

    version=2;
    *translate([outerdia/2 + spacer()/2 + directional_decoder(wall_extra_room,0,1) + optional_vector_index(wall_width,0,0) -.4, -30, -21])
      rotate([90,0,90]) linear_extrude(.5) text(str(profile, " Thimble v",version), size=6);
  }
}

*thumbbowl_tester(keys=true);



module offset_tester(rows=4, cols=2, keys=false) {
  row_spacing = create_circular_placement([14.5,25,0]);
  col_spacing = create_flat_placement(outerdia+spacer());
  homerow=2;
  homecol=1;
  profile_rows=effective_rows(rows,homerow);

  tilt=[-5,0,0];
  offsets=[[0,0,0],[0,4,1]];

  placement_params = layout_placement_params(row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, homecol=homecol, profile_rows=profile_rows, offsets=offsets, tilt=tilt);

  if ($preview) {
    *#rotate(tilt) translate([0,0,optional_vector_index(row_spacing[2],0,0)[1]])
    scale([col_spacing[2][1]/row_spacing[2][1],1,1])
    sphere($fn=120,r=optional_vector_index(row_spacing[2],0,0)[1]);
    layout_columns(rows=rows, cols=cols, homerow=homerow, homecol=homecol, keys=keys, wells=false,
		   params=placement_params);
  }

  difference(){
    //install_trackpoint(1, 0, row_spacing, col_spacing, profile_rows, homerow, h1=6, h2=6, stem=-.5, up=.5, tilt=[-7,0,0], square_hole=false)
      layout_columns(rows=rows, cols=cols, keys=false,
		     leftwall=true, rightwall=true, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
		     params=placement_params);

    translate([0,0,-24-40]) cube([500,500,80],true);

    version=2;
    translate([3*outerdia/2 + 3*spacer()/2 + directional_decoder(wall_extra_room,0,1) + optional_vector_index(wall_width,0,0) -.4, -30, -21])
      rotate([90,0,90]) linear_extrude(.5) text(str(profile, " Offset v",version), size=6);
  }
}

*offset_tester(keys=true);

module spherical_tester(rows=4, cols=2, keys=false) {
  row_spacing = create_circular_placement([19,35,0]);
  col_spacing = create_circular_placement([15.5,35,0]);
  homerow=2;
  profile_rows=effective_rows(rows,homerow);

  tilt=[0,0,0];

  placement_params = layout_placement_params(row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, profile_rows=profile_rows, tilt=tilt);

  if ($preview) {
    *#rotate(tilt) translate([0,0,optional_vector_index(row_spacing[2],0,0)[1]])
    scale([col_spacing[2][1]/row_spacing[2][1],1,1])
    sphere($fn=120,r=optional_vector_index(row_spacing[2],0,0)[1]);
    layout_columns(rows=rows, cols=cols, keys=keys, wells=false, params=placement_params);
  }

  difference(){
    install_trackpoint(1, 0, params=placement_params, h1=6, h2=6, stem=1, up=-1, square_hole=true)
      layout_columns(rows=rows, cols=cols, keys=false,
		     leftwall=true, rightwall=true, topwall=true, bottomwall=true, narrowsides=false, perimeter=true,
		     params=placement_params);

    translate([0,0,-24-40]) cube([500,500,80],true);

    version=2;
    translate([outerdia/2 + spacer()/2 + directional_decoder(wall_extra_room,0,1) + optional_vector_index(wall_width,0,0) -.4, -30, -21])
      rotate([90,0,90]) linear_extrude(.5) text(str(profile, " Sphere v",version), size=6);
  }
}

*spherical_tester(keys=true);

module cylindrical_tester(rows=4, keys=false) {
  row_spacing = create_circular_placement([15,25,0]);
  col_spacing=create_flat_placement(outerdia+spacer());
  homerow=2;
  profile_rows=effective_rows(rows,homerow);

  tilt=[0,0,0];

  placement_params = layout_placement_params(row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, profile_rows=profile_rows, tilt=tilt);

  if ($preview) {
    #rotate(tilt) translate([0,0,optional_vector_index(row_spacing[2],0,0)[1]]) rotate([0,90,0])
    cylinder($fn=120,r=optional_vector_index(row_spacing[2],0,0)[1],h=15,center=true);
    layout_columns(rows=rows, cols=2, keys=keys, wells=false, params=placement_params);
  }

  difference(){
    install_trackpoint(1,0, params=placement_params, h1=4, h2=3.5, stem=.5, up=-.5)
    layout_columns(rows, cols=2, keys=false,
		   leftwall=true, rightwall=true, /*topwall=true, bottomwall=true,*/ narrowsides=false, perimeter=true,
		   params=placement_params);

    translate([0,0,-24-40]) cube([500,500,80],true);

    version=2;
    translate([outerdia/2 + spacer()/2 + directional_decoder(wall_extra_room,0,1) + optional_vector_index(wall_width,0,0) -.4, -30, -21])
      rotate([90,0,90]) linear_extrude(.5) text(str(profile, " Cylinder v",version), size=6);
  }
}

*cylindrical_tester(keys=true);

module flat_tester(rows=4, cols=6,keys=false) {
  row_spacing = create_flat_placement([outerdia+spacer()+.6, outerdia+spacer()+.6, outerdia+spacer()+1.2, outerdia+spacer()+1.2]);
  col_spacing=create_flat_placement(outerdia+spacer());
  homerow=1;
  homecol=cols-2;
  profile_rows=effective_rows(rows,homerow);

  tilt=[5,5,0];

  placement_params = layout_placement_params(row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, homecol=homecol, profile_rows=profile_rows, tilt=tilt);

  layout_columns(rows, cols=cols, keys=keys, wells=false,
		 params=placement_params);

  difference(){
    install_trackpoint(homerow-1,homecol, params=placement_params, h1=8, h2=8, stem=4)
      layout_columns(rows, cols=cols, keys=false, wells=true,
		     leftwall=true, rightwall=true, topwall=true, bottomwall=true, narrowsides=false, perimeter=true,
		     params=placement_params);

    translate([0,0,-34-40]) cube([500,500,80],true);

    version=2;
    translate([outerdia/2 + spacer()/2 + directional_decoder(wall_extra_room,0,1) + optional_vector_index(wall_width,0,0) -.4, -25, -22])
      rotate([90,0,90]) linear_extrude(.5) text(str(profile, " Flat v",version), size=6);
  }
}

flat_tester(keys=true);


module tubular_tester(rows=4, cols=2, keys=false) {
  row_spacing=create_flat_placement(outerdia+spacer()+1.2);
  col_spacing = create_circular_placement([14.5,25,0]);
  homerow=2;
  profile_rows=effective_rows(rows,homerow);

  tilt=[0,0,0];

  placement_params = layout_placement_params(row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, profile_rows=profile_rows, tilt=tilt);

  if ($preview) {
    #rotate(tilt) translate([0,0,optional_vector_index(col_spacing[2],0,0)[1]]) rotate([90,0,0])
    cylinder($fn=120,r=optional_vector_index(col_spacing[2],0,0)[1],h=15,center=true);

    layout_columns(rows, cols=cols, keys=keys, wells=false,
		   params=placement_params);
  }

  difference(){
    install_trackpoint(1,0, params=placement_params, h1=8, h2=8, stem=2)
    layout_columns(rows, cols=cols, keys=keys,
		   leftwall=true, rightwall=true, /*topwall=true, bottomwall=true,*/ narrowsides=false, perimeter=true,
		   params=placement_params);

    translate([0,0,-26-40]) cube([500,500,80],true);

    version=2;
    translate([outerdia/2 + spacer()/2 + directional_decoder(wall_extra_room,0,1) + optional_vector_index(wall_width,0,0) -.4, -25, -22])
    rotate([90,0,90]) linear_extrude(.5) text(str(profile, " Tubular v",version), size=6);
  }
}

*tubular_tester(keys=true);
