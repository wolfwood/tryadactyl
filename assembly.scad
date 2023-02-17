include <settings.scad>;
use <key/cap.scad>;
use <column/util.scad>;
use <column/layout.scad>;
use <assembly/trackpoint.scad>;
use <assembly/util.scad>;


rows=4;
cols=2;

homerow=2;
profile_rows=effective_rows(rows,homerow);
tilt=[-3,0,0];
tent=[0,32,0];
row_chord = [14.5,25,0];

// Akko cherry PBT neesds a bit more space
tight_cylindrical_row =[row_chord+[.5/2,0,0],
			 row_chord+[.5,0,0],
			 row_chord,
			 row_chord+[.5,0,0]];


tight_spherical_row = [row_chord+[5.2,0,0],
		       row_chord+[4.75,0,0],
		       row_chord+[4.5,0,0],
		       row_chord+[8.6,0,0]];
tight_spherical_col = [[row_chord+[-1.8,0,0]],
		       [row_chord+[.9,0,0]],
		       [row_chord+[0,0,0]],
		       [row_chord+[-.5,0,0]]];
spherical_z = [4,30,0,0];

index_keys= true;
index_pos = [-(outerdia+4),-4,6];
index_tent = [0,0,5];
index_tilt = [0,0,0];
index_rows= [rows, rows-1, 1];
index_cols=cols;
index_placement_params =
  layout_placement_params(homerow=[homerow,homerow,0], homecol=0,
			  row_spacing=create_circular_placement([tight_cylindrical_row, tight_spherical_row, [row_chord]]),
			  col_spacing=create_circular_placement(tight_spherical_col, z_correct=spherical_z),
			  profile_rows=[profile_rows,profile_rows,[4]],
			  tent=index_tent+tent, tilt=index_tilt, position=index_pos);

index_mountings = [screw_mounting_params(row=0, col=0, height=60, layout_params=index_placement_params,
					 displacement=[5,-1,-23], offsets=[0,0,-1],
					 headroom=[[10,0], [2,10]], footroom=[[12, 2], [2, 2]]),
		   //screw_mounting_params(row=1, col=0, height=50, layout_params=index_placement_params)
		   screw_mounting_params(row=1, col=0, height=40, displacement=[-11, -1.8, -17],
					 headroom=[[1,2.6], [2,10]], layout_params=index_placement_params)
		   /*screw_mounting_params(row=3, col=0, height=50, layout_params=index_placement_params,
					 headroom=[[1,0],[2,7]],
					 displacement=[2,5,-20])*/
		   ];


middle_keys = true;
//middle_offset = [[0,0,0], [0,4,1]];
middle_offset = [0,5,0];
ring_offset=[1,-5,-1];
middle_rotation = [0,0,0];
middle_placement_params =
  layout_placement_params(homerow=homerow, homecol=1,
			  row_spacing=create_circular_placement(tight_cylindrical_row),
			  col_spacing=create_flat_placement(outerdia+spacer()),
			  profile_rows=profile_rows,
			  offsets=[ring_offset, middle_offset], tent=tent, tilt=middle_rotation+tilt);
middle_mountings = [screw_mounting_params(row=0, col=0, height=30, headroom=[[1,3],[2,7]], footroom=[[2,0],[2,2]],
					  layout_params=middle_placement_params,
					  /*displacement=[1.3,.4,-15],*/displacement=[0,1.6,-15-3], offsets=[0,0, -4]),
		    screw_mounting_params(row=1, col=1, height=20, layout_params=middle_placement_params,
					  displacement=[15.5,-2,-15.5], headroom=[[2,2],[2,7]],
					  offsets=middle_offset+[0,0,-1]),
		    screw_mounting_params(row=3, col=0, height=35, headroom=[[2,2],[2,7]],
					  layout_params=middle_placement_params,
					  displacement=[-7.5,-1.5,-17], offsets=[0,0,0])
		    ];


pinkie_keys = true;//[[false],[true],[false],[false]];
pinkie_pos = [outerdia+spacer()+20+2,-23,4];
pinkie_tent = [0,0,-2];
pinkie_tilt = [3,0,0];
pinkie_placement_params =
  layout_placement_params(homerow=homerow, homecol=1,
			  row_spacing=create_circular_placement([tight_spherical_row,
 								 [row_chord]]),
			  col_spacing=create_circular_placement(tight_spherical_col, z_correct=spherical_z),
			  profile_rows=[/*[4],*/profile_rows,profile_rows],
			  offsets=[0,0,0], tent=tent+pinkie_tent, tilt=pinkie_tilt+tilt,
			  position=pinkie_pos);

