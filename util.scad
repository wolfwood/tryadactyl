// utility functions

// makes a number of clones of a supbtreem/ rotated and spaced evenly around the origin
module rotational_clone(clones=2) {
  for(i=[0:clones-1] ) {
    rotate([0,0,i * (360/clones)]) children();
  }
}

/* one take on 'loft' - takes pairs of bounding boxes and then the model as the final child.
 *  joins the parts of the model within the bounding pairs, ideally connecting convex surfaces,
 *  while preserving the concavity of the model */
module bounded_hull() {
  end=$children-1;
  union() {
    children(end);
    for(i=[0:2:end-1-(end%2)]) {
      difference() {
	hull() {
	  intersection() {
	    children(end);
	    children(i);
	  }
	  intersection() {
	    children(end);
	    children(i+1);
	  }
	}
	hull() intersection() {
	  children(end);
	  children(i);
	}
	hull() intersection() {
	  children(end);
	  children(i+1);
	}
      }
    }
  }
}

/* similar to bounded hull, but instead of taking pairs of bounds, connects all the bounds in sequence,
 *  wrapping at the end, to make a hamiltonian circuit. */
module bounded_hull_circuit() {
  function nextwrap(i) = i+1 == $children-1 ? 0 : i+1;
  end=$children-1;
  union() {
    children(end);
    for(i=[0:end-1]) {
      difference() {
	hull() {
	  intersection() {
	    children(end);
	    children(i);
	  }
	  intersection() {
	    children(end);
	    children(nextwrap(i));
	  }
	}
	hull() intersection() {
	  children(end);
	  children(i);
	}
	hull() intersection() {
	  children(end);
	  children(nextwrap(i));
	}
      }
    }
  }
}

/* similar to bounded hull, but takes an array of vectors, each of which specifies 2 or more
 *  bounding boxes to be connected. can be upsed with pairs similarly to bounded_hull, but without
 *  having to potentially duplicate bounding boxes, or in a more free-form manner to build a
 *  non-convex hull out of convex subsets of bounds.
 */
module bounded_hull_stipulated(sets=[]) {
  end=$children-1;
  union() {
    children(end);
    for(set=sets){
      difference() {
	hull() intersection() {
	  children(end);
	  children(set);
	}
	for(i=set) {
	  hull() intersection() {
	    children(end);
	    children(i);
	  }
	}
      }
    }
    /*for(i=pair) {
      difference() {
	hull() {
	  intersection() {
	    children(end);
	    children(i[0]);
	  }
	  intersection() {
	    children(end);
	    children(i[1]);
	  }
	}
	hull() intersection() {
	  children(end);
	  children(i[0]);
	}
	hull() intersection() {
	  children(end);
	  children(i[1]);
	}
      }
      }*/
  }
}

// adds a mount for a cup magnet at a given position
module magnetize(position=[0,0,0], cut_height=9, post_height=12) {
  union() {
    difference() {
      /* idk why you would call this on a set of objects since there is only one position, but just
       *  in case union the children because otherwise the difference will subtract the subsequent
       *  children from the first one
       */
      union(){
        children();
      }

      /* a loose fitting hole for the magnet, bringing it is closer to the work surface (force is
       *  proportional to the square of distance), maybe also provides some support when moving laterally
       */
      translate(position) cylinder(cut_height,d=33,$fn=64);
    }
    // change diameter if you need to accomodate a different screw size
    translate(position) cylinder(post_height,d=3.5,$fn=64);
  }
}
