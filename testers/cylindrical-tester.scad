include <../settings.scad>;
use <../keycap.scad>;
use <../keywell.scad>;
use <../column-util.scad>;
use <../column-layout.scad>;
//use <../trackpoint.scad>;


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
    //install_trackpoint(1,0, params=placement_params, h1=4, h2=3.5, stem=.5, up=-.5)
    layout_columns(rows, cols=2, keys=false,
		   leftwall=true, rightwall=true, /*topwall=true, bottomwall=true,*/ narrowsides=true, perimeter=false,
		   params=placement_params);

    translate([0,0,-24-40]) cube([500,500,80],true);

    version=2;
    translate([outerdia/2 + spacer()/2 + directional_decoder(wall_extra_room,0,1) + optional_vector_index(wall_width,0,0) -.4, -30, -21])
      rotate([90,0,90]) linear_extrude(.5) text(str(profile, " Cylinder v",version), size=6);
  }
}

cylindrical_tester(keys=true);
