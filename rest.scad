/* Crystalhand's holder for a silicone palmrest, now with feet and a magnet
   for secure use on an angled (metal) surface */

use <util.scad>;

mount_foot(position=[-40,-20,0])
mount_foot(position=[-30,28,0])
mount_foot(position=[40,-20,0])
mount_foot(position=[30,28,0])
bar_magnetize_below(rotation=[0,0,90], washer=9)
wrist_rest_base($fn=120,angle=[10,0,0], back_height=30);

module wrist_rest_base(angle=[20,-5,9], back_height = 43, ledge = 3.5){
  h_offset = tan(angle.x)*88;
  scale_cos = cos(angle.x);
  scale_amount= scale_cos * 83.7/19.33;

  module wrist_rest_helper(){
    difference(){
      scale([4.25,scale_amount, 1]) union() {
	difference() {
	  scale([1.3, 1, 1]) cylinder(r=10, h=150, center=true);
	  scale([1.1, 1, 1]) translate([0, -13.4, 0]) cylinder(r=7, h=201, center=true);
	  translate([0,-12.4,0]) cube([18,10,201], center=true);
	}
	translate([-6.15, -0.98, 0]) cylinder(r=6.8, h=200, center=true);
	translate([6.15, -0.98, 0]) cylinder(r=6.8, h=200, center=true);

	translate([-6.35, -2, 0]) cylinder(r=5.9, h=200, center=true);
	scale([1.01, 1, 1]) translate([6.35, -2, 0]) cylinder(r=5.9, h=200, center=true);
      }

      translate([0,0,-51]) cube([300,300,102],center=true);
    }
  }

  rotate([0,0,angle.z]) difference() {
    scale([1.08,1.08,1]) wrist_rest_helper();
    rotate([0,angle.y,0]) rotate([angle.x,0,0]) translate([0,0, (h_offset/2)+(back_height -h_offset)+100]) cube([200,200,200],center=true);
    difference(){
      wrist_rest_helper();
      rotate([0,angle.y,0]) rotate([angle.x,0,0]) translate([0,0, (h_offset/2)+(back_height -h_offset)-(100+ledge)]) cube([200,200,200],center=true);
    }
  }
}
