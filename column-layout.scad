/* a flat column. not really a dactyl but someone may like it.
 *  also a good starting place for understanding other columns,
 *  and useful for validating profiles' position_flat() funcitons with the flat_tester()
 */


include <settings.scad>;
use <keywell.scad>;
use <keycap.scad>;
use <column-util.scad>;
use <trackpoint.scad>;
use <util.scad>;

module layout_columns(rows=4, cols=1, homerow, homecol, row_spacing,
		      col_spacing,

		      profile_rows, offsets, tilt, displacement=[0,0,0], keys=false, wells=true,
		      headers=false, footers=false, leftsides=false, rightsides=false,
		      leftwall=false, rightwall=false, topwall=false, bottomwall=false,
		      perimeter=true, narrowsides=false, flatten=true,
		      reverse_triangles=false,
		      params=default_layout_placement_params()) {
  layout_plate_only(rows=rows, cols=cols, homerow=homerow, homecol=homecol,row_spacing=row_spacing,
		    col_spacing=col_spacing,
		    profile_rows=profile_rows, offsets=offsets, tilt=tilt, displacement=displacement, keys=keys, wells=wells,
		    headers=headers, footers=footers, leftsides=leftsides, rightsides=rightsides,
		    leftwall=leftwall, rightwall=rightwall, topwall=topwall, bottomwall=bottomwall,
		    perimeter=perimeter, narrowsides=narrowsides, flatten=flatten,
		    reverse_triangles=reverse_triangles,
		    params=params);

  if (wells) {
    layout_walls_only(rows=rows, cols=cols, homerow=homerow, homecol=homecol, row_spacing=row_spacing,
		      col_spacing=col_spacing,
		      profile_rows=profile_rows, offsets=offsets, tilt=tilt, displacement=displacement, keys=keys, wells=wells,
		      headers=headers, footers=footers, leftsides=leftsides, rightsides=rightsides,
		      leftwall=leftwall, rightwall=rightwall, topwall=topwall, bottomwall=bottomwall,
		      perimeter=perimeter, narrowsides=narrowsides, flatten=flatten, params=params);
  }
}

function side_gets_spacer(spacer, has_neighbor, perimeter, force_underhang) =
  (spacer || (perimeter && !has_neighbor)) && !(force_underhang && !has_neighbor);

