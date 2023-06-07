# Godot VR Physics Template
This is a template for a VR application in Godot with physical hands that interact with the
environment, and cannot go through walls or other solid objects. The player can pick up items, and
those too cannot be pushed through walls. It also provides other expected VR functionality such as
turning and teleporting, and other basic features for any application including loading settings
at runtime from a config file.

This version is for Godot 4.0 or later. For Godot 3,
[see here](https://github.com/jtnicholl/godot3-vr-physics-template).

I would recommend using 4.1 or later. As you may already know, small freezes and stutters can
occur due to shader compilation, and these are especially undesirable with a head-mounted display.
While Godot 4.0 does implement shader caching to prevent these stutters on subsequent runs of the
application, Vulkan also needs "pipelines", which must be compiled similarly, and Godot did
not cache these until 4.1.

Note that even Godot 4.1 still is not able to compile shaders or pipelines asynchronously, like
Godot 3.5+ does, so there is no easy way to avoid these stutters on the first run of your
application. There are some techniques you can try, such as briefly rendering materials hidden
behind a loading screen to get them cached early. If first-run stutters will be a problem for your
project and you do not want to use such workarounds, you may wish to wait until a future 4.x
release adds asynchronous compilation, or use the Godot 3 version of this template linked above.

## Why should I use this?
Many VR games use a very simple system for the player's hands. The hand copies the position of the
controller every frame, and that's it. When the player picks up an object with their hand, the
object gets its physics shut off, and it gets dragged along with the hand. When the item is let go
it is disconnected from the controller, its physics are turned back on, and sometimes it is given
an impulse so it can be thrown.

This is the system used by all VR Godot projects I could find online. Its obvious limitation being
that the player's hands and any objects they pick up simply phase through walls with no collision.

### New method
This template takes a different approach to hands. For each hand it involves:
- The XRController3D node built into Godot. This copies the position of the controller.
- A "hand anchor," which is a CharacterBody3D with a small sphere shape. It uses `move_and_slide` to copy the position of the controller, but without passing through the environment.
- A hand node, which is a RigidBody3D that uses `_integrate_forces` to loosely copy the rotation of the controller. This is also where the hand is visually displayed.
- A PinJoint3D node that moves the hand node to the hand anchor node. Since the hand anchor won't pass through walls, this is never too extreme of a force.

Grabbing objects can happen one of two ways, depending on the object being grabbed. For both, the
first step is to have the hand node move to the nearest grabbable point.

For objects that extend `Pickup`, the pickup is then reparented to the hand. However, instead of
merely disabling collision on the picked up object, its collision shapes get reparented to the
hand. This effectively turns the object into an extension of the hand's collision bounds, keeping
them together precisely while also preventing them from passing through walls.

Other grabbable objects, such as doors and drawers, should extend `Moveable`. These objects get
connected to the hand with a joint.

## Credits
The VR glove model was created by Valve.

The textures used for the demo room, with the exception of those used for the beach balls, lamp
shades, and desk drawer knobs, are from [ambientCG](https://ambientcg.com/) and are in the public
domain.

## License
This project is released under the MIT license. See the [license](LICENSE) file for details.
