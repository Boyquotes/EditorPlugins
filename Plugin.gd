tool
extends EditorPlugin


const RAY_LENGTH = 1000

var selected_object


func _enter_tree():
	print("Snap plugin Enter tree")


func _exit_tree():
	print("Snap plugin Exit tree")


func handles(object):
	selected_object = object
	return object is Spatial


func forward_spatial_gui_input(camera, event):
	if not event is InputEventMouseButton:
		return
	if not event.pressed:
		return
	if not Input.is_key_pressed(KEY_ALT):
		return

	var normal = -camera.global_transform.basis.z

	var mouse_position = event.position
	var ray_start = camera.project_ray_origin(mouse_position)
	var ray_end = ray_start + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	var space_state = get_tree().root.world.direct_space_state
	var result = space_state.intersect_ray(ray_start, ray_end)

	if result:
		var position = result.position

		if selected_object is MultiMeshInstance:

			var multimesh = selected_object.multimesh

			match event.button_index:
				BUTTON_LEFT:
					var transforms = []
					for i in multimesh.instance_count:
						transforms.append(multimesh.get_instance_transform(i))

					var new_transform = Transform()
					new_transform.origin = position
					transforms.append(new_transform)

					var count = transforms.size()
					multimesh.instance_count = count
					multimesh.visible_instance_count = count

					for i in count:
						var transform = transforms[i]
						multimesh.set_instance_transform(i, transform)

				BUTTON_RIGHT:
					var transforms = []
					for i in multimesh.instance_count:
						var instance_transform = multimesh.get_instance_transform(i)
						var aabb = multimesh.mesh.get_aabb()

						aabb.position = instance_transform.origin - aabb.size / 2

						if not aabb.intersects_segment(ray_start, ray_end):
							transforms.append(instance_transform)

					var count = transforms.size()
					multimesh.instance_count = count
					multimesh.visible_instance_count = count

					for i in count:
						var transform = transforms[i]
						multimesh.set_instance_transform(i, transform)

		else:
			selected_object.global_transform.origin = position

	return true
