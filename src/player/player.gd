# 定义玩家类，类名可以在整个项目中直接使用（不需要路径）
# 继承自 CharacterBody2D，这是 Godot 4 中用于角色控制的节点类型
# CharacterBody2D 提供了物理移动相关的方法，如 move_and_slide()
class_name Player
extends CharacterBody2D

# @onready 关键字表示这些变量会在节点进入场景树后自动初始化
# 也就是说，当场景加载完成后，$ 符号会找到子节点并赋值给这些变量
# $ 符号是 get_node() 的简写，用于获取子节点
# PlayerInputSynchronizerComponent 是处理玩家输入同步的组件
@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent
# WeaponRoot 是武器根节点，用于控制武器的旋转和位置
@onready var weapon_root: Node2D = $WeaponRoot

# 存储这个玩家实例的多人游戏权限 ID
# 在多人游戏中，每个玩家实例都有一个权限 ID，只有拥有权限的客户端才能控制该玩家
var input_multiplayer_authority: int

# 定义玩家移动速度常量（像素/秒）
# const 表示这是一个常量，值不会改变
# 使用 300.0 表示每秒移动 300 像素
const SPEED = 300.0

# _ready() 是 Godot 的生命周期函数，在节点进入场景树后自动调用一次
# 这里用于初始化多人游戏的权限设置
func _ready() -> void:
	# 设置输入同步组件的多人游戏权限
	# 只有拥有权限的客户端才能处理这个玩家的输入
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)

# _process() 是 Godot 的生命周期函数，每帧都会调用一次
# _delta 参数表示上一帧到这一帧的时间间隔（秒），虽然这里用下划线表示未使用
func _process(_delta: float) -> void:
	# 计算武器的瞄准位置
	# weapon_root.global_position 是武器根节点的全局位置（世界坐标）
	# player_input_synchronizer_component.aim_vector 是从输入组件获取的瞄准方向向量
	# 将位置和方向向量相加，得到最终的瞄准目标位置
	var aim_position = weapon_root.global_position + player_input_synchronizer_component.aim_vector
	
	# 让武器根节点朝向瞄准位置
	# look_at() 方法会让节点旋转，使其朝向指定的目标位置
	weapon_root.look_at(aim_position)

	# 检查当前客户端是否拥有这个玩家实例的控制权限
	# 在多人游戏中，只有拥有权限的客户端才应该处理移动逻辑
	# 这样可以避免多个客户端同时控制同一个玩家，造成冲突
	if is_multiplayer_authority():
		# 设置玩家的移动速度
		# velocity 是 CharacterBody2D 的属性，表示当前的速度向量
		# movement_vector 是从输入组件获取的移动方向向量（通常是归一化的，长度为1）
		# 乘以 SPEED 得到实际的移动速度向量
		velocity = player_input_synchronizer_component.movement_vector * SPEED
		
		# 应用移动并处理碰撞
		# move_and_slide() 会根据 velocity 移动角色，并自动处理与墙壁等障碍物的碰撞
		# 这是 CharacterBody2D 提供的物理移动方法
		move_and_slide()
