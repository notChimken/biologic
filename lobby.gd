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


func _ready():
	if network_manager == null:
		print("❌ Error: NetworkManager not found!")
		return
		
	if lobby_code_label:
		lobby_code_label.text = "Lobby Code: " + str(network_manager.lobby_code)
	else:
		print("❌ Error: LobbyCodeLabel not found!")
		
	network_manager.lobby_updated.connect(_update_lobby_display)
	print("✅ Lobby code:", network_manager.lobby_code)
	
	if !multiplayer.is_server():
		var player_game = "Player" + str(randi() % 1000)
		network_manager.join_lobby.rpc(player_game)
	
	
func _update_lobby_display():
	if player_list_label:
		player_list_label.text = "Players in Lobby:\n"
		for name in network_manager.player_list.values():
			player_list_label.text += name + "\n"
		
	else:
		print("❌ Error: PlayerListLabel not found!")
		
	if multiplayer.is_server():
		start_button.disabled = !(network_manager.player_list.size() >= 2 and network_manager.player_list.size() <= 4)


func _on_start_button_pressed():
	if multiplayer.is_server() and network_manager.player_list.size() >= 2:
		print("Game Starting!")
		network_manager.start_game.rpc()
	else:
		print("❌ Not enough players to start the game.")