pinkie_mountings = [screw_mounting_params(row=0, col=0, height=10,
					  displacement=[2,-5.8,-15.3],
					  offsets=[0,0,-2],
					  layout_params=pinkie_placement_params),
		    screw_mounting_params(row=1, col=0, height=10, layout_params=pinkie_placement_params,
					  displacement=[28,14,-15]),
		    screw_mounting_params(row=2, col=0, height=6,
					  displacement=[5,3,-14],
					  layout_params=pinkie_placement_params)
		    ];

thumb_keys= true;
thumb_pos = index_pos + [-1.5*(outerdia+spacer())+30,-3.5*(outerdia+spacer())-1,-30];
thumb_tilt = [10,-100,25];
thumb_tent = tent+[0,0,-5];
thumb_row_chord_sides = [30, 25, 0];
thumb_row_chord_center = [14.5, 0, 60];
thumb_placement_params =
  layout_placement_params(homerow=1//[0,1,0]
			  , homecol=1,
			  row_spacing=create_circular_placement([[thumb_row_chord_sides],
								 [thumb_row_chord_center],
								 [thumb_row_chord_sides]]),
			  col_spacing = create_circular_placement([[[17,16,0]],[[20,20,0]]],z_correct=60),
			  profile_rows=[[2,3],["SKRH",3],[2,1]],
			  tent=thumb_tent, tilt=thumb_tilt,
			  position=thumb_pos);

thumb_mountings = [screw_mounting_params(row=0, col=1, height=6, displacement=[4,6,-13],
					 layout_params=thumb_placement_params),
		   screw_mounting_params(row=0, col=1, height=6, displacement=[2,-13,-16],
					 headroom= [[2,2],[2,10]], footroom=[[2,2],[2,1]],layout_params=thumb_placement_params),
		   screw_mounting_params(row=0, col=0, height=30, offsets=[0,0,0], displacement=[0,-4.8,-16.0],
					 headroom=[[2,3],[2,10]], footroom=[[6,2],[2,2]],
					 layout_params=thumb_placement_params)
		];

/*
  thumb_keys= [false,true,false];
thumb_pos = index_pos + [-1.75*(outerdia+spacer()),-2.5*(outerdia+spacer())+7,-15 -5];
thumb_row_chord_sides = [20.5,500,0];
thumb_row_chord_center = [14.5, 50,0];
thumb_placement_params =
  layout_placement_params(homerow=0, homecol=1,
			  row_spacing = create_flat_placement(19.1),
			  col_spacing = create_circular_placement([[[14,16,0]],[[18,32,0]]],z_correct=0),
			  profile_rows=[[3,2],[3,"SKRH"],[1,2]],
			  tent=tent+[-10,0,0], tilt=[20,-80,0],
			  position=thumb_pos);

thumb_mountings = [screw_mounting_params(row=0, col=1, height=10, displacement=[-0.5,-13,-15],
					 headroom= [[1,0],[2,7]], layout_params=thumb_placement_params),
		   screw_mounting_params(row=0, col=1, height=10, displacement=[1,6,-15],
					 layout_params=thumb_placement_params),
		   screw_mounting_params(row=0, col=0, height=30, offsets=[0,0,0], displacement=[4,0,-21],
					 headroom=[[2,3],[2,7]], footroom=[[7,2],[2,2]],
					 layout_params=thumb_placement_params)
		];
*/

