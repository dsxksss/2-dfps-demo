# 主菜单界面脚本
# 继承自 Control，这是 Godot 中用于 UI 界面的基础节点类型
extends Control

# @onready 变量会在节点进入场景树后自动初始化
# 获取"创建主机"按钮的引用
# $HBoxContainer/HostButton 表示在 HBoxContainer 子节点下的 HostButton 按钮
@onready var host_button: Button = $HBoxContainer/HostButton
# 获取"加入游戏"按钮的引用
@onready var join_button: Button = $HBoxContainer/JoinButton

# 定义主游戏场景的常量
# PackedScene 是 Godot 中预加载的场景资源类型
# preload() 在脚本加载时就预加载资源，确保资源可用
# "uid://q6hvr2r8w212" 是场景的唯一标识符（UID），在 Godot 编辑器中可以看到
const main_scene: PackedScene = preload("uid://q6hvr2r8w212")
# 定义网络端口号常量
# := 是类型推断的简写，等同于 const PORT: int = 4242
# 4242 是服务器监听的端口号，客户端连接时也需要使用相同的端口
const PORT := 4242

# _ready() 在节点进入场景树后自动调用一次
# 这里用于连接信号，设置按钮点击事件和网络连接事件
func _ready() -> void:
	# 连接"创建主机"按钮的 pressed 信号到处理函数
	# 当按钮被点击时，会调用 _on_host_button_pressed() 函数
	host_button.pressed.connect(_on_host_button_pressed)
	# 连接"加入游戏"按钮的 pressed 信号到处理函数
	join_button.pressed.connect(_on_join_button_pressed)
	# 连接多人游戏系统的 connected_to_server 信号
	# 当客户端成功连接到服务器时，会调用 _on_connected_to_server() 函数
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	

# "创建主机"按钮被点击时的处理函数
func _on_host_button_pressed() -> void:
	# 在控制台输出调试信息
	print("Host button pressed")
	# 创建 ENet 多人游戏对等体对象
	# ENet 是一个轻量级的网络库，Godot 用它来实现多人游戏网络通信
	var server_peer := ENetMultiplayerPeer.new()
	# 创建服务器，监听指定的端口
	# 其他玩家可以通过这个端口连接到服务器
	server_peer.create_server(PORT)
	# 将创建的服务器对等体设置为多人游戏系统的对等体
	# 这样 Godot 的多人游戏系统就会使用这个服务器来处理网络通信
	multiplayer.multiplayer_peer = server_peer
	# 切换到主游戏场景
	# get_tree() 获取场景树，change_scene_to_packed() 切换到指定的场景
	# 作为主机，创建服务器后立即进入游戏场景
	get_tree().change_scene_to_packed(main_scene)

# "加入游戏"按钮被点击时的处理函数
func _on_join_button_pressed() -> void:
	# 在控制台输出调试信息
	print("Join button pressed")
	# 创建 ENet 多人游戏对等体对象
	var client_peer := ENetMultiplayerPeer.new()
	# 创建客户端，连接到指定的服务器地址和端口
	# "localhost" 表示本地主机（127.0.0.1），如果是连接远程服务器，需要改为服务器的 IP 地址
	# PORT 是服务器监听的端口号，必须与服务器使用的端口一致
	client_peer.create_client("localhost", PORT)
	# 将创建的客户端对等体设置为多人游戏系统的对等体
	multiplayer.multiplayer_peer = client_peer
	# 注意：这里不立即切换场景，而是等待连接成功后再切换
	# 连接成功后会触发 connected_to_server 信号，在 _on_connected_to_server() 中切换场景

# 客户端成功连接到服务器时的处理函数
# 这个函数会在 connected_to_server 信号触发时被调用
func _on_connected_to_server() -> void:
	# 切换到主游戏场景
	# 只有在成功连接到服务器后，客户端才会进入游戏场景
	get_tree().change_scene_to_packed(main_scene)
