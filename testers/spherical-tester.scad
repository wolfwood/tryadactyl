include <../settings.scad>;
use <../keycap.scad>;
use <../keywell.scad>;
use <../column-util.scad>;
use <../column-layout.scad>;
use <../trackpoint.scad>;

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

spherical_tester(keys=true);
