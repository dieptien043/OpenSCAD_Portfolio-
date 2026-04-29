/* ==================================================================
   Project: Modular Snap-Fit IoT Enclosure
   Description: Parameter-driven enclosure with CSG and snap-fit joints
   Author: tiendma
   ================================================================== */

// --- 1. PARAMETERS ---
pcb_length = 70;
pcb_width = 50;
pcb_height = 20;
wall = 2.0;
tol = 0.3;          // Assembly tolerance/clearance
material = "PLA";   // ["PLA", "PETG", "ABS"]

// Adjust snap-fit geometry based on material properties
// PLA is more brittle, requiring a longer cantilever to reduce strain and prevent snapping
snap_length = (material == "PLA") ? 8.0 : 5.0; 

// --- 2. REUSABLE MODULES ---
module vent_pattern(w, l) {
    // Automatically calculate vent grid spacing
    cols = floor(w / 4);
    rows = floor(l / 4);
    for(i=[1:cols-1], j=[1:rows-1]) {
        translate([i*4 - w/2, j*4 - l/2, -10])
        cylinder(h=20, d=2, $fn=16);
    }
}

module snap_joint(is_male) {
    if(is_male) {
        // Male Snap-Fit (Lid Side)
        translate([0, 0, 0])
        hull() {
            cube([2, snap_length, 0.1], center=true);
            translate([0, 0, -2]) cube([3, snap_length, 0.1], center=true);
        }
    } else {
        // Female Snap-Fit (Base Side) with added tolerance (tol)
        hull() {
            cube([2 + tol, snap_length + tol, 0.1], center=true);
            translate([0, 0, -2.5]) cube([3 + tol, snap_length + tol, 0.1], center=true);
        }
    }
}

// --- 3. MAIN ARCHITECTURE ---
module bottom_case() {
    out_L = pcb_length + wall*2;
    out_W = pcb_width + wall*2;
    
    difference() {
        // Outer shell volume
        translate([0,0,pcb_height/2]) cube([out_L, out_W, pcb_height], center=true);
        // Interior hollow cavity
        translate([0,0,pcb_height/2 + wall]) cube([pcb_length, pcb_width, pcb_height], center=true);
        // Bottom ventilation holes
        vent_pattern(pcb_length, pcb_width);
        
        // Cutouts for female snap joints on side walls
        for(x =[-out_L/2 + 10, out_L/2 - 10]) {
            translate([x, out_W/2 - wall/2, pcb_height - 2]) 
                snap_joint(false);
            translate([x, -out_W/2 + wall/2, pcb_height - 2]) 
                rotate([0,0,180]) snap_joint(false);
        }
    }
}

module top_lid() {
    out_L = pcb_length + wall*2;
    out_W = pcb_width + wall*2;
    
    union() {
        // Enclosure Lid
        cube([out_L, out_W, wall], center=true);
        // Integrated male snap joints
        for(x =[-out_L/2 + 10, out_L/2 - 10]) {
            translate([x, out_W/2 - wall*1.5, -wall]) 
                snap_joint(true);
            translate([x, -out_W/2 + wall*1.5, -wall]) 
                rotate([0,0,180]) snap_joint(true);
        }
    }
}

// --- 4. RENDER / EXPORT ---
// Arrange parts side-by-side for print-ready layout
translate([0, pcb_width + 10, 0]) bottom_case();
top_lid();