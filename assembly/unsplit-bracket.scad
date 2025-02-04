use <../settings.scad>;
use <../util.scad>;

module symdup(v) {
  children();
  mirror(v) children();
}

module countersunk_screwhole_hexnut(pos=[0,0,0], a=[0,-90,0], head_thickness=wall_width(), screw_len = 10, extra_len=5, nut_thickness=2.3, countersunk=true, screw_d=3, head_d=5.8, nut_d=6.2, slop = .2) {
  d=screw_d+slop;
  h= screw_len+extra_len;
  nut_depth=screw_len-head_thickness-nut_thickness - slop;

  $fn=60;

  translate(pos) rotate (a) {
    translate([0,0,-head_thickness]) {
      // screw holes
      cylinder(d=d,h=h);

      // cones for countersink
      if (countersunk)
        cylinder(d1=head_d+slop,h=(head_d+slop)/2);
    }

    // nut holes
    rotate([0,0,90]) translate([0,0,nut_depth]) cylinder($fn=6, d=nut_d+slop, h=h-nut_depth-head_thickness);
  }
}

module countersunk_screwhole_squarenut(pos=[0,0,0], a=[0,0,0], head_thickness=wall_width(), screw_len = 10, extra_len=1, nut_thickness=2.25, countersunk=true, screw_d=3, head_d=5.8, nut_d=5.6, slop = .2) {
  d=screw_d+slop;
  h= screw_len+extra_len;
  nut_depth=screw_len-head_thickness - slop;

  $fn=60;

  translate(pos) rotate ([0,-90,0]) translate([0,0,-head_thickness]) {
    // screw holes
    cylinder(d=d,h=h);

    // cones for countersink
    if (countersunk)
      cylinder(d1=head_d+slop,h=(head_d+slop)/2);
  }

  // square nut holes
  translate(pos) let(x=nut_thickness+slop, y=nut_d+slop,z=20) {
      rotate(a)
      translate([-nut_depth, -y/2, -y/2])
      cube([x, y, z]);
  }
}


//unibracket();

module holes(pos=[0,0,0], head_thickness=wall_width(), screw_len = 10, extra_len=5, nut_thickness=2.3, countersunk=true, screw_d=3, head_d=5.8, nut_d=6.2, slop = .2) {
  d=screw_d+slop;
  h= screw_len+extra_len;
  nut_depth=screw_len-head_thickness-nut_thickness - slop;

  $fn=60;

  positions = [[1,19,1], [0,0,0], [-1,-26,0]];

  translate(pos) rotate ([0,-90,0]) translate([0,0,-head_thickness]) {
    // screw holes
    for (i = positions)
      translate(i) cylinder(d=d,h=h);

    // cones for countersink
    if (countersunk)
      for (i = [0:2])
        translate([positions[i].z, positions[i].y, 0]) cylinder(d1=head_d+slop,h=(head_d+slop)/2);
  }

  // nut holes
  translate(pos) rotate ([0,-90,0]) {
    for (i = positions)
      translate(i) rotate([0,0,90]) translate([0,0,nut_depth]) cylinder($fn=6, d=nut_d+slop, h=h-nut_depth-head_thickness);
  }
}


module better_holes(pos=[0,0,0], head_thickness=wall_width(), screw_len = 10, extra_len=1, nut_thickness=2.25, countersunk=true, screw_d=3, head_d=5.8, nut_d=5.6, slop = .2) {
  d=screw_d+slop;
  h= screw_len+extra_len;
  nut_depth=screw_len-head_thickness - slop;

  $fn=60;

  positions = [[0,19,1], [0,0,-1], [0,-26,1]];

  translate(pos) rotate ([0,-90,0]) translate([0,0,-head_thickness]) {
    // screw holes
    for (i = positions)
      translate([i.z, i.y, 0]) cylinder(d=d,h=h);

    // cones for countersink
    if (countersunk)
      for (i = positions)
        translate([i.z, i.y, 0]) cylinder(d1=head_d+slop,h=(head_d+slop)/2);
  }

  // square nut holes
  translate(pos) let(x=nut_thickness+slop, y=nut_d+slop,z=20) {
    translate(positions[0])
      rotate([-0,0,0])
      translate([-nut_depth, -y/2, -y/2])
      cube([x, y, z]);
    translate(positions[1])
      rotate([180,0,0])
      translate([-nut_depth, -y/2, -y/2])
      cube([x, y, z]);
    translate(positions[2])
      rotate([0,0,0])
      translate([-nut_depth, -y/2, -y/2])
      cube([x, y, z]);
  }
}


a = 16 + 2/3;

y = 53.356;
depth = 9.9;

split_sep_min = 157.5;
split_sep_max = split_sep_min+70;

screw_d=3.2;
side_thickness = 10;

slop=.2;

{
  adjust = a;
  rotate([0,0,adjust])
    split_mount(false);

  union(){
    pos = [-80, y/2+13, 0];
    mount_teensy20pp(position=pos, rotation=[0,0,-90])
      split_bracket(false);
    #translate(pos + [0,-11.5,depth/4]) cube([54.98,2,depth/2], true);
  }

  translate([-split_sep_max+15,0,0]) {
    rotate([0,0,-adjust])
      split_mount(true);
    split_bracket(true);
  }
}

