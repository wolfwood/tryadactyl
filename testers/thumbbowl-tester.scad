include <../settings.scad>;
use <../keywell.scad>;
use <../keycap.scad>;
use <../column-util.scad>;
use <../column-layout.scad>;
use <../trackpoint.scad>;

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

thumbbowl_tester(keys=true);
