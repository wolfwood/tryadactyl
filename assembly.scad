include <settings.scad>;
use <keycap.scad>;
use <column-util.scad>;
use <column-layout.scad>;
use <trackpoint.scad>;
use <assembly-util.scad>;


rows=4;
cols=2;

homerow=2;
profile_rows=effective_rows(rows,homerow);
tilt=[-5,0,0];
tent=[0,15,0];
row_chord = [14.5,25,0];

tight_spherical_row = [row_chord+[4.1,0,0],
		       row_chord+[3.25,0,0],
		       row_chord+[4.5,0,0],
		       row_chord+[8.6,0,0]];
tight_spherical_col = [[row_chord+[-2,0,0]],
		       [row_chord+[.6,0,0]],
		       [row_chord+[0,0,0]],
		       [row_chord+[-.5,0,0]]];
spherical_z = [3,25,0,0];
index_pos = [-(outerdia+4),-4,6];
index_rotation = [0,10+1,/*3*/0];
index_rows= [rows, rows-1, 1];
index_cols=cols;
index_placement_params =
  layout_placement_params(homerow=[homerow,homerow,0], homecol=0,
			  row_spacing=create_circular_placement([[row_chord], tight_spherical_row, tight_spherical_row]),
			  col_spacing=create_circular_placement(tight_spherical_col, z_correct=spherical_z),
			  profile_rows=profile_rows, tent=tent, tilt=index_rotation+tilt, position=index_pos);

index_mountings = [screw_mounting_params(row=0, col=0, height=35, layout_params=index_placement_params,
					 displacement=[1,1,-15], offsets=[0,0,-1]),
		   screw_mounting_params(row=1, col=0, height=25, layout_params=index_placement_params)
		   /*screw_mounting_params(row=3, col=0, height=50, layout_params=index_placement_params,
					 headroom=[[1,0],[2,7]],
					 displacement=[2,5,-20])*/
		];


middle_keys = true;
//middle_offset = [[0,0,0], [0,4,1]];
middle_offset = [0,4+1,1];
middle_rotation = [0,0,0];
middle_placement_params =
  layout_placement_params(homerow=homerow, homecol=1,
			  row_spacing=create_circular_placement(row_chord),
			  col_spacing=create_flat_placement(outerdia+spacer()),
			  profile_rows=profile_rows,
			  offsets=[[0,0,0], middle_offset], tent=tent, tilt=middle_rotation+tilt);
middle_mountings = [screw_mounting_params(row=0, col=0, height=12, headroom=[[1,4],[2,7]], footroom=[[2,0],[2,2]],
					  layout_params=middle_placement_params,
					  /*displacement=[1.3,.4,-15],*/displacement=[-.9,1.6,-15-3], offsets=[0,0, -3.7]),
		    screw_mounting_params(row=1, col=0, height=6, layout_params=middle_placement_params,
					  displacement=[-2.6,-1,-15],
					  offsets=middle_offset+[0,0,-1]),
		    screw_mounting_params(row=3, col=0, height=20, headroom=[[2,0],[2,7]],
					  layout_params=middle_placement_params,
					  displacement=[-4.5,-1.5,-15], offsets=[0,0,0])
		    ];


pinkie_keys = true;//[[false],[true],[false],[false]];
pinkie_pos = [outerdia+spacer()+20,-13+1,6];
pinkie_rotation = [0,0,/*-5*/-2];
pinkie_placement_params =
  layout_placement_params(homerow=homerow, homecol=1,
			  row_spacing=create_circular_placement([tight_spherical_row,
 								 [row_chord]]),
			  col_spacing=create_circular_placement(tight_spherical_col, z_correct=spherical_z),
			  profile_rows=profile_rows, offsets=[0,0,0], tent=tent, tilt=pinkie_rotation+tilt,
			  position=pinkie_pos);

pinkie_mountings = [screw_mounting_params(row=0, col=0, height=6,
					  displacement=[2,-5,-15],
					  offsets=[0,0,-2],
					  layout_params=pinkie_placement_params),
		    /*screw_mounting_params(row=1, col=0, height=6, layout_params=pinkie_placement_params,
		      displacement=[1,0,-15]),*/
					  screw_mounting_params(row=2, col=0, height=6, layout_params=pinkie_placement_params)
		    ];

thumb_keys= [false,true,false];
thumb_pos = index_pos + [-1.75*(outerdia+spacer()),-2.5*(outerdia+spacer())+7,-15 -5];
thumb_row_chord_sides = [20.5,500,0];
thumb_row_chord_center = [14.5,/*28*/ 50,0];
thumb_placement_params =
  layout_placement_params(homerow=0, homecol=1,
			  /*row_spacing=create_circular_placement([[thumb_row_chord_sides],
								 [thumb_row_chord_center],
								 [thumb_row_c1hord_sides]]),*/
			  row_spacing = create_flat_placement(19.1),
			  col_spacing = create_circular_placement([[[14,16,0]],[[18,32,0]]],z_correct=0),
			  profile_rows=[[3,2],[3,"SKRH"],[1,2]],
			  tent=tent+[-10,0,0], tilt=[20,-60,0],
			  position=thumb_pos);