module split_mount(left=true, extra=true, angle_comp=true) {
  angle_extra = side_thickness * tan(a);
  y2 = y+angle_extra;
  // can reduce the size of the pivot plate
  dia = y2;

  // reverse everything that happens to the screwhole, to center on the pivot
  translate([-(-side_thickness -dia/2 - slop) * (left? -1:1), -y2/2-(angle_comp? -y/2 + 2*angle_extra : -y2/2), 0]){
    mirror([left?1:0, 0, 0])
      translate([0, y2/2, 0]) rotate([0,0, 0]) difference() {
      union() {
        *translate([0, y/2, 0]) rotate([0,0, a]) translate([-.1, -y+2*slop, 0]) cube([side_thickness, y-4*slop, depth]);

        hull() {
          translate([-side_thickness, -y2+2*slop, 0]) cube([.1, y2-4*slop, depth]);
          translate([-0, -y2+2*slop, 0]) cube([.1, y-4*slop, depth]);
        }

        translate([0,0,extra?0: !left?depth/2:0]) {
          hull() {
            translate([-side_thickness, -y2+2*slop, 0]) cube([.1, y2-4*slop, extra?depth: depth/2]);
            translate([-side_thickness -dia/2 - slop, angle_comp? -y/2 + 2*angle_extra : -y2/2, 0])
              cylinder($fn=120, d=dia, h=extra?depth: depth/2);
          }

        }
      }

      translate([-side_thickness -dia/2 - slop, angle_comp? -y/2 + 2*angle_extra : -y2/2, 0])
        countersunk_screwhole_hexnut(pos = [0,0,wall_width()], a = [0,0,0], screw_len=depth);

      if (extra)
        translate([-side_thickness -dia/2 - slop, angle_comp? -y/2 + 2*angle_extra : -y2/2, !left?-.1:depth/2]) {
          cylinder($fn=120, d=dia+2*slop, h=depth/2+.1);

          rotate([0,0,-a])
            translate([-dia*.7,-y2,0])
            cube([dia+2*slop, 2*y2, depth/2+.1]);
        }

      y3=19+(screw_d/2)+2.15;
      translate([-.1, -y3-(y2-y), 1.19 + 2+screw_d/2])
        better_holes();
    }
  }
}

module split_bracket(left=true) {
  angle_extra = side_thickness * tan(a);
  y2 = y+angle_extra;
  // can reduce the size of the pivot plate
  dia = y2;

  sep = (split_sep_min-dia/2);

  distance_from_edge = 8;

  difference() {
    translate([0,0,!left?0:depth/2])
      hull() {
      cylinder($fn=120, d=dia, h=depth/2);
      translate([sep *(left?1:-1), -y2/2, 0]) cube([.1, y2, depth/2]);
    }

    // screwhole for pivot
    countersunk_screwhole_hexnut(pos = [0,0,wall_width()], a = [0,0,0], screw_len=depth);

    // notch for pivot collision avoidance
    translate([(sep + dia*.4)*(left?1:-1), 0, !left?0:depth/2])
      cylinder($fn=120, d=dia, h=depth/2);

    // screwholes for joining
    for (i=[-sep +distance_from_edge:(!left?2:3)*5:-dia/2])
    symdup([0,1,0])
      translate([i*(left?-1:1), y2/2 - distance_from_edge, 0])
      countersunk_screwhole_hexnut(pos = [0,0,wall_width()], a = [0,0,0], screw_len=depth);


  }
}

module unibracket() {
  top_width = 222;

  top_recession = 11;

  mount_teensy20pp(position=[0,38-top_recession,0], rotation=[0,0,-90], z=depth-2)
    difference() {
    union() {
      difference() {
        // make shell
        hull() {
          symdup([1,0,0]) translate([top_width / 2, y/2, 0]) rotate([0,0, a]) translate([-.1, -y+2*slop, 0]) cube([.1, y-4*slop, depth]);
        }


        // middle cutout
        hull() {
          y3=12;
          symdup([1,0,0])  translate([-side_thickness,0,0]) translate([top_width / 2, y/2, -.1]) rotate([0,0, a]) translate([-.1, -y3-21, 0]) cube([.1, y3, depth+.2]);
        }

        //
        hull() {
          y3=top_recession;
          symdup([1,0,0])  translate([-side_thickness,0,0]) translate([top_width / 2, y/2, -.1]) rotate([0,0, a]) translate([-.1, -y3-0, 0]) cube([.1, y3+.1, depth+.2]);
        }

         hull() {
          y3=7;
          symdup([1,0,0])  translate([-side_thickness,0,0]) translate([top_width / 2, y/2, -.1]) rotate([0,0, a]) translate([-.1, -.1-y, 0]) cube([.1, y3+.1, depth+.2]);
        }
      }

      // reinforce bottom hole
      symdup([1,0,0]) translate([top_width / 2, y/2, 0]) rotate([0,0, a]) translate([-side_thickness, -y, 0]) cube([side_thickness, y-top_recession, depth]);
    }

    // cut holes
    y2=19+(screw_d/2)+2.15;
    #symdup([1,0,0]) translate([top_width / 2, y/2, 1.19 + 2+screw_d/2]) rotate([0,0, a]) translate([-.1, -y2, 0]) holes();
  }



  translate([0,0,depth/2])  cube([60, 30, depth], center=true);
}
