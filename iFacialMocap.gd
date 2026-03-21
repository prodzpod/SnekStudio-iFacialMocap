class_name IFacialMocap_Tracker extends Mod_Base
static var instance: IFacialMocap_Tracker
func _enter_tree() -> void: instance = self

var bind_port: int = 49983
var receiver_enabled : bool = false
var mediapipe_guy: Mod_MediaPipeController

func _ready():
	add_tracked_setting("bind_port", "Receiver port")
	add_tracked_setting("receiver_enabled", "Receiver enabled")
	var test_button : Button = Button.new()
	test_button.text = "Test Packet"
	get_settings_window().add_child(test_button)
	test_button.pressed.connect(test_packet)
	load_after({}, {})

func load_after(_settings_old: Dictionary, _settings_new: Dictionary):
	if get_parent().has_node("MediaPipeController"): 
		mediapipe_guy = $"../MediaPipeController"
		print_log(["Found Mediapipe Guy:", mediapipe_guy])
	start_server()

# shoutout xhiggy we love you xhiggy
var udp_socket: PacketPeerUDP
func start_server():
	if udp_socket and udp_socket.is_bound(): udp_socket.close()
	if not receiver_enabled: return
	udp_socket = PacketPeerUDP.new()
	var error = udp_socket.bind(bind_port)
	if error != OK:
		print_log("Failed to bind UDP socket on port %d: %s" % [bind_port, error_string(error)])
		return
	print_log("Face receiver bound to port %d" % bind_port)

func _physics_process(_delta: float) -> void:
	if udp_socket != null and udp_socket.get_available_packet_count() > 0:
		var packet
		while udp_socket.get_available_packet_count() > 0:
			packet = udp_socket.get_packet()
		on_message(_delta, packet.get_string_from_utf8())

func test_packet():
	on_message(1, "eyeLookIn_R-54|noseSneer_L-5|mouthPress_L-8|mouthSmile_R-4|mouthLowerDown_L-1|mouthSmile_L-1|eyeWide_L-26|mouthRollUpper-1|mouthPucker-3|browOuterUp_L-3|mouthDimple_R-3|mouthShrugLower-21|mouthLeft-0|eyeLookUp_R-0|mouthFunnel-1|mouthDimple_L-3|mouthUpperUp_R-2|noseSneer_R-6|eyeSquint_R-3|jawForward-2|mouthClose-2|mouthFrown_L-0|mouthShrugUpper-15|eyeSquint_L-3|cheekSquint_L-3|eyeLookDown_L-16|mouthLowerDown_R-1|eyeLookOut_R-0|jawLeft-0|mouthStretch_L-5|cheekPuff-3|eyeLookUp_L-0|eyeBlink_R-0|jawOpen-2|mouthRollLower-5|browInnerUp-4|browOuterUp_R-3|mouthFrown_R-0|mouthStretch_R-5|eyeLookIn_L-0|tongueOut-0|eyeBlink_L-0|browDown_L-0|eyeWide_R-26|eyeLookDown_R-16|mouthUpperUp_L-2|cheekSquint_R-3|mouthPress_R-8|browDown_R-0|jawRight-0|mouthRight-2|eyeLookOut_L-44|hapihapi-0|=head#-1.6704091,-7.3032465,2.886358,0.084120944,0.03458406,-0.4721467|rightEye#5.3555145,19.067966,1.8478252|leftEye#5.5607924,15.616646,1.5515244|")

func on_message(delta: float, message: String):
	#print_log(["Message Recieved:", message])
	var p = $Parser.parse(message)
	var previous_data = {
		"hand_left_origin": [0., 0., 0.],
		"hand_left_rotation": [[1., 0., 0.], [0., 1., 0.], [0., 0., 1.]],
		"hand_left_score": 1.,
		"hand_right_origin": [0.0, 0.0, 0.0],
		"hand_right_rotation": [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]],
		"hand_right_score": 1.,
		"head_origin": [0., 0., 0.],
		"head_quat": [0., 0., 0., 1.],
		"blendshapes": { "_neutral": 0. },
		"head_missing_time": 1.0,
		"hand_landmarks_left": [],
		"hand_landmarks_right": []
	}
	previous_data.merge(mediapipe_guy.last_parsed_data if mediapipe_guy else {})
	var t = $Transformer.transform(p, previous_data)
	if mediapipe_guy: mediapipe_guy._process_single_packet(delta, t)