/*thumb_pos = index_pos + [-2*(outerdia+spacer()),-2.5*(outerdia+spacer())+7+1,-15 -5];
thumb_row_chord_sides = [20.5,40,0];
thumb_row_chord_center = [14.5,32,0];
thumb_placement_params =
  layout_placement_params(homerow=0, homecol=1,
			  row_spacing=create_circular_placement([[thumb_row_chord_sides],
								 [thumb_row_chord_center],
								 [thumb_row_chord_sides]]),
			  col_spacing = create_circular_placement([[[12,14,0]],[[14,14,0]]],z_correct=21),
			  profile_rows=[[3,2],[3,"SKRH"],[3,2]],
			  tent=tent+[-10,0,0], tilt=[normalize_chord(thumb_row_chord_center)[2]+10,-60,0],
			  position=thumb_pos);

thumb_mountings = [screw_mounting_params(row=0, col=1, height=10, displacement=[-0.5,-3,-16],
					 layout_params=thumb_placement_params),
		   screw_mounting_params(row=0, col=1, height=10, displacement=[1,15,-15],
					 layout_params=thumb_placement_params),
		   screw_mounting_params(row=0, col=0, height=35, offsets=[0,0,0], displacement=[6.5,0,-20],
a					 headroom=[[2,3],[2,7]],
					 layout_params=thumb_placement_params)
		];
*/
function tail(v) = assert(is_list(v)) len(v) == 2 ? [v[1]] : [ for (i = [1:len(v)-1]) v[i]];

module apply_screw_mountings(params, idx=0) {
  assert(is_list(params));

  screw_mounting(mounting_params=params[0], idx=idx)
    if (len(params) == 1) {
      children();
    } else {
      apply_screw_mountings(tail(params)) children();
    }
}
module mounted_thumb(keys=true) {
  let(rows=2//[1,2,1]
      ,cols=3) {
    apply_screw_mountings(params=thumb_mountings) {
      layout_columns(rows=rows, cols=cols, params=thumb_placement_params,
		     keys=false, perimeter=true, reverse_triangles=false);
      *hull() {
	layout_placement(0,2, params=thumb_placement_params) key_mount_bounding_box(y=1, header=true, leftside=true);
     	layout_placement(0,0, params=thumb_placement_params) key_mount_bounding_box(y=1, header=true, rightside=true);
      }
      hull() {
	layout_placement(0,1, params=thumb_placement_params) key_mount_bounding_box(y=1, header=true);
	layout_placement(0,2, params=thumb_placement_params) key_mount_bounding_box(y=1,x=1, header=true, leftside=true);
      }
      hull() {
	layout_placement(0,1, params=thumb_placement_params) key_mount_bounding_box(y=1,x=1, header=true);
	layout_placement(0,2, params=thumb_placement_params) key_mount_bounding_box(y=1,x=1, header=true, leftside=true);
     	layout_placement(0,0, params=thumb_placement_params) key_mount_bounding_box(y=1,x=-1, header=true, rightside=true);
      }
    }
    layout_columns(rows=rows, cols=cols, params=thumb_placement_params,
		   keys=keys?thumb_keys:false, wells=false);
  }
}

module mounted_index(keys=true) {
  tp_disp = [6.5,11,0];
  tp_corner_disp = [11,2.8,0];
  apply_screw_mountings(params=index_mountings)
    install_trackpoint(2, 0, h1=13, h2=8.8, stem=0, up=-0, square_hole=false, access=true,
		       tilt=tilt, use_shield=true,  shield=[4,12,15], shield_angle=[-69,-5],
		       displacement=tp_disp, w1=14, params=index_placement_params)
    union() {
    layout_columns(rows=index_rows, cols=index_cols, params=index_placement_params,
		   keys=false);
    hull() {
      layout_placement(3, 0, params=index_placement_params) key_mount_side_bounding_box(x=-1, rightside=true,
											footer=true);
      layout_placement(2, 1, params=index_placement_params) key_mount_corner_bounding_box(y=-1, x=1, leftside=true,
											footer=true);
    }
    hull () {
      layout_placement(3, 0, params=index_placement_params, displacement=tp_corner_disp, corners=true)
	key_mount_corner_bounding_box(x=-1, y=1,leftside=true, footer=true);
      layout_placement(2, 1, params=index_placement_params) key_mount_side_bounding_box(y=-1, leftside=true,
										      footer=true);
    }
    hull () {
      layout_placement(3, 0, params=index_placement_params, displacement=tp_corner_disp, corners=true)
	key_mount_corner_bounding_box(x=-1, y=1,leftside=true, footer=true);
      layout_placement(3, 0, params=index_placement_params) key_mount_corner_bounding_box(x=-1, y=-1, rightside=true,
										      footer=true);
      layout_placement(2, 1, params=index_placement_params) key_mount_bounding_box(y=-1, x=1, leftside=true,
											footer=true);
    }

