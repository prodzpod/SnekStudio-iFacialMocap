extends Node
static func transform(packet: Dictionary, previous: Dictionary):
	var ret = previous.duplicate(true)
	ret.head_origin = [packet.head_position.x, packet.head_position.y, packet.head_position.z]
	ret.blendshapes.assign(packet.blend_shape_data)
	# rotation: euler in degrees to quat
	var quat = Quaternion.from_euler((packet.head_rotation as Vector3) / 180 * PI)
	ret.head_quat = [quat.x, quat.y, quat.z, quat.w]
	return ret