thumb_mountings = [screw_mounting_params(row=0, col=1, height=10, displacement=[-0.5,-13,-15],
					 headroom= [[1,0],[2,7]], layout_params=thumb_placement_params),
		   screw_mounting_params(row=0, col=1, height=10, displacement=[1,6,-15],
					 layout_params=thumb_placement_params),
		   screw_mounting_params(row=0, col=0, height=30, offsets=[0,0,0], displacement=[4,0,-21],
					 headroom=[[2,3],[2,7]], footroom=[[7,2],[2,2]],
					 layout_params=thumb_placement_params)
		];

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
  let(rows=2,cols=3) {
    apply_screw_mountings(params=thumb_mountings)
      layout_columns(rows=rows, cols=cols, params=thumb_placement_params,
		     keys=false, perimeter=true);
    layout_columns(rows=rows, cols=cols, params=thumb_placement_params,
		   keys=keys?thumb_keys:false, wells=false);
  }
}

module mounted_index(keys=true) {
  tp_disp = [5.6,9,0];
  tp_corner_disp = [11,2.8,0];
  apply_screw_mountings(params=index_mountings)
    install_trackpoint(2, 0, h1=10.9, h2=6, stem=0, up=-0, square_hole=true,
		       displacement=tp_disp, w1=12.8, params=index_placement_params)
    union() {
    layout_columns(rows=index_rows, cols=index_cols, params=index_placement_params,
		   keys=false);
    hull() {
      layout_placement(3, 0, params=index_placement_params) keywell_side_bounding_box(x=-1, rightside=true,
											footer=true);
      layout_placement(2, 1, params=index_placement_params) keywell_corner_bounding_box(y=-1, x=1, leftside=true,
											footer=true);
    }
    hull () {
      layout_placement(3, 0, params=index_placement_params, displacement=tp_corner_disp, corners=true)
	keywell_corner_bounding_box(x=-1, y=1,leftside=true, footer=true);
      layout_placement(2, 1, params=index_placement_params) keywell_side_bounding_box(y=-1, leftside=true,
										      footer=true);
    }
    hull () {
      layout_placement(3, 0, params=index_placement_params, displacement=tp_corner_disp, corners=true)
	keywell_corner_bounding_box(x=-1, y=1,leftside=true, footer=true);
      layout_placement(3, 0, params=index_placement_params) keywell_corner_bounding_box(x=-1, y=-1, rightside=true,
										      footer=true);
      layout_placement(2, 1, params=index_placement_params) keywell_bounding_box(y=-1, x=1, leftside=true,
											footer=true);
    }

    *hull() {
      layout_placement(2, 1, params=index_placement_params) keywell_corner_bounding_box(y=-1, x=1,
											footer=true);
      /*layout_placement(3, 0, params=pinkie_placement_params) keywell_corner_bounding_box(y=1, x=-1,
	rightside=true,
	footer=true);*/
      layout_placement(2, 0, params=index_placement_params) keywell_corner_bounding_box(x=-1, y=-1);
      layout_placement(3, 0, params=index_placement_params) keywell_corner_bounding_box(x=-1, y=1,
											footer=true);
    }

    layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params) keywell(header=true, footer=true, leftside=true);

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	keywell_bounding_box(x=1,header=true, footer=true, leftside=true);
      layout_placement(2, 1, params=index_placement_params) keywell_bounding_box(x=-1, leftside=true,
											footer=true);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	keywell_bounding_box(x=1,y=-1, header=true, footer=true, leftside=true);
      layout_placement(2, 1, params=index_placement_params) keywell_bounding_box(x=-1,y=-1, leftside=true,
										 footer=true);
      layout_placement(3, 0, params=index_placement_params, displacement=tp_corner_disp, corners=true)
	keywell_corner_bounding_box(x=-1, y=1,leftside=true, footer=true);
    }
    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	keywell_bounding_box(y=-1, header=true, footer=true, leftside=true);
           layout_placement(3, 0, params=index_placement_params, displacement=tp_corner_disp, corners=true)
	keywell_corner_bounding_box(x=-1, y=1,leftside=true, footer=true);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	keywell_bounding_box(x=1,y=1, header=true, footer=true, leftside=true);
      layout_placement(2, 1, params=index_placement_params) keywell_bounding_box(x=-1,y=1, leftside=true,
										 footer=true);
      layout_placement(1, 1, params=index_placement_params) keywell_bounding_box(x=-1,y=-1, leftside=true,
										 footer=false);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	keywell_bounding_box(y=1, header=true, footer=true, leftside=true);
      layout_placement(1, 1, params=index_placement_params) keywell_bounding_box(x=-1,y=-1, leftside=true);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	keywell_bounding_box(x=-1,y=1, header=true, footer=true, leftside=true);
      layout_placement(0, 1, params=index_placement_params) keywell_bounding_box(x=-1, leftside=true,header=true);
    }

    hull() {
      layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params)
	keywell_bounding_box(x=-1,y=1, header=true, footer=true, leftside=true);
      layout_placement(0, 1, params=index_placement_params) keywell_bounding_box(x=-1, y=-1, leftside=true,header=true);
      layout_placement(1, 1, params=index_placement_params) keywell_bounding_box(x=-1, y=-1, leftside=true);
    }

    hull() {
      layout_placement(0, 1, params=index_placement_params) keywell_bounding_box(x=-1, y=-1, leftside=true,header=true);
      layout_placement(1, 1, params=index_placement_params) keywell_bounding_box(x=-1, leftside=true);

    }

    hull() {
      layout_placement(0, 1, params=index_placement_params) keywell_bounding_box(x=1, y=1, leftside=true,header=true);
      layout_placement(0, 0, params=index_placement_params) keywell_bounding_box(y=1, header=true);

    }

  }

  layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params) keycap($effective_row);
  layout_columns(rows=index_rows, cols=cols, params=index_placement_params,
		 keys=keys, wells=false);

}

module mounted_middle(keys=true) {
  apply_screw_mountings(params=middle_mountings) {
    layout_columns(rows=rows, cols=cols, params=middle_placement_params,
		   //leftwall=false, rightwall=true, topwall=false, bottomwall=false, narrowsides=false, perimeter=true,
		   keys=false);
    hull() {
      layout_placement(3, 0, params=middle_placement_params) keywell_corner_bounding_box(x=-1, y=-1,
											 footer=true);
      layout_placement(3, 1, params=middle_placement_params) keywell_side_bounding_box(y=-1, leftside=true,
										       footer=true);
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
      layout_placement(2, 0, params=pinkie_placement_params) keywell_side_bounding_box(y=-1, rightside=true,
										       footer=true);
      layout_placement(3, 1, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, leftside=true,
											 footer=true);
    }
    hull() {
      layout_placement(2, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=-1,y=-1, rightside=true,
											 footer=true);
      layout_placement(3, 1, params=pinkie_placement_params) keywell_side_bounding_box(x=1, leftside=true,
										       footer=true);
    }
    hull() {
      layout_placement(2, 0, params=pinkie_placement_params) keywell_corner_bounding_box(y=-1, x=-1,
											 rightside=true,
											 footer=true);
      /*layout_placement(3, 0, params=pinkie_placement_params) keywell_corner_bounding_box(y=1, x=-1,
	rightside=true,
	footer=true);*/
      layout_placement(2, 1, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, leftside=true
											 );
      layout_placement(3, 1, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=1, leftside=true,
											 footer=true);
    }
  }
  layout_placement(row=2, col=0, homerow=2, homecol=2, offsets=[0,-.1,0],params=pinkie_placement_params) keywell(header=true, footer=true, rightside=true);
  layout_placement(row=2, col=0, homerow=2, homecol=2, offsets=[0,-.1,0], params=pinkie_placement_params) keycap($effective_row);
  layout_columns(rows=[rows-1,rows], cols=cols, params=pinkie_placement_params,
		 keys=keys?pinkie_keys:false, wells=false);


  hull() {
    layout_placement(3, 1, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, leftside=true,
										       footer=true);
    layout_placement(2, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1,y=-1, rightside=true,
										       footer=true);
    layout_placement(row=2, col=0, homerow=2, homecol=2, offsets=[0,-.1,0], params=pinkie_placement_params)
      keywell_corner_bounding_box(x=-1,y=-1, rightside=true, header=true, footer=true);
  }
    hull() {
    layout_placement(3, 1, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, leftside=true,
										       footer=true);
    layout_placement(row=2, col=0, homerow=2, homecol=2, offsets=[0,-.1,0], params=pinkie_placement_params)
      keywell_side_bounding_box(y=-1, rightside=true, header=true, footer=true);
  }
  hull() {
    layout_placement(row=2, col=0, homerow=2, homecol=2, offsets=[0,-.1,0], params=pinkie_placement_params)
      keywell_side_bounding_box(x=-1, rightside=true, header=true, footer=true);
    layout_placement(2, 0, params=pinkie_placement_params) keywell_side_bounding_box(x=1, rightside=true,
										     footer=true);
  }

