use <settings.scad>;
use <key/cap.scad>;
use <column/util.scad>;
use <column/layout.scad>;
use <assembly/trackpoint.scad>;
use <assembly/util.scad>;
use <key/mount.scad>;


index_walls = [
	       [ [ [0,[0,13,23.7]] ],  [], [], []/* [2, [0,9.5,5]] ]*/ ],
	       [ [ [0, [[0,5,10],[0,-5,30]]],[3, [10,0,39]]  ], [ [3,[10,0,30]] ], [], /*[ [2,[0,0,20]] , [3, [0,10,10]] ]*/ ],
	       [ [ [0,[0,10,30]], [3,[10,0,30]] ] ]
		];

index_walls2 = [
	       [ [ [0,[0,13,23.7]] ],  [], [], [ [2, [0,9.5,5]] , [3,[20,0,0]]] ],
		[ [ [0, [0,5,45]],[3, [10,0,39]]  ], [ [3,[10,0,30]] ], [ [2,[0,30,-30]] ] ],
		];

middle_walls = [
		[ [ [0,[0,15,23.7]] ],  [], [], [ [2, [0,25,12]] ] ],
		[ [ [0, [0,10,15]]  ], [], [], [ /*[2,[0,15.5,10.3]]*/ ] ],
		];

pinkie_walls = [
		[ [ [1, [17,0, 23]], [2, [[0,5,0], [0,31,0]]] ] ],
		[ [ [0, [[0,8,5], [0,5,45]] ], [1, [22,0,25]]  ], [ [1,[30,0,23]] ], [ [2,[[0,5,0], [0,31,0]]] ] ],
		[ [ [0,[0,28,23.7]] ],  [], [], [ [2, [0,9.5,5]]/*, [1, [0,0,0]]*/ ] ],
		];

thumb_walls = [
	       [ [], [] ],
	       [ [ [0, [0,5,5]] ], [ [2, [0,5,5]] ] ],
	       [ [ [0, [0,5,5]], [3, [5,0,5]] ], [  [2, [0, 5,5]], [3, [10,0,5]] ] ]
	       ];


middle_walls2 = [
		[ [ [0,[0,15,23.7]],  [1,[5,0,0]] ], [ [1, [5,0,0]] ], [ [1, [5,0,0]] ], [ [1, [5,0,0]], [2, [0,5,5]] ] ],
		[ [ [0, [0,10,15]], [3,[10,0,5]] ], [ [3,[10,0,5]] ], [ [3,[10,0,5]] ], [ [3,[10,0,5]], [2,[0,13.5,10.3]] ] ],
		];

middle_walls3 = [
		[ [ [0,[0,0,0]], [1,[0,0,0]] ], [ [1,[0,0,0]] ], [ [1,[0,0,0]] ], [ [1,[0,0,0]], [2,[0,0,0]] ] ],
		[ [ [0,[0,0,0]], [3,[0,0,0]] ], [ [3,[0,0,0]] ], [ [3,[0,0,0]] ], [ [3,[0,0,0]], [2,[0,0,0]] ] ],
		];


use_walls=true;
use_topper=true;
rows=4;
cols=2;

homerow=2;
profile_rows=effective_rows(rows,homerow);
tilt=[-3,0,0];
tent=[0,33,0];
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
tight_spherical_col = [[row_chord+[-.8,0,0]],
		       [row_chord+[1.9,0,0]],
		       [row_chord+[0,0,0]],
		       [row_chord+[-.5,0,0]]];
spherical_z = [4,30,0,0];


//layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params) key_mount(header=true, footer=true, leftside=true);
index_keys= true;
index_pos = [-(outerdia()+4),-4,6];
index_tent = [0,0,5];
index_tilt = [0,0,0];
index_rows= [rows, rows-1, 1];
index_cols=cols +1;

//index_col_sp=tight_spherical_col;
index_col_sp=[[tight_spherical_col[0][0],tight_spherical_col[0][0],tight_spherical_col[2][0]],[tight_spherical_col[1][0]],[tight_spherical_col[2][0]],[tight_spherical_col[3][0]]];
//index_col_sp=[[tight_spherical_col[0]],[tight_spherical_col[1]],[tight_spherical_col[2]],[tight_spherical_col[3]]];
//index_col_sp=[[tight_spherical_col[0], tight_spherical_col[0], tight_spherical_col[0], tight_spherical_col[0]], [tight_spherical_col[1], tight_spherical_col[1], tight_spherical_col[1], tight_spherical_col[1]], [tight_spherical_col[2], tight_spherical_col[2], tight_spherical_col[2], tight_spherical_col[2]], [tight_spherical_col[3], tight_spherical_col[3], tight_spherical_col[3], tight_spherical_col[3]]];

index_placement_params =
  layout_placement_params(homerow=[homerow,homerow,0], homecol=0,
			  row_spacing=create_circular_placement([tight_cylindrical_row, tight_spherical_row, [row_chord]]),
			  col_spacing=create_circular_placement(index_col_sp, z_correct=spherical_z),
			  profile_rows=[profile_rows,profile_rows,[4]],
			  offsets=[[0,0,0],[0,0,0],[0,-.1,0]],
			  tent=index_tent+tent, tilt=index_tilt, position=index_pos);

middle_keys = true;
//middle_offset = [[0,0,0], [0,4,1]];
middle_offset = [0,5,0];
ring_offset=[0,-5,-1];
middle_rotation = [0,0,0];
middle_placement_params =
  layout_placement_params(homerow=homerow, homecol=1,
			  row_spacing=create_circular_placement(tight_cylindrical_row),
			  col_spacing=create_flat_placement(outerdia()+spacer()),
			  profile_rows=profile_rows,
			  offsets=[ring_offset, middle_offset], tent=tent, tilt=middle_rotation+tilt);

