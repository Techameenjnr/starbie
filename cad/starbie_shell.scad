// Starbie Shell — Week 2 enclosure concept
// Units: millimetres. Board coordinates are translated so the outline's
// lower-left corner (-4, 0.5) maps to enclosure-local (0, 0).

// PCB dimensions measured from the four KiCad Edge.Cuts segments.
pcb_width = 68.5;
pcb_depth = 59.0;
pcb_thickness = 1.6;

// Fit and construction parameters. Adjust these after measuring the real PCB
// and chosen printer/material; they are starting values, not validated fits.
board_side_clearance = 0.5;  // cavity clearance at each board edge
wall_thickness = 2.0;
base_floor_thickness = 2.0;
base_wall_height = 16.0;
corner_ledge_width = 5.5;
corner_ledge_depth = 5.5;
ledge_thickness = 1.8;      // vertical thickness of the PCB bearing shelf
support_web_thickness = 1.8; // lower ribs joining each shelf to both walls
board_bottom_height = 4.5;   // board underside above the outside bottom

lid_top_thickness = 2.0;
lid_skirt_height = 6.0;
lid_wall_thickness = 1.8;
lid_fit_clearance = 0.35;   // per side around base exterior

// Select "assembly", "base", or "lid" for preview/export.
part = "assembly";

cavity_width = pcb_width + 2 * board_side_clearance;
cavity_depth = pcb_depth + 2 * board_side_clearance;
outer_width = cavity_width + 2 * wall_thickness;
outer_depth = cavity_depth + 2 * wall_thickness;
base_height = base_floor_thickness + base_wall_height;

// Base centered about the PCB outline. Each corner shelf bears the PCB at
// board_bottom_height. Two lower ribs connect each shelf to the adjacent cavity
// walls and floor, so none of the supports are floating print islands.
module base() {
    difference() {
        cube([outer_width, outer_depth, base_height]);
        translate([wall_thickness, wall_thickness, base_floor_thickness])
            cube([cavity_width, cavity_depth, base_wall_height + 0.02]);
    }

    shelf_bottom = board_bottom_height - ledge_thickness;
    rib_bottom = base_floor_thickness - 0.02; // overlap floor for a robust union
    rib_height = shelf_bottom - rib_bottom + 0.02;
    wall_overlap = 0.02; // overlap the cavity walls to avoid face-only contact

    for (x_side = [0, 1])
        for (y_side = [0, 1]) {
            x = wall_thickness + (x_side ? cavity_width - corner_ledge_width : 0);
            y = wall_thickness + (y_side ? cavity_depth - corner_ledge_depth : 0);

            // Bearing shelf: its upper face is exactly the intended PCB underside height.
            translate([x - (x_side ? 0 : wall_overlap),
                       y - (y_side ? 0 : wall_overlap), shelf_bottom])
                cube([corner_ledge_width + wall_overlap,
                      corner_ledge_depth + wall_overlap, ledge_thickness]);

            // Rib along the X-adjacent wall and rib along the Y-adjacent wall.
            // Together they form a connected L beneath each corner shelf.
            translate([x - (x_side ? 0 : wall_overlap),
                       y + (y_side ? corner_ledge_depth - support_web_thickness : 0),
                       rib_bottom])
                cube([corner_ledge_width + wall_overlap,
                      support_web_thickness + wall_overlap, rib_height]);
            translate([x + (x_side ? corner_ledge_width - support_web_thickness : 0),
                       y - (y_side ? 0 : wall_overlap), rib_bottom])
                cube([support_web_thickness + wall_overlap,
                      corner_ledge_depth + wall_overlap, rib_height]);
        }
}

// A shallow cap with an open skirt slides over the outside of the base.
// No connector, sensor, button, or mounting-hole openings are assumed.
module lid(z_offset = base_height) {
    lid_outer_width = outer_width + 2 * (lid_wall_thickness + lid_fit_clearance);
    lid_outer_depth = outer_depth + 2 * (lid_wall_thickness + lid_fit_clearance);
    translate([-lid_wall_thickness - lid_fit_clearance,
               -lid_wall_thickness - lid_fit_clearance,
               z_offset])
        difference() {
            cube([lid_outer_width, lid_outer_depth,
                  lid_skirt_height + lid_top_thickness]);
            translate([lid_wall_thickness, lid_wall_thickness, -0.01])
                cube([outer_width + 2 * lid_fit_clearance,
                      outer_depth + 2 * lid_fit_clearance,
                      lid_skirt_height + 0.02]);
        }
}

if (part == "base") {
    base();
} else if (part == "lid") {
    lid(0);
} else {
    base();
    lid();
}
