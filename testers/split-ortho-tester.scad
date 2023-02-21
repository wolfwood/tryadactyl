use <../settings.scad>;
use <../key/cap.scad>;
use <../key/mount.scad>;
use <../column/util.scad>;
use <../column/layout.scad>;
use <../assembly/trackpoint.scad>;

module flat_tester(rows=4, cols=6,keys=false) {
  row_spacing = create_flat_placement([outerdia()+spacer()+.6, outerdia()+spacer()+.6, outerdia()+spacer()+1.2, outerdia()+spacer()+1.2]);
  col_spacing=create_flat_placement(outerdia()+spacer());
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
    translate([outerdia()/2 + spacer()/2 + directional_decoder(wall_extra_room(),0,1) + optional_vector_index(wall_width(),0,0) -.4, -25, -22])
      rotate([90,0,90]) linear_extrude(.5) text(str(profile(), " Flat v",version), size=6);
  }
}

flat_tester(keys=true);
