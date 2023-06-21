/* a flat column. not really a dactyl but someone may like it.
 *  also a good starting place for understanding other columns,
 *  and useful for validating profiles' position_flat() funcitons with the flat_tester()
 */


use <../settings.scad>;
use <../key/mount.scad>;
use <../key/cap.scad>;
use <util.scad>;
use <../util.scad>;

module layout_columns(rows=4, cols=1, homerow, homecol, row_spacing,
		      col_spacing,

		      profile_rows, offsets, tilt, displacement=[0,0,0], keys=false, wells=true,
		      headers=false, footers=false, leftsides=false, rightsides=false,
		      leftwall=false, rightwall=false, topwall=false, bottomwall=false,
		      perimeter=true, narrowsides=false, flatten=true,
		      reverse_triangles=false, punch_holes=false,
		      params=default_layout_placement_params(),
		      wall_matrix) {
  layout_plate_only(rows=rows, cols=cols, homerow=homerow, homecol=homecol,row_spacing=row_spacing,
		    col_spacing=col_spacing,
		    profile_rows=profile_rows, offsets=offsets, tilt=tilt, displacement=displacement, keys=keys, wells=wells,
		    headers=headers, footers=footers, leftsides=leftsides, rightsides=rightsides,
		    leftwall=leftwall, rightwall=rightwall, topwall=topwall, bottomwall=bottomwall,
		    perimeter=perimeter, narrowsides=narrowsides, flatten=flatten,
		    reverse_triangles=reverse_triangles, punch_holes=punch_holes,
		    params=params);

  if (wells) {
    layout_walls_only(rows=rows, cols=cols, homerow=homerow, homecol=homecol, row_spacing=row_spacing,
		      col_spacing=col_spacing,
		      profile_rows=profile_rows, offsets=offsets, tilt=tilt, displacement=displacement, keys=keys, wells=wells,
		      headers=headers, footers=footers, leftsides=leftsides, rightsides=rightsides,
		      leftwall=leftwall, rightwall=rightwall, topwall=topwall, bottomwall=bottomwall,
		      perimeter=perimeter, narrowsides=narrowsides, flatten=flatten, params=params,
		      wall_matrix=wall_matrix);
  }
}

function bool2int(b) = b ? 1 : 0;
function side_gets_spacer(spacer, has_neighbor, perimeter, force_underhang) =
  (spacer || (perimeter && !has_neighbor)) && !(force_underhang && !has_neighbor);

