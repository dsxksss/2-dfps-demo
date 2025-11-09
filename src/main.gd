# 主游戏场景脚本
# 继承自 Node，这是 Godot 中最基础的节点类型
extends Node

# 定义玩家场景资源
# PackedScene 是预加载的场景资源类型
# "uid://fb27g4i45gam" 是玩家场景的唯一标识符（UID）
# 这个场景会在需要生成玩家时被实例化
var player_scene: PackedScene = preload("uid://fb27g4i45gam")

# @onready 变量会在节点进入场景树后自动初始化
# MultiplayerSpawner 是 Godot 多人游戏系统中用于同步生成节点的组件
# 它可以确保在所有客户端上同步生成相同的节点
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

# _ready() 在节点进入场景树后自动调用一次
func _ready() -> void:
	# 设置生成函数，这个函数定义了如何创建玩家实例
	# spawn_function 是一个回调函数，当需要生成玩家时会被调用
	# data 参数包含了生成时传递的数据（在这里是 peer_id）
	multiplayer_spawner.spawn_function = func(data):
		# 实例化玩家场景
		# instantiate() 方法会创建一个场景的实例
		# as Player 是类型转换，确保返回的是 Player 类型的对象
		var player = player_scene.instantiate() as Player
		# 设置玩家节点的名称
		# str() 将数字转换为字符串，使用 peer_id 作为名称，方便识别不同的玩家
		# peer_id 是每个客户端/服务器的唯一标识符（1 是服务器，其他数字是客户端）
		player.name = str(data.peer_id)
		# 设置玩家的多人游戏权限
		# 将玩家的控制权限设置为对应的 peer_id
		# 这样每个客户端只能控制自己的玩家，服务器（peer_id = 1）可以控制所有玩家
		player.input_multiplayer_authority = data.peer_id
		# 返回创建的玩家实例
		# MultiplayerSpawner 会将这个实例添加到场景树中
		return player

	# 调用 RPC 函数，通知服务器这个客户端已经准备好了
	# rpc_id(1) 表示只发送给 ID 为 1 的节点（通常是服务器）
	# 这样服务器就知道有新的客户端连接，可以为其生成玩家
	peer_ready.rpc_id(1)



# 定义远程过程调用（RPC）函数
# @rpc 是 Godot 的 RPC 注解，用于标记可以被远程调用的函数
# "any_peer" 表示任何客户端或服务器都可以调用这个函数
# "call_local" 表示本地也会执行这个函数（不仅远程调用）
# "reliable" 表示使用可靠的传输方式（确保消息一定会到达，但可能较慢）
# 如果不加 "reliable"，默认是 "unreliable"（快速但不保证到达）
@rpc("any_peer", "call_local", "reliable")
func peer_ready():
	# 获取发送 RPC 调用的远程客户端 ID
	# get_remote_sender_id() 返回调用这个函数的客户端的 peer_id
	var sender_id = multiplayer.get_remote_sender_id()
	# 为发送请求的客户端生成玩家
	# spawn() 方法会调用之前设置的 spawn_function，并传递数据
	# {"peer_id": sender_id} 是一个字典，包含要传递给生成函数的数据
	# 这样每个客户端都会在自己的场景中生成对应的玩家实例
	multiplayer_spawner.spawn({"peer_id": sender_id})
