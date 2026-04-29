/* ==================================================================
   Project: Generative Truss Quadcopter Frame
   Description: Advanced 2D-to-3D mathematical framing with intersection logic
   Author: tiendma 
   ================================================================== */

// --- 1. PARAMETERS ---
propeller_size_inch = 5;      // Propeller size in inches
prop_clearance = 15;          // Safety clearance between propellers (mm)
hub_radius = 25;              // Central hub radius (for Flight Controller/PDB)
frame_thickness = 5.0;        // Carbon fiber / 3D print thickness
$fn = 64;

// Calculate arm length using trigonometry
// Minimum motor-to-motor distance = prop_diameter + clearance
prop_dia_mm = propeller_size_inch * 25.4;
motor_to_motor = prop_dia_mm + prop_clearance;
arm_length = (motor_to_motor / sqrt(2)); // Arm length based on the hypotenuse of an isosceles right triangle

// --- 2. GENERATIVE MASKS ---
// Generates a 2D hexagonal honeycomb mask for weight reduction
module hex_mask_2d(w, l) {
    size = 4;
    cols = floor(l / (size * 1.5));
    rows = floor(w / (size * 1.732)); // sqrt(3) height ratio
    
    for(x = [0:cols], y =[-rows/2 : rows/2]) {
        offset_y = (x % 2 == 0) ? 0 : (size * 1.732 / 2);
        translate([x * size * 1.5, y * size * 1.732 + offset_y])
            circle(r=size-0.5, $fn=6); // Hexagonal lattice unit
    }
}

// 2D Arm geometry with applied truss/cutout patterns
module arm_2d() {
    difference() {
        // Base arm profile
        hull() {
            circle(r=hub_radius);
            translate([arm_length, 0]) circle(r=15); // Motor mounting plate
        }
        
        // Intersect mask within the arm body region
        intersection() {
            translate([hub_radius, 0]) square([arm_length - hub_radius - 10, 40], center=true);
            translate([hub_radius, 0]) hex_mask_2d(40, arm_length);
        }
        
        // Motor mounting pattern
        translate([arm_length, 0]) {
            circle(d=6); // Central motor shaft bore
            for(a=[0, 90, 180, 270]) rotate([0,0,a]) translate([8,0]) circle(d=3.2); // M3 screw mounting pattern
        }
    }
}

// --- 3. MAIN ASSEMBLY (2D-to-3D Extrusion) ---
module drone_frame() {
    linear_extrude(frame_thickness) {
        union() {
            // Replicate 4 times to generate the X-frame configuration
            for(angle = [45, 135, 225, 315]) {
                rotate([0, 0, angle]) arm_2d();
            }
        }
    }
}

// Render final geometry
drone_frame();