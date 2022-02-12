/* keycaps */
profile = "cherry";

function mxstem() =
  profile == "cherry" ? 6.1 :
  profile == "sa" ? 6.8 :
  assert(false, "unrecognized keycap profile");

// keycap render settings

/* Pre-rendered keycaps are recommended as they should be much faster, and remove the dependency on KeyV2.
 * However they lose the distinctive coloring. Also, pre-renders may be missing. Used in both previews and renders
 */
_prerendered_keycaps = true;

// if not pre-rendering, these options turn down the fidelity so that previews/renders don't take so long
_fast_keycap_preview = true;
_fast_keycap_render = false;

// don't show keycaps in renders. we don't want keys when 3D printing, also they block the view and can be slow
_disable_keycap_render = true;

/* keyswitch */
switch_travel = 4.0;


/* MX keywell parameters */
innerdia=13.9;
outerdia=17;
thickness=4;

tab_offset = 1.2; // how far from the top the switchholders start
tab_depth = 0.6; // how far tabs stick out
tab_width = 5;

epsilon = .001; // smallest meaningful overlap

// XXX profile dependent?
function spacer() = 1.4; // how close keywells can be


/* side wall width */
wall_width=2;
wall_extra_room = [0,0]; //[5,3];

// bounds
highest_high=40;
lowest_low=60;


// Do Not Edit Below This Line

function prerendered_keycaps() = !is_undef($prerendered_keycaps) ? $prerendered_keycaps : _prerendered_keycaps;
function fast_keycap_preview() = !is_undef($fast_keycap_preview) ? $fast_keycap_preview : _fast_keycap_preview;
function fast_keycap_render() = !is_undef($fast_keycap_render) ? $fast_keycap_render : _fast_keycap_render;
function disable_keycap_render() = !is_undef($disable_keycap_render) ? $disable_keycap_render : _disable_keycap_render;