module layout_plate_only(rows=4, cols=1, homerow, homecol, row_spacing,
			 col_spacing,
			 profile_rows, offsets, tilt, displacement=[0,0,0], keys=false, wells=true,
			 headers=false, footers=false, leftsides=false, rightsides=false,
			 leftwall=false, rightwall=false, topwall=false, bottomwall=false,
			 perimeter=true, narrowsides=false, flatten=true,
			 reverse_triangles=false, punch_holes=false,
			 params=default_layout_placement_params()) {

  module placement_helper(row,col) {
    // lets us pass row, column as 2 scalar parameters, or as a single 2d vector
    let(col = is_undef(col) ? row.y : col, row = is_list(row) ? row.x : row) {
      $h = side_gets_spacer(optional_index(headers,row,col), row != 0, perimeter, narrowsides);
      $f = side_gets_spacer(optional_index(footers,row,col), row != optional_index(rows, col)-1, perimeter, narrowsides);
      $r = side_gets_spacer(optional_index(rightsides,row,col), col != 0, perimeter, narrowsides);
      $l = side_gets_spacer(optional_index(leftsides,row,col), col != cols-1, perimeter, narrowsides);

      layout_placement(row=row, col=col, row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows,
		       homerow=homerow, homecol=homecol, tilt=tilt, offsets=offsets, displacement=displacement, flatten=flatten, params=params) children();
    }
  }

  // used to join key_mounts so they form a solid plate
  module connect(this, left, down, corner) {
    // params can be ignored, otherwise they should ve a 2d vector of [row,col]
    assert( ( is_undef(this) || is_list(this) ) &&
	    ( is_undef(left) || is_list(left) ) &&
	    ( is_undef(down) || is_list(down) ) &&
	    ( is_undef(corner) || is_list(corner) )
	    );

    // translates param names to bounding box positions, and handles undefined params gracefully
    module hull_corners(this, left, down, corner) {
      hull() {
	if (!is_undef(this))
	  placement_helper(this) key_mount_bounding_box(y=-1, x=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
	if (!is_undef(left))
	  placement_helper(left) key_mount_bounding_box(y=-1, x=1, header=$h, footer=$f, leftside=$l, rightside=$r);
	if (!is_undef(down))
	  placement_helper(down) key_mount_bounding_box(y=1, x=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
	if (!is_undef(corner))
	  placement_helper(corner) key_mount_bounding_box(y=1, x=1, header=$h, footer=$f, leftside=$l, rightside=$r);
      }
    }

    //for figuring out how many unique key_mounts we are joining
    function count_def(test) = is_undef(test) ? 0 : 1;

    num_wells = count_def(this) + count_def(left) + count_def(down) + count_def(corner);

    // of there is only one well we aren't joining anything
    assert(num_wells > 1);

    // for 3 wells, just do what the caller says, otherwise we need to split  the quadralateral into 2 triangles
    if (num_wells == 3) {
      hull_corners(this, left, down, corner);
    } else {

      /* this is a trick to handle joining 2 key_mounts along a row or column the same as joining the intersection
       * of 4 key_mounts. To connect 2 wells in the same column, left is mapped onto 'this' and corner onto down.
       * To connect 2 wells in the same row, down is mapped onto 'this' and corner onto left.  this reverses the ordering
       * so the reverse boolean is needed to correct this.
       */
      let (corner = is_undef(corner) ? (is_undef(left) ? down : left) : corner,
	   left = is_undef(left) ? this : left,
	   down = is_undef(down) ? this : down) {

	/* this is our heuristic for producing concave hulls (which are desireable because they are less likely
	 *  to protrude from the plate and interfere with keycap travel) by using 2 triangular convex hulls of the
	 *  corners of key_mounts, instead of a single convex hull of all 4 corners,
	 *  which will always protrude a bit (and sometimes quite a lot) because it is, after all, convex:
	 * hulls on the upper right and lower left quadrants of a curved plate should be triangulated so that
	 *  upper left and lower right corners connect (left and down appear in both hulls). */
	quadrant = (this.y < $homecol && this.x <= $homerow) || (this.y >= $homecol && this.x > $homerow);

	/* the trick used in the let statement "reverses" the hulls ordering of corners
	 *  (eg down becomes the upper corner of this and so is no longer below but above)
	 *  so if we are doing tricks, we need to reverse the triangluation from the baseline
	 */
	reverse = num_wells != 4;

	// we can override the heuristic with reverse_triangles if needed
	if (xor(quadrant, xor(reverse, reverse_triangles))) {
	  hull_corners(this=this,left=left,down=down);
	  hull_corners(left=left,down=down,corner=corner);
	} else {
	  hull_corners(this=this,left=left,corner=corner);
	  hull_corners(this=this,down=down,corner=corner);
	}
      }
    }
  }

  difference() {
    for (j=[0:cols-1]) {
      row_count = optional_index(rows,j);
      for (i=[0:row_count-1]) {
	if (!punch_holes && optional_index(keys, j, i)) {
	  placement_helper(i,j) keycap($effective_row);
	}

	if (wells) get_homes(params, homerow, homecol, j){// let(homerow=$homerow, homecol=$homecol){
	    // well
	    if (!punch_holes) {
	      placement_helper(i,j) key_mount(header=$h, footer=$f, leftside=$l, rightside=$r);
	    } else {
	      placement_helper(i,j) key_mount_slug(header=$h, footer=$f, leftside=$l, rightside=$r);
	    }
	    if ($preview && !punch_holes) placement_helper(i,j) hotswap();

	    //connect rows
	    if (i < row_count-1) {
	      connect([i,j], down=[i+1,j]);
	    }

	    // XXX get row offset working, also handle corner connect when next column is longer than this one
	    //                               (maybe connect bottom to side as well?)

	    //connect cols
	    if (j < cols-1) { // not the last column
	      let(next_homerow=get_homerow(params, homerow, j+1),
		  next_row_count=optional_index(rows, j+1),
		  row_offset=(next_homerow - $homerow),
		  next_i=i+row_offset,
		  next_j=j+1) {

		next_i_valid      = 0 <= next_i   && next_i   < next_row_count;
		next_corner_valid = 0 <= next_i+1 && next_i+1 < next_row_count;

		if (next_i_valid) {
		  connect([i,j], left=[next_i, next_j]);
		}

		//connect connectors
		if (bool2int(i < row_count-1) + bool2int(next_i_valid) + bool2int(next_corner_valid) >= 2) {
		  connect([i,j],
			  down   = (i < row_count-1)   ? [i+1,j]           : undef,
			  left   = (next_i_valid)      ? [next_i,next_j]   : undef,
			  corner = (next_corner_valid) ? [next_i+1,next_j] : undef);
		}
	      }
	    }
	  }
      }
    }
    if (punch_holes) {
      for (j=[0:cols-1]) {
	row_count = optional_index(rows,j);
	for (i=[0:row_count-1]) {
	  if (wells) get_homes(params, homerow, homecol, j){
	      // well
	      placement_helper(i,j) key_mount_cavity(above=true,below=true);
	    }
	}
      }
    }
  }

  if (punch_holes) {
    for (j=[0:cols-1]) {
      row_count = optional_index(rows,j);
      for (i=[0:row_count-1]) {
	if (optional_index(keys, j, i)) {
	  placement_helper(i,j) keycap($effective_row);
	}
	if (wells) get_homes(params, homerow, homecol, j){
	    if ($preview) placement_helper(i,j) hotswap();
	  }
      }
    }
  }
}

function create_direction_vector(v) = [ for(i=v) if (i[0]) i[1] ];


module layout_walls_only(rows=4, cols=1, homerow, homecol, row_spacing,
		      col_spacing,
			 profile_rows, offsets, tilt, displacement=[0,0,0], keys=false, wells=true,
		      headers=false, footers=false, leftsides=false, rightsides=false,
		      leftwall=false, rightwall=false, topwall=false, bottomwall=false,
			 perimeter=true, narrowsides=false, flatten=true, params=default_layout_placement_params(),
			 wall_matrix, topper=true, wall=true) {
  module placement_helper(row,col) {
    $h = side_gets_spacer(optional_index(headers,row,col), row != 0, perimeter, narrowsides);
    $f = side_gets_spacer(optional_index(footers,row,col), row != optional_index(rows,col)-1, perimeter, narrowsides);
    $r = side_gets_spacer(optional_index(rightsides,row,col), col != 0, perimeter, narrowsides);
    $l = side_gets_spacer(optional_index(leftsides,row,col), col != cols-1, perimeter, narrowsides);

    layout_placement(row=row, col=col, row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows,
		     homerow=homerow, homecol=homecol, tilt=tilt, offsets=offsets, displacement=displacement, flatten=flatten, params=params) children();
  }

  module wall_connector(ij, xy, ij2, xy2, extra_room, extra_room2) {
    let (i1=ij.x, j1=ij.y, x1=xy.x, y1=xy.y,
	 i2=is_undef(ij2) ? i1 : ij2.x, j2=is_undef(ij2) ? j1 : ij2.y,
	 x2=is_undef(xy2) ? x1 : xy2.x, y2=is_undef(xy2) ? y1 : xy2.y,
	 extra_room=is_list(extra_room[0]) ? extra_room : [extra_room],
	 extra_room2=is_undef(extra_room2) ? extra_room : is_list(extra_room2[0]) ? extra_room2 : [extra_room2],
	 last=len(extra_room)-1,
	 last2=len(extra_room2)-1) {
      er_elements = is_list(extra_room[0]) ? len(extra_room) : 0;
      er_elements2 = is_list(extra_room2[0]) ? len(extra_room2) : 0;
      er_topper = extra_room[0];
      er_topper2 = extra_room2[0];
      er_dropper = extra_room[last];
      er_dropper2 = extra_room2[last2];

      if (topper) {
	hull() {
	  placement_helper(i1,j1) key_mount_corner_spheres(x=x1, y=y1, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=er_topper);
	  placement_helper(i2,j2) key_mount_corner_spheres(x=x2, y=y2, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=er_topper2);
	  if (er_topper != [0,0,0]) {
	    placement_helper(i1,j1) key_mount_corner_spheres(x=x1, y=y1, header=$h, footer=$f, leftside=$l, rightside=$r);
	  }
	  if (er_topper2 != [0,0,0] && (ij != ij2 || xy !=xy2)) {
	    placement_helper(i2,j2) key_mount_corner_spheres(x=x2, y=y2, header=$h, footer=$f, leftside=$l, rightside=$r);
	  }
	}

	if(last > 0 || last2 > 0) {
	  //echo(ij, ij2, last, last2);
	  // if extra_room isn't a vector make it one for uniformity so we can alway just index into it
	  //let(er=er_elements == 0 ? [extra_room] : extra_room, er2=er_elements2 == 0 ? [extra_room2] : extra_room2) {
	  for(k=[0:max(last, last2)-1]) {
	    hull() {

	      placement_helper(i1,j1) key_mount_corner_spheres(x=x1, y=y1, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room[k > last ?  last : k]);
	      placement_helper(i1,j1) key_mount_corner_spheres(x=x1, y=y1, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room[k+1 > last ?  last : k+1]);
	      placement_helper(i2,j2) key_mount_corner_spheres(x=x2, y=y2, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room2[k > last2 ? last2 : k]);
	      placement_helper(i2,j2) key_mount_corner_spheres(x=x2, y=y2, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room2[k+1 > last2 ? last2 : k+1]);
	    }

	  }
	}

	if (wall) drop() {
	    placement_helper(i1,j1) key_mount_corner_spheres(x=x1, y=y1, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=er_dropper);
	    placement_helper(i2,j2) key_mount_corner_spheres(x=x2, y=y2, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=er_dropper2);
	  }
      }
    }
  }

  module corner(i,j,x,y, extra_room1=[0,0,0], extra_room2=[0,0,0]) {
    wall_connector(ij=[i,j], xy=[x,y], extra_room=extra_room1,  extra_room2= extra_room2);

    *if (wall) drop() placement_helper(i,j) {
	//sidewall_edge_bounding_box(x=x, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room1);
	//sidewall_edge_bounding_box(x=x, y=y, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room2);
	key_mount_corner_spheres(x=x, y=y, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room1);
	key_mount_corner_spheres(x=x, y=y, width=wall_width(),  header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room2);

      }

    *if (topper) hull() placement_helper(i,j) {
	*sidewall_topper_bounding_box(x=x, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room1);
	*sidewall_topper_bounding_box(x=x, y=y, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room2);
	key_mount_corner_spheres(x=x, y=y, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room1);
	key_mount_corner_spheres(x=x, y=y, width=wall_width(),  header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room2);
      if (extra_room1 != [0,0,0] || extra_room2 != [0,0,0] ) {
	*key_mount_bounding_box(y=y, x=x, header=$h, footer=$f, leftside=$l, rightside=$r);
	key_mount_corner_spheres(x=x, y=y, header=$h, footer=$f, leftside=$l, rightside=$r);
      }
    }
  }

  module old_corner(i,j,x,y, extra_room1=[0,0,0], extra_room2=[0,0,0]) {
    if (wall) drop() placement_helper(i,j) {
      sidewall_edge_bounding_box(x=x, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room1);
      sidewall_edge_bounding_box(x=x, y=y, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room2);
    }

    if (topper) hull() placement_helper(i,j) {
      sidewall_topper_bounding_box(x=x, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room1);
      sidewall_topper_bounding_box(x=x, y=y, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=extra_room2);
    }
  }

  module corner_helper(side) {
    if (side == 0) {
      $x=1;
      $y=1;
      children();
    } else if (side == 1) {
      $x=1;
      $y=-1;
      children();
    } else if (side == 2) {
      $x=-1;
      $y=-1;
      children();
    } else if (side == 3) {
      $x=-1;
      $y=1;
      children();
    }
  }

  module wall_helper(side) {
    if (side == 0) {
      $x=undef;
      $y=1;
      children();
    } else if (side == 1) {
      $x=1;
      $y=undef;
      children();
    } else if (side == 2) {
      $x=undef;
      $y=-1;
      children();
    } else if (side == 3) {
      $x=-1;
      $y=undef;
      children();
    }
  }


  if(!is_undef(wall_matrix)) {
    for (j=[0:cols-1]) {
      row_count = optional_index(rows,j);
      for (i=[0:row_count-1]) {
	if(is_list(wall_matrix[j][i]) && [] != wall_matrix[j][i]) {

	    max_side = len(wall_matrix[j][i])-1;
	    for(side_idx=[0:max_side]) {
	      side = wall_matrix[j][i][side_idx][0];
	      side_extra_room = wall_matrix[j][i][side_idx][1];

	      neighbors =search((side+1)%4,wall_matrix[j][i], 0, 0);
	      if (0 < len(neighbors)) {
		corner_extra_room = wall_matrix[j][i][neighbors[0]][1];

		corner_helper(side) wall_connector(ij=[i, j], xy=[$x, $y], //corner(i,j,x=$x,y=$y,
					   extra_room = side % 2 == 0 ? side_extra_room : corner_extra_room,
					   extra_room2 = side % 2 == 1 ? side_extra_room : corner_extra_room);


	      }

	      wall_helper(side) let(er=is_list(side_extra_room[0]) ? side_extra_room : [side_extra_room], last=len(er)-1) {
		if (topper) {//if (side_extra_room != [0,0,0]) {
		  placement_helper(i,j) hull() {
		    //sidewall_topper(x=is_undef($x) ? 0 : $x, y=is_undef($y) ? 0 : $y, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=side_extra_room);
		    //key_mount_bounding_box(y=$y, x=$x, header=$h, footer=$f, leftside=$l, rightside=$r);
		    if (er[0] != [0,0,0])
		      key_mount_corner_spheres(x=$x, y=$y, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=er[0]);
		    key_mount_corner_spheres(x=$x, y=$y, header=$h, footer=$f, leftside=$l, rightside=$r);

		  }

		  if ( last > 0 ) {
		    for(k=[0:last-1]) {
		      placement_helper(i,j) hull() {
			key_mount_corner_spheres(x=$x, y=$y, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=er[k]);
			key_mount_corner_spheres(x=$x, y=$y, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=er[k+1]);
		      }
		    }
		  }
		}

		if (wall) drop() placement_helper(i,j)
			    //sidewall_bounding_box(leftwall=($x == -1), rightwall=($x == 1), bottomwall=($y == -1), topwall=($y == 1), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=side_extra_room);
			    key_mount_corner_spheres(x=$x, y=$y, width=wall_width(), header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=er[last]);

	      }
		  //} else {
		  //placement_helper(i,j) wall_helper(side) sidewall_topper(x=is_undef($x) ? 0 : $x, y=is_undef($y) ? 0 : $y, header=$h, footer=$f, leftside=$l, rightside=$r, extra_room=side_extra_room);
		  //}

	      // connecter sidewalls
	      wall_helper(side) {
		if (!is_undef($x) && i < row_count-1 && is_list(wall_matrix[j][i+1]) && [] != wall_matrix[j][i+1] ) {
		  neighbors = search(side,wall_matrix[j][i+1], 0, 0);
		  if(0 != len(neighbors)) {
		    next_idx = neighbors[0];
		    next_extra_room = wall_matrix[j][i+1][next_idx][1];
		    wall_connector(ij=[i,j], xy=[$x,-1], ij2=[i+1,j], xy2=[$x,1], extra_room=side_extra_room, extra_room2=next_extra_room);
		  }
		}

		if (j < cols-1) {
		  get_homes(params, homerow, homecol, j)
		    let(next_homerow=get_homerow(params, homerow, j+1),
			next_row_count=optional_index(rows, j+1),
			row_offset=(next_homerow - $homerow),
			next_i=i+row_offset,
			next_j=j+1) {

		    next_i_valid      = 0 <= next_i   && next_i   < next_row_count;
		    next_corner_valid = 0 <= next_i+1 && next_i+1 < next_row_count;
		    next_upper_corner_valid = 0 <= next_i-1 && next_i-1 < next_row_count;

		    if (!is_undef($y) && next_i_valid) {
		      next_wall = wall_matrix[j+1][next_i];
		      if(is_list(next_wall) && [] != next_wall) {
			neighbors = search(side,next_wall, 0, 0);
			if(0 != len(neighbors)) {
			  next_idx = neighbors[0];
			  next_extra_room = next_wall[next_idx][1];

			  wall_connector(ij=[i,j], xy=[-1, $y], ij2=[next_i, j+1], xy2=[1, $y], extra_room=side_extra_room, extra_room2=next_extra_room);
			}
		      }
		    }

		    // XXX: consolidate these 4 cases somehow?
		    if(next_upper_corner_valid && side == 0){
		      next_wall = wall_matrix[next_j][next_i-1];
		      if(is_list(next_wall) && [] != next_wall) {
			neighbors = search((side+1)%4,next_wall, 0, 0);
			if(0 != len(neighbors)) {
			  next_idx = neighbors[0];
			  next_extra_room = next_wall[next_idx][1];

			  wall_connector(ij=[i,j], xy=[-1, 1], ij2=[next_i-1, next_j], xy2=[1, -1], extra_room=side_extra_room, extra_room2=next_extra_room);
			}
		      }
		    }

		    if(next_upper_corner_valid && side == 3){
		      next_wall = wall_matrix[next_j][next_i-1];
		      if(is_list(next_wall) && [] != next_wall) {
			neighbors = search((side-1)%4,next_wall, 0, 0);
			if(0 != len(neighbors)) {
			  next_idx = neighbors[0];
			  next_extra_room = next_wall[next_idx][1];

			  wall_connector(ij=[i,j], xy=[-1, 1], ij2=[next_i-1, next_j], xy2=[1, -1], extra_room=side_extra_room, extra_room2=next_extra_room);
			}
		      }
		    }

		    if(next_corner_valid && side == 2){
		      next_wall = wall_matrix[next_j][next_i+1];
		      if(is_list(next_wall) && [] != next_wall) {
			neighbors = search((side-1)%4,next_wall, 0, 0);
			if(0 != len(neighbors)) {
			  next_idx = neighbors[0];
			  next_extra_room = next_wall[next_idx][1];

			  wall_connector(ij=[i,j], xy=[-1, -1], ij2=[next_i+1, next_j], xy2=[1, 1], extra_room=side_extra_room, extra_room2=next_extra_room);
			}
		      }
		    }

		    if(next_corner_valid && side == 3){
		      next_wall = wall_matrix[next_j][next_i+1];
		      if(is_list(next_wall) && [] != next_wall) {
			neighbors = search((side+1)%4,next_wall, 0, 0);
			if(0 != len(neighbors)) {
			  next_idx = neighbors[0];
			  next_extra_room = next_wall[next_idx][1];

			  wall_connector(ij=[i,j], xy=[-1, -1], ij2=[next_i+1, next_j], xy2=[1, 1], extra_room=side_extra_room, extra_room2=next_extra_room);
			}
		      }
		    }
		  }
		}
	      }
	    }
	}
      }
    }
  } else {
    x_walls = create_direction_vector([[rightwall, 1], [leftwall, -1]]);
    y_walls = create_direction_vector([[topwall, 1], [bottomwall, -1]]);

    // corners
    *for (x=x_walls) {
      for (y=y_walls) {
	j = x == 1 ? 0 : cols -1;
	row_count = optional_index(rows,j);
	i = y == 1 ? 0 : row_count -1;

	corner(i,j,x,y);
      }
    }
    //for (j=[0,cols-1]) {
    //row_count = optional_index(rows,j);
    //for (i=[0,row_count-1]) {

    if (optional_index(rightwall,0,0) && optional_index(topwall,0,0)) {
      old_corner(0,0,x=1,y=1);
    }

    let (j=0, i=optional_index(rows,j)-1) {
      if (optional_index(rightwall,i,0) && optional_index(bottomwall,0,i)) {
	old_corner(i,0,x=1,y=-1);
      }
    }

    let (i=0, j=cols-1) {
      if (optional_index(leftwall,i,j) && optional_index(topwall,j,i)) {
	old_corner(i,j,x=-1,y=1);
      }
    }
    let (j =cols-1, i = optional_index(rows,j)-1) {
      if (optional_index(leftwall,i,j) && optional_index(bottomwall,j,i)) {
	old_corner(i,j,x=-1,y=-1);
      }
    }

    // iterate key_mounts on perimeter columns
    for (x=x_walls) {
      j = x == 1 ? 0 : cols -1;
      row_count = optional_index(rows,j);
      for (i=[0:optional_index(row_count,j)-1]) {

	// key_mount sidewalls
	drop() placement_helper(i,j)
	  sidewall_bounding_box(leftwall=(x == -1), rightwall=(x == 1), header=$h, footer=$f, leftside=$l, rightside=$r);
	placement_helper(i,j) sidewall_topper(x=x, header=$h, footer=$f, leftside=$l, rightside=$r);

	// connecter sidewalls
	if (i != row_count-1) {
	  drop() {
	    placement_helper(i,j) sidewall_edge_bounding_box(x=x, y=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
	    placement_helper(i+1,j) sidewall_edge_bounding_box(x=x, y=1, header=$h, footer=$f, leftside=$l, rightside=$r);
	  }

	  hull() {
	    placement_helper(i,j) sidewall_topper_bounding_box(x=x, y=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
	    placement_helper(i+1,j) sidewall_topper_bounding_box(x=x, y=1, header=$h, footer=$f, leftside=$l, rightside=$r);
	  }
	}
      }
    }

    // iterate key_mounts on perimeter rows
    for (y=y_walls) {
      for (j=[0:cols-1]) {
	row_count = optional_index(rows,j);
	i = y == 1 ? 0 : row_count -1;

	// key_mount sidewalls
	drop() placement_helper(i,j)
	  sidewall_bounding_box(bottomwall=(y == -1), topwall=(y == 1), header=$h, footer=$f, leftside=$l, rightside=$r);
	placement_helper(i,j) sidewall_topper(y=y, header=$h, footer=$f, leftside=$l, rightside=$r);

	// connecter sidewalls
	if (j < cols-1) {
	  drop() {
	    placement_helper(i,j) sidewall_edge_bounding_box(x=-1, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r);
	    placement_helper(i,j+1) sidewall_edge_bounding_box(x=1, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r);
	  }

	  hull() {
	    placement_helper(i,j) sidewall_topper_bounding_box(x=-1, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r);
	    placement_helper(i,j+1) sidewall_topper_bounding_box(x=1, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r);
	  }
	}
      }
    }
  }
}

/*module layout_columns_only(rows=4, cols=1, homerow=2, row_spacing=create_flat_placement(outerdia()+2*spacer()),
		      col_spacing=create_flat_placement(outerdia()+spacer()),
		      profile_rows=effective_rows(), keys=false, wells=true,
		      headers=false, footers=false, leftsides=false, rightsides=false,
		      leftwall=false, rightwall=false, topwall=false, bottomwall=false,
		      perimeter=true, narrowsides=false, tilt=[0,0,0], flatten=true) {
  module placement_helper(row,col) {
    effective_row = optional_index(profile_rows, row, col);

    rotate([0,optional_vector_index(tilt, col, row).y,0]) rotate([optional_vector_index(tilt, col, row).x,0,0])
      place_row(row,col,row_spacing,homerow=homerow)
      place_col(row,col,col_spacing)
      if(flatten) {
	position_flat(effective_row) children();
      } else {
	children();
      }
  }

  for (j=[0:cols-1]) {
    for (i=[0:rows-1]) {
      effective_row = optional_index(profile_rows, i, j);
      if (keys) {
	placement_helper(i,j) keycap(effective_row);
      }

      if (wells) {
	h = side_gets_spacer(headers, i != 0, perimeter, narrowsides);
	f = side_gets_spacer(footers, i != rows-1, perimeter, narrowsides);
	r = side_gets_spacer(rightsides, j != 0, perimeter, narrowsides);
	l = side_gets_spacer(leftsides, j != cols-1, perimeter, narrowsides);

	// well
	placement_helper(i,j) key_mount(header=h, footer=f, leftside=l, rightside=r);

	// sidewalls
	if (leftwall && j == cols-1) {
	  drop() placement_helper(i,j)
	    sidewall_bounding_box(leftwall=leftwall, header=h, footer=f, leftside=l, rightside=r);
	  placement_helper(i,j) sidewall_topper(x=-1, header=h, footer=f, leftside=l, rightside=r);
	}

	if (rightwall && j == 0) {
	  drop() placement_helper(i,j)
	    sidewall_bounding_box(rightwall=rightwall, header=h, footer=f, leftside=l, rightside=r);
	  placement_helper(i,j) sidewall_topper(x=1, header=h, footer=f, leftside=l, rightside=r);
	}

	if (topwall && i == 0 ) {
	  drop() placement_helper(i,j)
	    sidewall_bounding_box(topwall=topwall, header=h, footer=f, leftside=l, rightside=r);
	  placement_helper(i,j) sidewall_topper(y=1, header=h, footer=f, leftside=l, rightside=r);

	  if (j == 0 && rightwall) {
	    drop() {
	      placement_helper(i,j) sidewall_edge_bounding_box(x=1, y=1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j) sidewall_edge_bounding_box(x=1, y=1, header=h, footer=f, leftside=l, rightside=r);
	    }
	    hull() {
	      placement_helper(i,j) sidewall_topper_bounding_box(x=1,y=1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j) sidewall_topper_bounding_box(x=1,y=1, header=h, footer=f, leftside=l, rightside=r);
	    }
	  }
	  if (j == cols-1 && leftwall) {
	    drop() {
	      placement_helper(i,j) sidewall_edge_bounding_box(x=-1, y=1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j) sidewall_edge_bounding_box(x=-1, y=1, header=h, footer=f, leftside=l, rightside=r);
	    }
	    hull() {
	      placement_helper(i,j) sidewall_topper_bounding_box(x=-1,y=1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j) sidewall_topper_bounding_box(x=-1,y=1, header=h, footer=f, leftside=l, rightside=r);
	    }
	  } else if (j < cols-1) {
	    drop() {
	      placement_helper(i,j) sidewall_edge_bounding_box(x=-1, y=1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j+1) sidewall_edge_bounding_box(x=1, y=1, x_aligned=false, header=h, footer=f, leftside=leftsides, rightside=rightsides);
	    }
	    hull() {
	      placement_helper(i,j) sidewall_topper_bounding_box(x=-1,y=1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j+1) sidewall_topper_bounding_box(x=1,y=1, x_aligned=false, header=h, footer=f, leftside=leftsides, rightside=rightsides);
	    }
	  }
	}

	if (bottomwall && i == rows-1 ) {
	  drop() placement_helper(i,j)
	    sidewall_bounding_box(bottomwall=bottomwall, header=h, footer=f, leftside=l, rightside=r);
	  placement_helper(i,j) sidewall_topper(y=-1, header=h, footer=f, leftside=l, rightside=r);

	 if (j == 0 && rightwall) {
	    drop() {
	      placement_helper(i,j) sidewall_edge_bounding_box(x=1, y=-1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j) sidewall_edge_bounding_box(x=1, y=-1, header=h, footer=f, leftside=l, rightside=r);
	    }
	    hull(){
	      placement_helper(i,j) sidewall_topper_bounding_box(x=1, y=-1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j) sidewall_topper_bounding_box(x=1, y=-1, header=h, footer=f, leftside=l, rightside=r);
	    }
	  }
	  if (j == cols-1 && leftwall) {
	    drop() {
	      placement_helper(i,j) sidewall_edge_bounding_box(x=-1, y=-1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j) sidewall_edge_bounding_box(x=-1, y=-1, header=h, footer=f, leftside=l, rightside=r);
	    }
	    hull() {
	      placement_helper(i,j) sidewall_topper_bounding_box(x=-1, y=-1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j) sidewall_topper_bounding_box(x=-1, y=-1, header=h, footer=f, leftside=l, rightside=r);
	    }
	  } else if (j < cols-1) {
	    drop() {
	      placement_helper(i,j) sidewall_edge_bounding_box(x=-1, y=-1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j+1) sidewall_edge_bounding_box(x=1, y=-1, x_aligned=false, header=h, footer=f, leftside=leftsides, rightside=rightsides);
	    }
	    hull() {
	      placement_helper(i,j) sidewall_topper_bounding_box(x=-1, y=-1, x_aligned=false, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i,j+1) sidewall_topper_bounding_box(x=1, y=-1, x_aligned=false, header=h, footer=f, leftside=leftsides, rightside=rightsides);
	    }
	  }
	}

	//connect rows
	if (i < rows-1) {
	  hull() {
	    placement_helper(i,j) key_mount_side_bounding_box(y=-1, header=h, footer=f, leftside=l, rightside=r);
	    placement_helper(i+1,j) key_mount_side_bounding_box(y=1, header=headers, footer=footers, leftside=l, rightside=r);
	  }

	  // connecter sidewalls
	  if (leftwall && j == cols-1) {
	    drop() {
	      placement_helper(i,j) sidewall_edge_bounding_box(x=-1,y=-1,header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i+1,j) sidewall_edge_bounding_box(x=-1,y=1,header=headers, footer=footers, leftside=l, rightside=r);
	    }
	    hull() {
	      placement_helper(i,j) sidewall_topper_bounding_box(x=-1,y=-1,header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i+1,j) sidewall_topper_bounding_box(x=-1,y=1,header=headers, footer=footers, leftside=l, rightside=r);
	    }
	  }
	  if (rightwall && j == 0) {
	    drop() {
	      placement_helper(i,j) sidewall_edge_bounding_box(x=1,y=-1,header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i+1,j) sidewall_edge_bounding_box(x=1,y=1,header=headers, footer=footers, leftside=l, rightside=r);
	    }

	    hull() {
	      placement_helper(i,j) sidewall_topper_bounding_box(x=1,y=-1,header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i+1,j) sidewall_topper_bounding_box(x=1,y=1,header=headers, footer=footers, leftside=l, rightside=r);
	    }
	  }
	}

	//connect cols
	if (j < cols-1) {
	  hull() {
	    placement_helper(i,j) key_mount_side_bounding_box(x=-1, header=h, footer=f, leftside=l, rightside=r);
	    placement_helper(i,j+1) key_mount_side_bounding_box(x=1, header=h, footer=f, leftside=leftsides, rightside=rightsides);
	  }

	  //connect connectors
	  if (i < rows-1) {
	    hull() {
	      placement_helper(i,j) key_mount_corner_bounding_box(x=-1, y=-1, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i+1,j) key_mount_corner_bounding_box(x=-1, y=1,header=headers, footer=footers, leftside=l, rightside=r);
	      placement_helper(i,j+1) key_mount_corner_bounding_box(x=1, y=-1, header=h, footer=f, leftside=leftsides, rightside=rightsides);
	      placement_helper(i+1,j+1) key_mount_corner_bounding_box(x=1, y=1,header=headers, footer=footers, leftside=leftsides, rightside=rightsides);
	    }
	  }
	}
      }
    }
  }
}
*/
