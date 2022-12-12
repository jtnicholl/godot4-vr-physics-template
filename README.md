Porting this project to Godot 4.0 is still a work in progress. This is not intended for use yet.

# Godot VR Physics Template
This is a basic template for a VR application in Godot with physical hands that interact with the environment, and cannot go through walls or other solid objects. The player can pick up items, and those too cannot be pushed through walls. It also provides other expected VR functionality such as turning and teleporting, as well as some other basic features for any application including loading settings at runtime from a config file.

This version is for Godot 4.0 or later. For Godot 3.5, see [here](https://github.com/jtnicholl/godot3-vr-physics-template)

## Why should I use this?
Many VR games use a very simple system for the player's hands. The hand copies the position of the controller every frame, and that's it. When the player picks up an object with their hand, the object gets its physics shut off, and it gets dragged along with the hand. When the item is let go it is disconnected from the controller, its physics turned back on, and sometimes it is given an impulse so it can be thrown.

This is the system used by all VR Godot projects I could find online. Its obvious limitation being that the player's hands and any objects they pick up simply phase through walls with no collision.
### New method
This template takes a different approach to hands. For each hand it involves:
- The XRController node built into Godot. This copies the position of the controller.
- A "hand anchor," which is a CharacterBody3D with a small shpere shape. It uses `move_and_slide` to copy the position of the controller, but without passing through the environment.
- A hand node, which is a RigidBody3D that uses `_integrate_forces` to losely copy the rotation of the controller. This is also where the hand is visually displayed.
- A PinJoint3D node that moves the hand node to the hand anchor node. Since the hand anchor won't pass through walls, this is never too extreme of a force.

Grabbing objects can happen one of two ways, depending on the object being grabbed. For both, the first step is the hand node moves to the nearest grabbable point.
For objects that extend `Pickup`, the pickup is then reparented to the hand. However, instead of just disabling collision on the picked up object, its collision bounds also get reparented to the hand. This effectively turns the object into an extension of the hand's collision bounds, keeping them together precisely while also preventing them from passing through walls.
Other grabbable objects, such as doors and drawers, should extend `Moveable`. These objects are connected to the hand with a joint.

## Credits
The VR glove model was created by Valve.

The textures used for the demo room, with the exception of those used for the beach balls, lamp shades, and desk drawer knobs, are from [ambientCG](https://ambientcg.com/) and are in the public domain.

## License
This project is released under the MIT license. See the [license](LICENSE) file for details.