  hull() {
    layout_placement(row=2, col=0, homerow=2, homecol=2, offsets=[0,-.1,0], params=pinkie_placement_params)
      keywell_corner_bounding_box(x=-1, y=1, header=true);
    layout_placement(2, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=1, rightside=true);
    layout_placement(1, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, rightside=true);
  }
  hull() {
    layout_placement(row=2, col=0, homerow=2, homecol=2, offsets=[0,-.1,0], params=pinkie_placement_params)
      keywell_corner_bounding_box(x=1,y=1, rightside=true, header=true, footer=true);
    layout_placement(0, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1,rightside=true,
										     header=true);
    layout_placement(1, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, rightside=true);
  }
  hull() {
    layout_placement(row=2, col=0, homerow=2, homecol=2, offsets=[0,-.1,0], params=pinkie_placement_params)
      keywell_side_bounding_box(y=1, rightside=true, header=true, footer=true);
    layout_placement(1, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, rightside=true);
  }
  hull() {
    layout_placement(1, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, rightside=true);
    layout_placement(1, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=1, rightside=true);
    layout_placement(0, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, rightside=true,header=true);
  }
  hull() {
    *layout_placement(1, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=-1, rightside=true);
    *layout_placement(0, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=1, y=1, rightside=true,header=true);
    layout_placement(0, 0, params=pinkie_placement_params) keywell_side_bounding_box(x=1, rightside=true,header=true);
    layout_placement(row=2, col=0, homerow=2, homecol=2, offsets=[0,-.1,0], params=pinkie_placement_params)
      keywell_corner_bounding_box(x=1,y=1, rightside=true, header=true, footer=true);
  }
  hull() {
    layout_placement(0, 0, params=pinkie_placement_params) keywell_corner_bounding_box(x=-1, y=1, rightside=true,header=true);
    layout_placement(0, 1, params=pinkie_placement_params) keywell_side_bounding_box(y=1, leftside=true,header=true);
  }
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



use <keywell.scad>;
module join_columns(rows, cols, params1, params2, left=false, right=false) {
  for (i=[0:rows-1]) {
    hull() {
      layout_placement(i, 0, params=params1) keywell_side_bounding_box(x=1, rightside=!right,
								       header=(i==0), footer=(i==(rows-1)));
      layout_placement(i, 1, params=params2) keywell_side_bounding_box(x=-1, leftside=!left,
								       header=(i==0), footer=(i==(rows-1)));
    }
    if (i < rows -1) {
      hull() {
	layout_placement(i, 0, params=params1) keywell_corner_bounding_box(x=1, y=-1, rightside=!right,
									   header=(i==0));
	layout_placement(i+1, 0, params=params1) keywell_corner_bounding_box(x=1, y=1, rightside=!right,
									     footer=((i+1)==(rows-1)));
	layout_placement(i, 1, params=params2) keywell_corner_bounding_box(x=-1, y=-1, leftside=!left,
									   header=(i==0));
	layout_placement(i+1, 1, params=params2) keywell_corner_bounding_box(x=-1, y=1, leftside=!left,
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

module base_plate(z=-31,debug=true) {
  //*magnetize(position=[-16,-25,-29])
  //magnetize(position=[28,-15,-29], post_height=8)

  mountings = [each index_mountings, each thumb_mountings, each middle_mountings, each pinkie_mountings];

  //if (debug) {
  //plate(mountings, z=z, debug=debug);
  //} else {

  mount_trrs([15,25,z],[0,0,0])
    mount_teensy20pp([-14, 5, z])
    //mount_teensy20pp([23, 5, z],[0,0,-20])
    bar_magnetize_below([-31.5,-33.5, z], [0,0,90])
    bar_magnetize_below([34,-5, z], [0,0,0])
    mount_permaproto([-60,-24, z], rail1=25.5, rail2=30)
    plate(mountings, z=z, debug=debug);
    //}

}

base_plate(debug=true);

module plate(mountings, z=-31, thickness=4, debug=true) {
  if (debug) {
    for (mount=mountings) {
      screw_mounting(mounting_params=mount, idx=1, clearance=true);
      #mount_bounding_box(z=z, thickness=thickness, mounting_params=mount);
    }
  } else {
    for (mount=mountings) {
      difference(){
	screw_mounting(mounting_params=mount, idx=1, clearance=debug);
	translate([0,0,-thickness]) mount_bounding_box(z=z, thickness=thickness, mounting_params=mount);
	translate([0,0,-2*thickness+.1]) mount_bounding_box(z=z, thickness=thickness, mounting_params=mount);
      }
    }

    difference() {
      hull() {
	for (mount=mountings) {
	  intersection() {
	    screw_mounting(mounting_params=mount, idx=1, clearance=false);
	    mount_bounding_box(z=z, thickness=thickness, mounting_params=mount);
	  }
	}
      }

      for (mount=mountings) {
	hull() {screw_mounting(mounting_params=mount, idx=1, clearance=true,blank=true);}
      }
    }
  }
}
