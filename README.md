# untitled-pvp-danmaku-game
pvp danmaku game inspired by maiden &amp; spell with music based elements

## bullet system
* currently, bullet positions and velocities are composed through a piecewise function
    * this piecewise function P(t) gives a 4 component vector, storing (pos x, pos y, vel x, vel y)
    * each bullet is defined as a 4 tuple, where each bullet is defined as (kind, start, end, piecewise)
    * this makes it hopefully really easy to rollback
* rendering side queries the active bullet command pools and renders the bullet from the object pools
* also, it's all based off of the client timer, so no delta time exists here

## vfx
* this branch is just holding vfx related stuff.
* will use for like visual effects handling and possibly scripts to export from blender -> godot regarding the background stuff
* also, for testing particle systems, ui, and the sort :d