    *hull() {
      layout_placement(2, 1, params=index_placement_params) key_mount_corner_bounding_box(y=-1, x=1,
											footer=true);
      /*layout_placement(3, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(y=1, x=-1,
	rightside=true,
	footer=true);*/
      layout_placement(2, 0, params=index_placement_params) key_mount_corner_bounding_box(x=-1, y=-1);
      layout_placement(3, 0, params=index_placement_params) key_mount_corner_bounding_box(x=-1, y=1,
											footer=true);
    }

    layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params) key_mount(header=true, footer=true, leftside=true);

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	key_mount_bounding_box(x=1,header=true, footer=true, leftside=true);
      layout_placement(2, 1, params=index_placement_params) key_mount_bounding_box(x=-1, leftside=true,
											footer=true);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	key_mount_bounding_box(x=1,y=-1, header=true, footer=true, leftside=true);
      layout_placement(2, 1, params=index_placement_params) key_mount_bounding_box(x=-1,y=-1, leftside=true,
										 footer=true);
      layout_placement(3, 0, params=index_placement_params, displacement=tp_corner_disp, corners=true)
	key_mount_corner_bounding_box(x=-1, y=1,leftside=true, footer=true);
    }
    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	key_mount_bounding_box(y=-1, header=true, footer=true, leftside=true);
           layout_placement(3, 0, params=index_placement_params, displacement=tp_corner_disp, corners=true)
	key_mount_corner_bounding_box(x=-1, y=1,leftside=true, footer=true);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	key_mount_bounding_box(x=1,y=1, header=true, footer=true, leftside=true);
      layout_placement(2, 1, params=index_placement_params) key_mount_bounding_box(x=-1,y=1, leftside=true,
										 footer=true);
      layout_placement(1, 1, params=index_placement_params) key_mount_bounding_box(x=-1,y=-1, leftside=true,
										 footer=false);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	key_mount_bounding_box(y=1, header=true, footer=true, leftside=true);
      layout_placement(1, 1, params=index_placement_params) key_mount_bounding_box(x=-1,y=-1, leftside=true);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	key_mount_bounding_box(x=-1,y=1, header=true, footer=true, leftside=true);
      layout_placement(0, 1, params=index_placement_params) key_mount_bounding_box(x=-1, leftside=true,header=true);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	key_mount_bounding_box(x=-1,y=1, header=true, footer=true, leftside=true);
      layout_placement(0, 1, params=index_placement_params) key_mount_bounding_box(x=-1, y=-1, leftside=true,header=true);
      layout_placement(1, 1, params=index_placement_params) key_mount_bounding_box(x=-1, y=-1, leftside=true);
    }

    hull() {
      layout_placement(0, 1, params=index_placement_params) key_mount_bounding_box(x=-1, y=-1, leftside=true,header=true);
      layout_placement(1, 1, params=index_placement_params) key_mount_bounding_box(x=-1, leftside=true);

    }

    hull() {
      layout_placement(0, 1, params=index_placement_params) key_mount_bounding_box(x=1, y=1, leftside=true,header=true);
      layout_placement(0, 0, params=index_placement_params) key_mount_bounding_box(y=1, header=true);

    }

  }

  if (keys) {
    layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params) keycap($effective_row);
    layout_columns(rows=index_rows, cols=cols, params=index_placement_params,
		   keys=index_keys, wells=false);
  }
}

//!mounted_index();

module mounted_middle(keys=true) {
  apply_screw_mountings(params=middle_mountings) {
    layout_columns(rows=rows, cols=cols, params=middle_placement_params,
		   rightsides=[true,false],
		   //rightwall=true, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
		   keys=false);
    hull() {
      layout_placement(3, 0, params=middle_placement_params) key_mount_corner_bounding_box(x=-1, y=-1,
											 footer=true);
      layout_placement(3, 1, params=middle_placement_params) key_mount_side_bounding_box(y=-1, leftside=true,
										       footer=true);
    }
    hull() {
      layout_placement(3, 0, params=middle_placement_params) key_mount_bounding_box(x=-1, y=-1,
											 footer=true);
      layout_placement(3, 1, params=middle_placement_params) key_mount_bounding_box(x=-1, y=-1, leftside=true,
										       footer=true);
            layout_placement(3, 0, params=index_placement_params) key_mount_bounding_box(x=1, y=-1,
											footer=true
										       /*rightside=true*/);
    }
  }
  layout_columns(rows=rows, cols=cols, params=middle_placement_params,
		 keys=keys?middle_keys:false, wells=false);

}

