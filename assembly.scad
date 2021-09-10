include <settings.scad>;
use <keycap.scad>;
use <column-util.scad>;
use <column-layout.scad>;
use <trackpoint.scad>;
use <assembly-util.scad>;

index_pos = [-(outerdia+4),-4,6];
index_rotation = [0,10,3];
middle_offset = [0,4,1];
middle_rotation = [0,0,0];
pinkie_pos = [outerdia+spacer()+20,-13,8];
pinkie_rotation = [0,0,-5];

module finger_plates(keys=true) {
  rows=4;
  cols=2;
  homerow=2;
  profile_rows=effective_rows(rows,homerow);
  tilt=[-5,0,0];

  row_chord = [14.5,25,0];


  thumb_row_chord_sides = [19,28,0];
  thumb_row_chord_center = [14.5,thumb_row_chord_sides[1],0];
  translate(index_pos + [-2*(outerdia+spacer()),-2.5*(outerdia+spacer()),-5])
    let(rows=2,cols=3,homerow=0,homecol=1,
        row_spacing=create_circular_placement([[thumb_row_chord_sides],
                                               [thumb_row_chord_center],
                                               [thumb_row_chord_sides]]),
        col_spacing = create_circular_placement([12,14,0],z_correct=31.5),
        offsets=[0,0,0],profile_rows=[[3,2],[3,"SKRH"],[3,2]],tilt=[normalize_chord(thumb_row_chord_center)[2]+20,-60,0]) {
    layout_columns(rows=rows, cols=cols, row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, homecol=homecol,
                   //leftwall=false, rightwall=true, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
                   profile_rows=profile_rows, offsets=offsets, tilt=tilt, keys=keys);
  }

  translate(index_pos)
    let(homecol=0,
        row_spacing=create_circular_placement([[row_chord],[row_chord+[4.0,0,0],row_chord+[3.2,0,0],row_chord+[4.5,0,0],row_chord+[8.6,0,0]]]),
        col_spacing=create_circular_placement([[row_chord,row_chord+[-2,0,0]],
                                               [row_chord,row_chord+[.6,0,0]],
                                               [row_chord,row_chord+[0,0,0]],
                                               [row_chord,row_chord+[-.5,0,0]]
                                               ],
                                              z_correct=[3,25,0,0]),
	offsets=[0,0,0], tilt=index_rotation+tilt) {
    screw_mounting(1,0,row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows, homerow=homerow, homecol=homecol,offsets=offsets, tilt=tilt)
      screw_mounting(0,0,row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows, homerow=homerow, homecol=homecol,offsets=offsets, tilt=tilt)
    install_trackpoint(2, 0, row_spacing, col_spacing,
		       profile_rows, homerow, h1=10.9, h2=6, stem=0, up=-0, tilt=tilt, square_hole=true,
		       displacement=[5,8.5,0], w1=12.3)
  layout_columns(rows=rows, cols=cols, row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, homecol=homecol,
		 //leftwall=false, rightwall=true, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
		 profile_rows=profile_rows, offsets=offsets, tilt=tilt, keys=false);
    layout_columns(rows=rows, cols=cols, row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, homecol=homecol,
		 //leftwall=false, rightwall=true, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
		   profile_rows=profile_rows, offsets=offsets, tilt=tilt, keys=keys,wells=false);
  }

  let(homecol=1,
      row_spacing=create_circular_placement(row_chord), col_spacing=create_flat_placement(outerdia+spacer()),
      offsets=[[0,0,0], middle_offset]) {
  layout_columns(rows=rows, cols=cols, row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, homecol=homecol,
		 //leftwall=false, rightwall=true, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
		 profile_rows=profile_rows, offsets=offsets, tilt=middle_rotation+tilt, keys=keys);
  }

  translate(pinkie_pos)
    let(homecol=1,
	row_spacing=create_circular_placement([[[18.5, row_chord[1],0],[17.5, row_chord[1],0],[19, row_chord[1],0],[17.8, row_chord[1],0]],
					       [row_chord]]),
	col_spacing=create_circular_placement([ [[12.7, row_chord[1],0], row_chord],
						[[15.0, row_chord[1],0], row_chord],
						[[14.4, row_chord[1],0], row_chord],
						[[14.6, row_chord[1],0], row_chord] ],
					      z_correct=[2.5,23,0,23]),
	offsets=[0,0,0]) {
    layout_columns(rows=rows, cols=cols, row_spacing=row_spacing, col_spacing=col_spacing, homerow=homerow, homecol=homecol,
		   //leftwall=false, rightwall=true, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
		   profile_rows=profile_rows, offsets=offsets, tilt=pinkie_rotation+tilt, keys=keys);
  }

}

rotate([0,10,0]) finger_plates(keys=false);
