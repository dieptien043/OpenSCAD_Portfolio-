/* ==================================================================
   Project: Parametric NEMA Motor Mount with Belt Tensioner
   Description: End-to-end parametric design for a motor bracket.
   Author: 
   ================================================================== */

// --- 1. PARAMETERS (Technical Specifications) ---
nema_type = 17;          // [14, 17, 23] Select NEMA motor standard
thickness = 4.0;         // Bracket wall thickness (mm)
travel_dist = 15.0;      // Sliding distance for belt tensioning (mm)
tolerance = 0.2;         // 3D printing clearance/tolerance (mm)
$fn = 64;                // Curve resolution

// --- 2. DATA LOOKUP (Logic & Constants) ---
// Functions to retrieve dimensions based on NEMA standards
function get_nema_width(type) = (type == 23) ? 56.4 : ((type == 17) ? 42.3 : 35.2);
function get_hole_spacing(type) = (type == 23) ? 47.1 : ((type == 17) ? 31.0 : 26.0);
function get_center_hole(type) = (type == 23) ? 38.1 : ((type == 17) ? 22.0 : 22.0);
function get_screw_dia(type) = (type == 23) ? 5.0 : 3.0; // M5 for NEMA23, M3 for 14/17

// --- 3. REUSABLE MODULES ---
/**
 * @brief Generates a 2D slotted hole using hull() for geometric accuracy
 * @param dia: Diameter of the hole
 * @param travel: Length of the slot
 */
module slotted_hole_2d(dia, travel) {
    hull() {
        circle(d=dia);
        translate([travel, 0]) circle(d=dia);
    }
}

// --- 4. MAIN CSG & EXTRUSION ---
module nema_mount() {
    w = get_nema_width(nema_type);
    spacing = get_hole_spacing(nema_type);
    center_d = get_center_hole(nema_type) + tolerance;
    screw_d = get_screw_dia(nema_type) + tolerance;
    
    // Motor Mounting Flange (Vertical Face)
    translate([0, thickness, 0]) rotate([90, 0, 0])
    difference() {
        // 2D to 3D Extrusion
        linear_extrude(thickness)
        offset(r=2) offset(delta=-2) // 2D rounding technique for stress reduction
        square([w, w], center=true);
        
        // Center bore and 4 mounting holes
        translate([0, 0, -1]) cylinder(h=thickness+2, d=center_d);
        for(x = [-1, 1], y = [-1, 1]) {
            translate([x * spacing/2, y * spacing/2, -1])
            cylinder(h=thickness+2, d=screw_d);
        }
    }

    // Base Mounting Flange (Horizontal Face)
    translate([0, 0, -w/2])
    difference() {
        translate([-w/2, 0, 0]) cube([w, w, thickness]);
        
        // Belt tensioner slots
        for(x = [-w/3, w/3]) {
            translate([x, w/4, -1])
            linear_extrude(thickness + 2)
            rotate([0,0,90])
            slotted_hole_2d(dia=screw_d+1, travel=travel_dist);
        }
    }
}

// Render execution
nema_mount();