module mounted_pinkie(keys=true) {
  apply_screw_mountings(params=pinkie_mountings)
    union() {
    layout_columns(rows=[rows-1,rows], cols=cols, params=pinkie_placement_params,
		   keys=false);
    hull() {
      layout_placement(2, 0, params=pinkie_placement_params) key_mount_side_bounding_box(y=-1, rightside=true,
										       footer=true);
      layout_placement(3, 1, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, leftside=true,
											 footer=true);
    }
    hull() {
      layout_placement(2, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=-1,y=-1, rightside=true,
											 footer=true);
      layout_placement(3, 1, params=pinkie_placement_params) key_mount_side_bounding_box(x=1, leftside=true,
										       footer=true);
    }
    hull() {
      layout_placement(2, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(y=-1, x=-1,
											 rightside=true,
											 footer=true);
      /*layout_placement(3, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(y=1, x=-1,
	rightside=true,
	footer=true);*/
      layout_placement(2, 1, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, leftside=true
											 );
      layout_placement(3, 1, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=1, leftside=true,
											 footer=true);
    }

    layout_placement(row=2, col=0, homerow=2, homecol=2, profile_rows=4, offsets=[0,-.1,0],params=pinkie_placement_params) key_mount(header=true, footer=true, rightside=true);

    hull() {
      layout_placement(3, 1, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, leftside=true,
											 footer=true);
      layout_placement(2, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1,y=-1, rightside=true,
											 footer=true);
      layout_placement(row=2, col=0, homerow=2, homecol=2, profile_rows=4, offsets=[0,-.1,0], params=pinkie_placement_params)
	key_mount_corner_bounding_box(x=-1,y=-1, rightside=true, header=true, footer=true);
    }
    hull() {
      layout_placement(3, 1, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, leftside=true,
											 footer=true);
      layout_placement(row=2, col=0, homerow=2, homecol=2, profile_rows=4, offsets=[0,-.1,0], params=pinkie_placement_params)
	key_mount_side_bounding_box(y=-1, rightside=true, header=true, footer=true);
    }
    hull() {
      layout_placement(row=2, col=0, homerow=2, homecol=2, profile_rows=4, offsets=[0,-.1,0], params=pinkie_placement_params)
	key_mount_side_bounding_box(x=-1, rightside=true, header=true, footer=true);
      layout_placement(2, 0, params=pinkie_placement_params) key_mount_side_bounding_box(x=1, rightside=true,
										       footer=true);
    }

    hull() {
      layout_placement(row=2, col=0, homerow=2, homecol=2, profile_rows=4, offsets=[0,-.1,0], params=pinkie_placement_params)
	key_mount_corner_bounding_box(x=-1, y=1, header=true);
      layout_placement(2, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=1, rightside=true);
      layout_placement(1, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, rightside=true);
    }
    hull() {
      layout_placement(row=2, col=0, homerow=2, homecol=2, profile_rows=4, offsets=[0,-.1,0], params=pinkie_placement_params)
	key_mount_corner_bounding_box(x=1,y=1, rightside=true, header=true, footer=true);
      layout_placement(0, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1,rightside=true,
											 header=true);
      layout_placement(1, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, rightside=true);
    }
    hull() {
      layout_placement(row=2, col=0, homerow=2, homecol=2, profile_rows=4, offsets=[0,-.1,0], params=pinkie_placement_params)
	key_mount_side_bounding_box(y=1, rightside=true, header=true, footer=true);
      layout_placement(1, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, rightside=true);
    }
    hull() {
      layout_placement(1, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, rightside=true);
      layout_placement(1, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=1, rightside=true);
      layout_placement(0, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, rightside=true,header=true);
    }
    hull() {
      *layout_placement(1, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=-1, rightside=true);
      *layout_placement(0, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=1, y=1, rightside=true,header=true);
      layout_placement(0, 0, params=pinkie_placement_params) key_mount_side_bounding_box(x=1, rightside=true,header=true);
      layout_placement(row=2, col=0, homerow=2, homecol=2, profile_rows=4, offsets=[0,-.1,0], params=pinkie_placement_params)
	key_mount_corner_bounding_box(x=1,y=1, rightside=true, header=true, footer=true);
    }
    hull() {
      layout_placement(0, 0, params=pinkie_placement_params) key_mount_corner_bounding_box(x=-1, y=1, rightside=true,header=true);
      layout_placement(0, 1, params=pinkie_placement_params) key_mount_side_bounding_box(y=1, leftside=true,header=true);
    }

  }
  if (keys) layout_placement(row=2, col=0, homerow=2, homecol=2, profile_rows=4, offsets=[0,-.1,0], params=pinkie_placement_params) keycap($effective_row);
  layout_columns(rows=[rows-1,rows], cols=cols, params=pinkie_placement_params,
		 keys=keys?pinkie_keys:false, wells=false);

}

module strut_mounted_finger_plates(keys=true, thumb=true) {
  //thumb
  if(thumb)
    mounted_thumb(keys);