pinkie_keys = true;//[[false],[true],[false],[false]];
pinkie_pos = [outerdia()+spacer()+20,-23,4];
pinkie_tent = [0,0,-2];
pinkie_tilt = [3,0,0];
pinkie_rows = [1, rows-1, rows];
pinkie_cols = cols +1;
pinkie_placement_params =
  layout_placement_params(homerow=[0,homerow,homerow], homecol=2,
			  row_spacing=create_circular_placement([tight_spherical_row, tight_spherical_row,
 								 [row_chord]]),
			  col_spacing=create_circular_placement(tight_spherical_col, z_correct=spherical_z),
			  profile_rows=[[4],profile_rows,profile_rows],
			  offsets=[[0,-.1,0],[0,0,0],[0,0,0]], tent=tent+pinkie_tent, tilt=pinkie_tilt+tilt,
			  position=pinkie_pos);


thumb_keys= true;
thumb_pos = index_pos + [-1.5*(outerdia()+spacer())+30,-3.5*(outerdia()+spacer())-1,-30];
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

module mounted_index(keys=true) {
  tp_disp = [6.5,11,0];
  tp_corner_disp = [11,2.8,0];
  //  apply_screw_mountings(params=index_mountings)
    install_trackpoint(2, 0, h1=13, h2=8.8, stem=0, up=-0, square_hole=false, access=true,
      tilt=tilt, use_shield=true,  shield=[4,12,15], shield_angle=[-69,-5],
      displacement=tp_disp, w1=14, params=index_placement_params)

    union() {
      layout_columns(rows=index_rows, cols=index_cols, params=index_placement_params,
		     keys=false,
		     wall_matrix=index_walls
		     //rightwall=true,
		     //leftwall=true,
		     //topwall=true, bottomwall=true);
		     );

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

    *layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params) key_mount(header=true, footer=true, leftside=true);
  }

  if (keys) {
    //layout_placement(row=2, col=2, homerow=2, homecol=0, offsets=[0,-.1,0], params=index_placement_params) keycap($effective_row);
    layout_columns(rows=index_rows, cols=index_cols, params=index_placement_params,
		   keys=index_keys, wells=false);
  }
}

module mounted_middle(keys=true) {
  //apply_screw_mountings(params=middle_mountings) {
    layout_columns(rows=rows, cols=cols, params=middle_placement_params,
		   rightsides=[false,false],
		   leftsides=false,
		   //leftwall=true,
		   //rightwall=true,
		   //topwall=true, bottomwall=true, //narrowsides=false, perimeter=true,
		   keys=false,
		   wall_matrix=middle_walls
		   );
    if (keys) {
      layout_columns(rows=rows, cols=cols, params=middle_placement_params,
		 keys=keys?middle_keys:false, wells=false);
    }
}

module mounted_pinkie(keys=true) {
  //apply_screw_mountings(params=pinkie_mountings)
  layout_columns(rows=pinkie_rows/*[rows-1,rows]*/, cols=pinkie_cols, params=pinkie_placement_params,
		 wall_matrix=pinkie_walls,
		 keys=false);

  if (keys) layout_columns(rows=pinkie_rows, cols=pinkie_cols, params=pinkie_placement_params,
			   keys=pinkie_keys, wells=false);
}


module mounted_thumb(keys=true) {
  let(rows=2//[1,2,1]
      ,cols=3) {
    //apply_screw_mountings(params=thumb_mountings) {
    layout_columns(rows=rows, cols=cols, params=thumb_placement_params,
		   wall_matrix=thumb_walls,
		   keys=false, perimeter=true, reverse_triangles=false);
    layout_columns(rows=rows, cols=cols, params=thumb_placement_params,
		   keys=keys?thumb_keys:false, wells=false);
  }
}

keys=true;

if(false)
    mounted_thumb(keys);
mounted_index(keys=keys);
mounted_middle(keys=keys);
mounted_pinkie(keys=keys);
join_columns(rows,cols, index_placement_params, middle_placement_params, right=true);
join_columns(rows,pinkie_cols, middle_placement_params, pinkie_placement_params, left=true);

use <key/mount.scad>;
module join_columns(rows, cols, params1, params2, left=false, right=false) {
  for (i=[0:rows-1]) {
    hull() {
      layout_placement(i, 0, params=params1) key_mount_side_bounding_box(x=1, rightside=!right,
								       header=(i==0), footer=(i==(rows-1)));
      layout_placement(i, cols-1, params=params2) key_mount_side_bounding_box(x=-1, leftside=!left,
								       header=(i==0), footer=(i==(rows-1)));
    }
    if (i < rows -1) {
      hull() {
	layout_placement(i, 0, params=params1) key_mount_corner_bounding_box(x=1, y=-1, rightside=!right,
									   header=(i==0));
	layout_placement(i+1, 0, params=params1) key_mount_corner_bounding_box(x=1, y=1, rightside=!right,
									     footer=((i+1)==(rows-1)));
	layout_placement(i, cols-1, params=params2) key_mount_corner_bounding_box(x=-1, y=-1, leftside=!left,
									   header=(i==0));
	layout_placement(i+1, cols-1, params=params2) key_mount_corner_bounding_box(x=-1, y=1, leftside=!left,
									     footer=((i+1)==(rows-1)));
      }
    }
  }
}
