# Starbie Shell CAD

`starbie_shell.scad` defines a parametric enclosure base and removable cap in millimetres. The PCB is centred in the cavity, with its KiCad lower-left outline corner translated from `(-4, 0.5)` to local `(0, 0)`. The measured outline is 68.5 × 59 mm and the nominal PCB thickness is 1.6 mm. KiCad `Edge.Cuts` contains four straight segments and no mounting-hole footprints were detected.

The design starts with 0.5 mm clearance at each board edge, 2 mm walls and floor, and four adjustable 5.5 × 5.5 mm corner bearing shelves. Each shelf top is at the configured 4.5 mm board underside height. Two lower ribs per corner join the shelf to adjacent cavity walls and overlap the floor slightly, avoiding isolated or floating support geometry. The supports remain at the PCB corners; no posts sit below component footprints. The lid is a shallow cap fitted over the outside of the base with 0.35 mm per-side nominal clearance. These dimensions are conservative starting assumptions and need adjustment for the board, component heights, printer, and material. There are no invented connector, button, sensor, or fastener openings.

## Coordinate and source notes

The KiCad board itself is the geometry source. `kicad-cli pcb export pos` reports footprint origins in the PCB coordinate system, with negative Y for the top side: J1 `(38, -35)`, J2 `(38, -8)`, SW1 `(18.9, -17)`, SW2 `(18.9, -30)`, U1 `(-2.8, -30)`, and U2 `(55, -8)`. This confirms the board origin is not the enclosure origin. The supplied `/tmp/starbie-components.csv` does not agree with those KiCad positions, so it was not used to place supports or openings.

The PCB source references KiCad 3D models for J1/J2 socket strips, SW1/SW2 pushbuttons, and U2 DHT11. No XIAO 3D model is referenced. These references establish that models were configured in the PCB source; they do not establish actual installed component dimensions or clearance.

## Preview and export

With OpenSCAD installed, preview the assembly with:

```sh
openscad cad/starbie_shell.scad
```

Export the pieces separately as STL (OpenSCAD command line; run from the repository root):

```sh
openscad -D 'part="base"' -o cad/exports/starbie_shell_base.stl cad/starbie_shell.scad
openscad -D 'part="lid"' -o cad/exports/starbie_shell_lid.stl cad/starbie_shell.scad
```

The final exports are `cad/exports/starbie_shell_base.stl` (73.5 × 64 × 18 mm) and `cad/exports/starbie_shell_lid.stl` (77.8 × 68.3 × 8 mm). The lid export is translated to Z=0 for a convenient standalone part; in the assembly preview it sits at the base top. Re-run the commands after changing parameters. Set `part` to `"assembly"`, `"base"`, or `"lid"` in the source for other previews. OpenSCAD rendered both final STL exports from the current SCAD source. Each STL has one connected triangle component and every mesh edge is shared by exactly two facets, so both exported meshes are closed and manifold. This checks mesh integrity only; it does not validate fit, structural strength, slicer behavior, or physical printability. FreeCAD is not installed in the current environment.

## Physical checks still needed

- Measure the physical PCB and confirm its actual outline, thickness, and orientation.
- Check the footprint CSV against the intended/updated PCB; resolve its coordinate mismatch.
- Measure component body and solder-side heights, especially the angled OLED and MPU6050 sockets, DHT11, buttons, and XIAO. Confirm lid interior clearance and that the corner ledges avoid all board features.
- Confirm whether connectors need to protrude through a side or lid, and add openings only after measuring the actual assemblies and cable direction.
- Test insertion, retention, lid fit, and print tolerances with the intended material and printer. The OpenSCAD mesh export is not a physical fit or printability test. The model is a CAD starting point; it has not been physically tested and is not print-ready.
