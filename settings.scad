/* keycaps */
_profile = "cherry";

// the height of the bottom of the keycap over the key_mount.
// a property of the keycap but I couldn't think fo a better name.
// shouldn't need to override this directly, but you can.
//_stem_height = 6.1;

// keycap render settings

/* Pre-rendered keycaps are recommended as they should be much faster, and remove the dependency on KeyV2.
 * However they lose the distinctive coloring. Also, pre-renders may be missing. Used in both previews and renders.
 */
_prerendered_keycaps = true;

// if not pre-rendering, these options turn down the fidelity so that previews/renders don't take so long
_fast_keycap_preview = true;
_fast_keycap_render = false;

// don't show keycaps in renders. we don't want keys when 3D printing, also they block the view and can be slow
_disable_keycap_render = true;


/* keyswitch */
// switch style is "mx", "choc".
// can be inferred from profile
//_switch_style= "choc";

// if using mx switches, are they speed switches (lower travel)?
//_mx_speed = true;

// how far the key switch can depress (only for visual indication, doesn't affect the keyboard)
// can be inferred from switch type
//_switch_travel = 4.0;


/* key_mount parameters */
// innerdia is the (square) hole for the switch
// outerdia is the the minimum structural support
_mx_innerdia = 13.9;
_mx_outerdia = 17;

_choc_innerdia = 13.8;
_choc_outerdia = 15.5;

// key plate thickness
// can be inferred from switch type
//_thickness=4; // blanket override... probably unnecessary

_mx_thickness = 4;
_choc_thickness = 3;

// MX cutout params
function mx_tab_offset() = 1.2; // how far from the top the switchholders start
function mx_tab_depth() = 0.6; // how far tabs stick out
function mx_tab_width() = 5;

_epsilon = .001; // smallest meaningful overlap, used when avoiding coincident faces

// the footprint of the keycaps.
// defines how close key_mounts can be, but mostly used for outer perimeters.
_mx_min_spacing = 18.4;
_choc_min_spacing = 18;

// how much room we need for switchpins, hotswaps, etc.
// used to cut into trackpoint mount supports
function switch_clearance() = 3;


/* side wall width */
_wall_width=2.5;

// extra space between the key mount and an ajoining wall, in x and y
_wall_extra_room = [0,0]; //[5,3];


// bounds
//highest_high=40;
//XXX  eliminate by placing bottom of plate at Z=0
function lowest_low() = 60;

// Do Not Edit Below This Line

function profile(override) =
  !is_undef(override) ? override :
  !is_undef($profile) ? $profile :
  _profile;

function profile_is_uniform() =
  profile() == "dsa" || profile() == "g20" || profile() == "lpx";


function stem_height() =
  !is_undef($stem_height) ? $stem_height :
  !is_undef(_stem_height) ? _stem_height :
  profile() == "cherry" ? 6.1 :
  profile() == "sa" ? 6.8 :
  profile() == "lpx" ? 5 :
  assert(false, "unrecognized keycap profile");


function prerendered_keycaps() = !is_undef($prerendered_keycaps) ? $prerendered_keycaps : _prerendered_keycaps;
function fast_keycap_preview() = !is_undef($fast_keycap_preview) ? $fast_keycap_preview : _fast_keycap_preview;
function fast_keycap_render() = !is_undef($fast_keycap_render) ? $fast_keycap_render : _fast_keycap_render;
function disable_keycap_render() = !is_undef($disable_keycap_render) ? $disable_keycap_render : _disable_keycap_render;

function switch_type() =
  !is_undef($switch_type) ? $switch_type :
  !is_undef(_switch_type) ? _switch_type :
  profile() == "lpx" || profile() == "mbk" || profile() == "cs" || profile() == "mcc" ? "choc" :
  profile() == "cherry" || profile() == "sa" || profile() == "dsa" || profile() == "g20" ? "mx" :
  assert(false, str("unknown profile '", profile(), "' cannot deduce switch_type"));

function mx_speed() =
  !is_undef($mx_speed) ? $mx_speed :
  !is_undef(_mx_speed) && _mx_speed;

function switch_travel() =
  !is_undef($switch_travel) ? $switch_travel :
  !is_undef(_switch_travel) ? _switch_travel :
  switch_type() == "mx" ? mx_speed() ? 3.5 : 4.0 :
  switch_type() == "choc" ? 3.0 :
  assert(false, str("unknown switch_type '", switch_type()));

function innerdia() =
  !is_undef($innerdia) ? $innerdia :
  switch_type() == "mx" && !is_undef(_mx_innerdia) ? _mx_innerdia :
  switch_type() == "choc" && !is_undef(_choc_innerdia) ? _choc_innerdia :
  assert(false, str("please define an innerdia for: ", switch_type()));

function outerdia() =
  !is_undef($outerdia) ? $outerdia :
  switch_type() == "mx" && !is_undef(_mx_outerdia) ? _mx_outerdia :
  switch_type() == "choc" && !is_undef(_choc_outerdia) ? _choc_outerdia :
  assert(false, str("please define an outerdia for: ", switch_type()));

function spacer() =
  !is_undef($spacer) ? $spacer :
  switch_type() == "mx" ? _mx_min_spacing - outerdia() :
  switch_type() == "choc" ? _choc_min_spacing - outerdia() :
  assert(false, str("please define an spacer for: ", switch_type(), " or: ", profile()));

function thickness() =
  !is_undef($thickness) ? $thickness :
  !is_undef(_thickness) ? _thickness :
  switch_type() == "mx" ? _mx_thickness :
  switch_type() == "choc" ? _choc_thickness :
  assert(false, "please define a key plate thickness");

function wall_width() =
  !is_undef($wall_width) ? $wall_width :
  !is_undef(_wall_width) ? _wall_width :
  assert(false, "please defined a wall_width");

function wall_extra_room() =
  !is_undef($wall_extra_room) ? $wall_extra_room :
  !is_undef(_wall_extra_room) ?
  !is_list(_wall_extra_room) ? [_wall_extra_room, _wall_extra_room]
  : _wall_extra_room :
  [0,0];


function epsilon() =
  !is_undef($epsilon) ? $epsilon :
  !is_undef(_epsilon) ? _epsilon :
  assert(false, "please define an _epsilon value");
