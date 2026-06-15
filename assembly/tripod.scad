use <../util.scad>;

$fs=.1;
$fa=1;

module smallrig_mount(rot=[0,90,0],pos=[0,0,0],noop=false, frame=true){
  d=8.1;
  wall=1.3;
  slop = .1;
  h=7.4;

  difference() {
    union() {
      children();
      if (!noop) {
        translate(pos) rotate(rot) cylinder(d=d+slop+2*wall,h=h,center=false);
        if (frame)
          let(x=h+wall,y=25,z=13)
          translate(pos) rotate(rot) translate([0,0,x/2]) cube([z,y,x], true);
      }
    }

    if (!noop)
    translate(pos) rotate(rot){
      cylinder(d=d+slop,h=h*2,center=true);
      sep=15.1;
      d2=3;
      h2=2.6+slop*2;
      rotational_clone() translate([0,sep/2,0]) cylinder(d=d2+3*slop,h=h2*2,center=true);
      //translate([0,-sep,0]) cylinder(d=d2+2*slop,h=h2*2,center=true);
    }
  }
}

*smallrig_mount() let(x=10,y=40,z=x) translate([x/2,0,0]) cube([x,y,z], true);
