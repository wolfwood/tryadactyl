use <../settings.scad>;
use <../key/cap.scad>;
use <../key/mount.scad>;
use <../column/util.scad>;
use <../column/layout.scad>;

module flat_cherry_tester(rows=4, cols=1,keys=false) {
  row_spacing = create_flat_placement([outerdia()+spacer()+.6, outerdia()+spacer()+.6, outerdia()+spacer()+1.2, outerdia()+spacer()+1.2]);
  col_spacing=create_flat_placement(outerdia()+spacer());
  homerow=2;
  homecol=0;
  profile_rows=effective_rows(rows,homerow);

  tilt=[0,0,0];

  placement_params = layout_placement_params(row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, homecol=homecol, profile_rows=profile_rows, tilt=tilt);

  layout_columns(rows, cols=cols, keys=keys, wells=false,
		 params=placement_params);

  difference(){
      layout_columns(rows, cols=cols, keys=false, wells=true,
		     leftwall=true, rightwall=true, topwall=false, bottomwall=false, narrowsides=true, perimeter=false,
		     params=placement_params);

    translate([0,0,-34-30]) cube([500,500,80],true);

    version=3;
    translate([innerdia()/2 + wall_width() -.4, -25, -22])
      rotate([90,0,90]) linear_extrude(.5) text(str(profile(), " Flat v",version), size=6);
  }
}

flat_cherry_tester(keys=true);
