extends Node
	
var blend_shape_data = {} # for storing all shape data in a name:value dict
var head_rotation = Vector3.ZERO
var head_position = Vector3.ZERO
func parse(message: String):
	for part in message.split("|"):
		part = part.strip_edges()
		if part.is_empty():
			continue
			
		# parse head rotation and position first
		if part.begins_with("=head#"):
			var head_data = part.trim_prefix("=head#").split(",")
			if head_data.size() >= 6:
				# some manual angles for clamping the head rotation I landed on
				head_rotation.x = clamp(float(head_data[0]), -75.0, 75.0)
				head_rotation.y = clamp(float(head_data[1]), -90.0, 90.0)
				head_rotation.z = clamp(float(head_data[2]), -90.0, 90.0)
				
				head_position.x = float(head_data[3])
				head_position.y = float(head_data[4])
				head_position.z = float(head_data[5])
				# note the head rotation seems to be 2x too much, so you may want to reduce it in the model script
				
		# then do the shape keys
		elif "-" in part and not part.begins_with("="):
			var tokens = part.split("-", true, 1)
			if tokens.size() == 2: # if valid size of data
				var blend_name = tokens[0]
				# name normalization - I think this was since meowface used different L/R formatting than ARKit
				if "_L" in blend_name:
					blend_name = blend_name.replace("_L", "Left")
				elif "_R" in blend_name:
					blend_name = blend_name.replace("_R", "Right")
				
				var blend_value = clamp(float(tokens[1]) / 100.0, -1.0, 1.0) # int to float value and clamp weird data received outside of -1 to 1
				
				blend_shape_data[blend_name] = blend_value # store all data in a name:value dict
	
	var ret = {
		"head_position": head_position,
		"head_rotation": head_rotation,
		"blend_shape_data": blend_shape_data
	}
	return ret
