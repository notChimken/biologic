extends Control

@export var max_players = 4
var lobby_code: String
var players = {}

@onready var network_manager = get_node("/root/NetworkManager")	
@onready var player_list: ItemList = $PlayerList
@onready var start_button: Button = $Start_Button
@onready var lobby_code_label: Label = $LobbyCodeLabel
@onready var difficulty_label: Label = $DifficultyLabel
@onready var player_list_label: Label = $PlayerList/PlayerID
@export var selected_difficulty: String = ""

func set_difficulty(difficulty):
	selected_difficulty = difficulty
	difficulty_label.text = "Difficulty: " + difficulty
	network_manager.selected_difficulty = difficulty  


func _on_start_button_pressed():
	if !multiplayer.is_server():
		print("❌ You are not the host!")
		return
		
	print("📜 Current player list:", network_manager.player_list)
	print("🔢 Number of players:", network_manager.player_list.size())
	
	if multiplayer.is_server() and network_manager.player_list.size() >= 2:
		print("Game Starting with difficulty:", selected_difficulty)
		network_manager.start_game.rpc(selected_difficulty)
	else:
		print("❌ Not enough players to start the game.")


func _ready():
	var game_difficulty = network_manager.selected_difficulty
	print("Game started with difficulty:", game_difficulty)
	
	if network_manager == null:
		print("❌ Error: NetworkManager not found!")
		return
		
	if lobby_code_label:
		lobby_code_label.text = "Lobby Code: " + str(network_manager.lobby_code)
	else:
		print("❌ Error: LobbyCodeLabel not found!")
		
	network_manager.lobby_updated.connect(_update_lobby_display)
	print("✅ Lobby code:", network_manager.lobby_code)
	
	if !start_button:
		print("❌ Error: Start_Button not found!")
		return
		
	if !multiplayer.is_server():
		start_button.hide()
		var player_game = "Player" + str(randi() % 1000)
		network_manager.join_lobby.rpc(player_game)
	else:
		start_button.show()
	
func _update_lobby_display():
	print("📜 Updating lobby display... Players:", network_manager.player_list)
	
	player_list_label.text = "Players in Lobby:\n"
	for peer_id in network_manager.player_list:
		player_list_label.text += str(peer_id) + " - " + network_manager.player_list[peer_id + "\n"]
	
	if player_list_label:
		player_list_label.text = "Players in Lobby:\n"
		
		for peer_id in network_manager.player_list:
			var player_name = network_manager.player_list[peer_id]
			player_list_label.text += str(peer_id) + " - " + player_name + "\n"
			
		print("Updated player list:", player_list_label.text)
		
	else:
		print("❌ Error: PlayerListLabel not found!")
		
	if multiplayer.is_server():
		start_button.disabled = !(network_manager.player_list.size() >= 2 and network_manager.player_list.size() <= 4)
		print("✅ Lobby updated!")
		print("✅ Current player list:", network_manager.player_list)