  // index
  mounted_index(keys);

  // middle+ring
  mounted_middle(keys);

  // pinkie
  mounted_pinkie(keys);

  join_columns(rows,cols, index_placement_params, middle_placement_params, right=true);
  join_columns(rows,cols, middle_placement_params, pinkie_placement_params, left=true);
}



use <key/mount.scad>;
module join_columns(rows, cols, params1, params2, left=false, right=false) {
  for (i=[0:rows-1]) {
    hull() {
      layout_placement(i, 0, params=params1) key_mount_side_bounding_box(x=1, rightside=!right,
								       header=(i==0), footer=(i==(rows-1)));
      layout_placement(i, 1, params=params2) key_mount_side_bounding_box(x=-1, leftside=!left,
								       header=(i==0), footer=(i==(rows-1)));
    }
    if (i < rows -1) {
      hull() {
	layout_placement(i, 0, params=params1) key_mount_corner_bounding_box(x=1, y=-1, rightside=!right,
									   header=(i==0));
	layout_placement(i+1, 0, params=params1) key_mount_corner_bounding_box(x=1, y=1, rightside=!right,
									     footer=((i+1)==(rows-1)));
	layout_placement(i, 1, params=params2) key_mount_corner_bounding_box(x=-1, y=-1, leftside=!left,
									   header=(i==0));
	layout_placement(i+1, 1, params=params2) key_mount_corner_bounding_box(x=-1, y=1, leftside=!left,
									     footer=((i+1)==(rows-1)));
      }
    }
  }
}

module joined_finger_plates(keys=true) {
  //thumb
  let(rows=2,cols=3) {

    layout_columns(rows=rows, cols=cols, params=thumb_placement_params,
		   keys=false);
    layout_columns(rows=rows, cols=cols, params=thumb_placement_params,
		   keys=true, wells=false);
  }

  // index
  install_trackpoint(2, 0, h1=10.9, h2=6, stem=0, up=-0, square_hole=true,
		     displacement=[5,8.5,0], w1=12.3, params=index_placement_params)
    layout_columns(rows=rows, cols=cols, params=index_placement_params,
		   keys=false, leftwall=true);
  layout_columns(rows=rows, cols=cols, params=index_placement_params,
		 keys=keys, wells=false);

  // middle+ring
  layout_columns(rows=rows, cols=cols, params=middle_placement_params,
		 //leftwall=false, rightwall=true, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
		   keys=false);
  layout_columns(rows=rows, cols=cols, params=middle_placement_params,
		 keys=keys?middle_keys:false, wells=false);

  // pinkie
  layout_columns(rows=rows, cols=cols, params=pinkie_placement_params,
		 keys=false, rightwall=true);
  layout_columns(rows=rows, cols=cols, params=pinkie_placement_params,
		 keys=keys?pinkie_keys:false, wells=false);

  join_columns(rows,cols, index_placement_params, middle_placement_params);
  join_columns(rows,cols, middle_placement_params, pinkie_placement_params);
}


module badplate(h=4) {
  children();
  hull(){
    intersection(){
      children();
      translate([0,0,-(25+h/2)]) cube([400,400,h],center=true);
    }
  }
}

//badplate()
//rotate(tent)
strut_mounted_finger_plates(keys=true);

*difference() {
  joined_finger_plates(keys=true);
  translate([0,0,-30-lowest_low]) cube([200,200,lowest_low*2], true);
}

use <util.scad>;
use <assembly/rest.scad>;

base_plate(debug=true);

module base_plate(z=-48,debug=true) {
  // flatten all the mountings into a single array
  mountings = [each index_mountings, each thumb_mountings, each middle_mountings, each pinkie_mountings];

