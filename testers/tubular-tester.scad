use <../settings.scad>;
use <../key/cap.scad>;
use <../key/mount.scad>;
use <../column/util.scad>;
use <../column/layout.scad>;
//use <../assembly/trackpoint.scad>;

module tubular_tester(rows=4, cols=2, keys=false) {
  row_spacing=create_flat_placement(outerdia()+spacer()+1.2);
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
    //install_trackpoint(1,0, params=placement_params, h1=8, h2=8, stem=2)
    layout_columns(rows, cols=cols, keys=keys,
		   leftwall=true, rightwall=true, /*topwall=true, bottomwall=true,*/ narrowsides=false, perimeter=true,
		   params=placement_params);

    translate([0,0,-26-40]) cube([500,500,80],true);

    version=2;
    translate([outerdia()/2 + spacer()/2 + directional_decoder(wall_extra_room(),0,1) + optional_vector_index(wall_width(),0,0) -.4, -25, -22])
      rotate([90,0,90]) linear_extrude(.5) text(str(profile(), " Tubular v",version), size=6);
  }
}

tubular_tester(keys=true);
