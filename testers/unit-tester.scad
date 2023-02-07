// a 1u key holder, for testing units

include <../settings.scad>;
use <../keycap.scad>;
use <../keywell.scad>;
use <../column-util.scad>;
use <../column-layout.scad>;

module unit_tester() {
  spacing=create_flat_placement(outerdia+spacer());
  homerow=0;
  profile_rows=2;

  placement_params = layout_placement_params(row_spacing=spacing, col_spacing=spacing, homerow=homerow, profile_rows=profile_rows);

  if ($preview) {
    layout_columns(1, 1, keys=true, wells=false, params=placement_params);
  }
  difference() {
    layout_columns(1, 1, narrowsides=true, leftwall=true, rightwall=true, params=placement_params);
    translate([0,0,-24-40]) cube([500,500,80],true);
  }
}

unit_tester();