  difference() {
    mount_foot([0,-20,z])
      mount_foot([37,12,z])
      mount_foot([60,-5,z])
      mount_foot([30,-30,z])
      mount_foot([-46,-43,z])
      mount_foot([-5,-43,z])
      mount_foot([-30,-66,z])
      mount_foot([-65,-8,z])
      mount_foot([-90,-8,z])
      mount_foot([-90,21,z])
      mount_foot([-65,21,z])
      mount_foot([-30,20,z])
      mount_foot([0,25,z])
      mount_trrs([27,18,z],[0,0,0])
      mount_teensy20pp([-49.6, 6, z])
      //mount_teensy20pp([23, 5, z],[0,0,-20])
      bar_magnetize_below([-35,-30.4, z], [0,0,90])
      //bar_magnetize_below([34,-5, z], [0,0,0])
      bar_magnetize_below([12.7,-1, z], [0,0,0])
      mount_permaproto_flat([-97.7,-22, z])
      plate(mountings, z=z, debug=debug);

    // cutout to acommodate floating palm rest
    if(!debug) translate([outerdia*2.1,-95,z-.1]) scale([1.,1,1]) wrist_rest_base($fn=120,angle=[0,0,0], back_height=10);
  }
}

module plate(mountings, z=-31, thickness=4, debug=true, vertical=true) {
  module vertical_mount(){
    if (vertical) {
      where=[pinkie_pos.x+12.2+2*(outerdia+spacer()),24.8,10];

      // XXX: it would be far preferable not to rotate the children() but handling tent and tilt in bar_magnetize_below()
      //       would add a (circular) dependency to util.scad on column-util.scad
      rotation_only(tilt=tilt, tent=tent)
	bar_magnetize_below(where, [0,-90,0],grow=[-3,0,0])
	bar_magnetize_below(where+[0,0,17], [0,-90,0])
	reverse_rotation(tilt=tilt, tent=tent)
	children();
    } else {
      children();
    }
  }
  module vertical_mount_bounding_box(bonus=0){
    translate([0,0,z])
      linear_extrude(thickness+bonus)
      projection()
      vertical_mount();
  }

  if (debug) {
    for (mount=mountings) {
      screw_mounting(mounting_params=mount, idx=1, clearance=true);
      #mount_bounding_box(z=z, thickness=thickness, mounting_params=mount);
    }
    if (vertical) {
      vertical_mount();
      #vertical_mount_bounding_box();
    }
  } else {
    difference() {
      // apply the mount to the rest of the plate, so that the mounts' magnet holes get cut from the plate
      vertical_mount() union() {
	for (mount=mountings) {
	  difference(){
	    screw_mounting(mounting_params=mount, idx=1, clearance=debug);
	    translate([0,0,-thickness]) mount_bounding_box(z=z, thickness=thickness, mounting_params=mount);
	    translate([0,0,-2*thickness+.1]) mount_bounding_box(z=z, thickness=thickness, mounting_params=mount);
	  }
	}

	difference() {
	  // to keep the plate a fixed thickness, we intersect the constituent parts with their footprints extruded to a fixed height
	  hull() {
	    for (mount=mountings) {
	      intersection() {
		screw_mounting(mounting_params=mount, idx=1, clearance=false);
		mount_bounding_box(z=z, thickness=thickness, mounting_params=mount);
	      }
	    }
	    if (vertical) intersection(){
	      vertical_mount();
	      vertical_mount_bounding_box();
	    }
	  }

	  // diffing out the hull'd mountings keeps the plate hull above from filling in the cavities
	  for (mount=mountings) {
	    hull() {screw_mounting(mounting_params=mount, idx=1, clearance=true,blank=true);}
	  }
	}
      }
      // remove any part of the mount vertical magnet mount that extends below the plate
      bonus = 10;
      if (vertical) translate([0,0,-thickness-bonus]) vertical_mount_bounding_box(bonus=bonus);
    }
  }
}