module layout_plate_only(rows=4, cols=1, homerow, homecol, row_spacing,
			 col_spacing,
			 profile_rows, offsets, tilt, displacement=[0,0,0], keys=false, wells=true,
			 headers=false, footers=false, leftsides=false, rightsides=false,
			 leftwall=false, rightwall=false, topwall=false, bottomwall=false,
			 perimeter=true, narrowsides=false, flatten=true,
			 reverse_triangles=false,
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

  // used to join keywells so they form a solid plate
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
	  placement_helper(this) keywell_bounding_box(y=-1, x=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
	if (!is_undef(left))
	  placement_helper(left) keywell_bounding_box(y=-1, x=1, header=$h, footer=$f, leftside=$l, rightside=$r);
	if (!is_undef(down))
	  placement_helper(down) keywell_bounding_box(y=1, x=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
	if (!is_undef(corner))
	  placement_helper(corner) keywell_bounding_box(y=1, x=1, header=$h, footer=$f, leftside=$l, rightside=$r);
      }
    }

    //for figuring out how many unique keywells we are joining
    function count_def(test) = is_undef(test) ? 0 : 1;

    num_wells = count_def(this) + count_def(left) + count_def(down) + count_def(corner);

    // of there is only one well we aren't joining anything
    assert(num_wells > 1);

    // for 3 wells, just do what the caller says, otherwise we need to split  the quadralateral into 2 triangles
    if (num_wells == 3) {
      hull_corners(this, left, down, corner);
    } else {

      /* this is a trick to handle joining 2 keywells along a row or column the same as joining the intersection
       * of 4 keywells. To connect 2 wells in the same column, left is mappe onto 'this' and corner onto down.
       * To connect 2 wells in the same row, down is mapped onto 'this' and corner onto left.  this reverses the ordering
       * so the reverse bollean is needed to correct this.
       */
      let (corner = is_undef(corner) ? (is_undef(left) ? down : left) : corner,
	   left = is_undef(left) ? this : left,
	   down = is_undef(down) ? this : down) {

	/* this is our heuristic for producing concave hulls (which are desireable because they are less likely
	 *  to protrude from the plate and interfere with keycap travel) by using 2 triangular convex hulls of the
	 *  corners of keywells, instead of a single convex hull of all 4 corners,
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

  for (j=[0:cols-1]) {
    row_count = optional_index(rows,j);
    for (i=[0:row_count-1]) {
      if (optional_index(keys, j, i)) {
	placement_helper(i,j) keycap($effective_row);
      }

      if (wells) get_homes(params, homerow, homecol, j) let(homerow=$homerow, homecol=$homecol){
	// well
	placement_helper(i,j) keywell(header=$h, footer=$f, leftside=$l, rightside=$r);
	if ($preview) placement_helper(i,j) hotswap();

	//connect rows
	if (i < row_count-1) {
	  connect([i,j], down=[i+1,j]);
	}

	// XXX get row offset working, also handle corner connect when next column is longer than this one
	//                               (maybe connect bottom to side as well?)

	//connect cols
	if (j < cols-1 &&                    // not the last column
	    i < optional_index(rows, j+1)) { // next column is as long as this one
	  row_offset = 0;//optional_index(homerow, j+1) - optional_index(homerow, j);
	  if ((i + row_offset) >= 0) {
	    connect([i,j], left=[i+row_offset, j+1]);

	    //connect connectors
	    if (i < row_count-1 && i < optional_index(rows, j+1) /*+ row_offset*/) {
	      connect([i,j], down=[i+1,j], left=[i+row_offset,j+1],
		      corner=(i < optional_index(rows, j+1)-1) ? [i+row_offset+1,j+1] : undef);

	    }
	  }
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
			 perimeter=true, narrowsides=false, flatten=true, params=default_layout_placement_params()) {
  module placement_helper(row,col) {
    $h = side_gets_spacer(headers, row != 0, perimeter, narrowsides);
    $f = side_gets_spacer(footers, row != optional_index(rows,col)-1, perimeter, narrowsides);
    $r = side_gets_spacer(rightsides, col != 0, perimeter, narrowsides);
    $l = side_gets_spacer(leftsides, col != cols-1, perimeter, narrowsides);

    layout_placement(row=row, col=col, row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows,
		     homerow=homerow, homecol=homecol, tilt=tilt, offsets=offsets, displacement=displacement, flatten=flatten, params=params) children();
  }

  x_walls = create_direction_vector([[rightwall, 1], [leftwall, -1]]);
  y_walls = create_direction_vector([[topwall, 1], [bottomwall, -1]]);

  // corners
  for (x=x_walls) {
    for (y=y_walls) {
      j = x == 1 ? 0 : cols -1;
      row_count = optional_index(rows,j);
      i = y == 1 ? 0 : row_count -1;

      drop() placement_helper(i,j) {
	sidewall_edge_bounding_box(x=x, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r);
	sidewall_edge_bounding_box(x=x, y=y, header=$h, footer=$f, leftside=$l, rightside=$r);
      }

      hull() placement_helper(i,j) {
	sidewall_topper_bounding_box(x=x, y=y, x_aligned=false, header=$h, footer=$f, leftside=$l, rightside=$r);
	sidewall_topper_bounding_box(x=x, y=y, header=$h, footer=$f, leftside=$l, rightside=$r);
      }
    }
  }

  // iterate keywells on perimeter columns
  for (x=x_walls) {
    j = x == 1 ? 0 : cols -1;
    row_count = optional_index(rows,j);
    for (i=[0:optional_index(row_count,j)-1]) {

      // keywell sidewalls
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

  // iterate keywells on perimeter rows
  for (y=y_walls) {
    for (j=[0:cols-1]) {
      row_count = optional_index(rows,j);
      i = y == 1 ? 0 : row_count -1;

      // keywell sidewalls
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


/*module layout_columns_only(rows=4, cols=1, homerow=2, row_spacing=create_flat_placement(outerdia+2*spacer()),
		      col_spacing=create_flat_placement(outerdia+spacer()),
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
	placement_helper(i,j) keywell(header=h, footer=f, leftside=l, rightside=r);

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
	    placement_helper(i,j) keywell_side_bounding_box(y=-1, header=h, footer=f, leftside=l, rightside=r);
	    placement_helper(i+1,j) keywell_side_bounding_box(y=1, header=headers, footer=footers, leftside=l, rightside=r);
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
	    placement_helper(i,j) keywell_side_bounding_box(x=-1, header=h, footer=f, leftside=l, rightside=r);
	    placement_helper(i,j+1) keywell_side_bounding_box(x=1, header=h, footer=f, leftside=leftsides, rightside=rightsides);
	  }

	  //connect connectors
	  if (i < rows-1) {
	    hull() {
	      placement_helper(i,j) keywell_corner_bounding_box(x=-1, y=-1, header=h, footer=f, leftside=l, rightside=r);
	      placement_helper(i+1,j) keywell_corner_bounding_box(x=-1, y=1,header=headers, footer=footers, leftside=l, rightside=r);
	      placement_helper(i,j+1) keywell_corner_bounding_box(x=1, y=-1, header=h, footer=f, leftside=leftsides, rightside=rightsides);
	      placement_helper(i+1,j+1) keywell_corner_bounding_box(x=1, y=1,header=headers, footer=footers, leftside=leftsides, rightside=rightsides);
	    }
	  }
	}
      }
    }
  }
}
*/
