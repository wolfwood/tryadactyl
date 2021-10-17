/* a flat column. not really a dactyl but someone may like it.
 *  also a good starting place for understanding other columns,
 *  and useful for validating profiles' position_flat() funcitons with the flat_tester()
 */


include <settings.scad>;
use <keywell.scad>;
use <keycap.scad>;
use <column-util.scad>;
use <trackpoint.scad>;


module layout_columns(rows=4, cols=1, homerow, homecol, row_spacing,
		      col_spacing,

		      profile_rows, offsets, tilt, displacement=[0,0,0], keys=false, wells=true,
		      headers=false, footers=false, leftsides=false, rightsides=false,
		      leftwall=false, rightwall=false, topwall=false, bottomwall=false,
		      perimeter=true, narrowsides=false, flatten=true, params=default_layout_placement_params()) {
  layout_plate_only(rows=rows, cols=cols, homerow=homerow, homecol=homecol,row_spacing=row_spacing,
		    col_spacing=col_spacing,
		    profile_rows=profile_rows, offsets=offsets, tilt=tilt, displacement=displacement, keys=keys, wells=wells,
		    headers=headers, footers=footers, leftsides=leftsides, rightsides=rightsides,
		    leftwall=leftwall, rightwall=rightwall, topwall=topwall, bottomwall=bottomwall,
		    perimeter=perimeter, narrowsides=narrowsides, flatten=flatten, params=params);

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
			 perimeter=true, narrowsides=false, flatten=true, params=default_layout_placement_params()) {
  module placement_helper(row,col) {
    $h = side_gets_spacer(headers, row != 0, perimeter, narrowsides);
    $f = side_gets_spacer(footers, row != optional_index(rows, col)-1, perimeter, narrowsides);
    $r = side_gets_spacer(rightsides, col != 0, perimeter, narrowsides);
    $l = side_gets_spacer(leftsides, col != cols-1, perimeter, narrowsides);

    layout_placement(row=row, col=col, row_spacing=row_spacing, col_spacing=col_spacing, profile_rows=profile_rows,
		     homerow=homerow, homecol=homecol, tilt=tilt, offsets=offsets, displacement=displacement, flatten=flatten, params=params) children();
  }

  for (j=[0:cols-1]) {
    row_count = optional_index(rows,j);
    for (i=[0:row_count-1]) {
      if (optional_index(keys, j, i)) {
	placement_helper(i,j) keycap($effective_row);
      }

      if (wells) {
	// well
	placement_helper(i,j) keywell(header=$h, footer=$f, leftside=$l, rightside=$r);

	//connect rows
	if (i < row_count-1) {
	  hull() {
	    placement_helper(i,j) keywell_side_bounding_box(y=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
	    placement_helper(i+1,j) keywell_side_bounding_box(y=1, header=$h, footer=$f, leftside=$l, rightside=$r);
	  }
	}

	//connect cols
	if (j < cols-1 &&
	    i < optional_index(rows, j+1)) { // next row is as long as this one
	  row_offset = 0;//optional_index(homerow, j+1) - optional_index(homerow, j);
	  if ((i + row_offset) >= 0) {
	    hull() {
	      placement_helper(i,j) keywell_side_bounding_box(x=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
	      placement_helper(i+row_offset, j+1) keywell_side_bounding_box(x=1, header=$h, footer=$f, leftside=$l, rightside=$r);
	    }

	    //connect connectors
	    if (i < row_count-1 && i < optional_index(rows, j+1) /*+ row_offset*/) {
	      hull() {
		placement_helper(i,j) keywell_corner_bounding_box(x=-1, y=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
		placement_helper(i+1,j) keywell_corner_bounding_box(x=-1, y=1, header=$h, footer=$f, leftside=$l, rightside=$r);
		placement_helper(i+row_offset,j+1) keywell_corner_bounding_box(x=1, y=-1, header=$h, footer=$f, leftside=$l, rightside=$r);
		if (i < optional_index(rows, j+1)-1) {
		  placement_helper(i+row_offset+1,j+1) keywell_corner_bounding_box(x=1, y=1, header=$h, footer=$f, leftside=$l, rightside=$r);
		}
	      }
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
