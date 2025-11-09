# 定义玩家输入同步组件类
# 继承自 MultiplayerSynchronizer，这是 Godot 多人游戏系统中用于同步数据的节点
# MultiplayerSynchronizer 会自动将标记的变量同步到所有客户端
class_name PlayerInputSynchronizerComponent
extends MultiplayerSynchronizer

# @export 关键字表示这个变量可以在编辑器中直接设置
# aim_root 是用于计算瞄准方向的根节点（通常是玩家节点或武器节点）
@export var aim_root: Node2D

# 移动方向向量，初始值为零向量（表示不移动）
# Vector2.ZERO 等同于 Vector2(0, 0)
# 这个变量会被 MultiplayerSynchronizer 自动同步到所有客户端
var movement_vector: Vector2 = Vector2.ZERO

# 瞄准方向向量，初始值为向右的方向向量
# Vector2.RIGHT 等同于 Vector2(1, 0)，表示向右
# 这个变量会被 MultiplayerSynchronizer 自动同步到所有客户端
var aim_vector: Vector2 = Vector2.RIGHT

# _process() 每帧都会调用
func _process(_delta: float) -> void:
	# 检查当前客户端是否拥有这个组件的控制权限
	# 只有拥有权限的客户端才应该收集输入，避免多个客户端同时处理输入造成冲突
	if is_multiplayer_authority():
		# 调用收集输入的函数
		gather_input()

# 收集玩家输入的函数
# 这个函数会读取键盘输入和鼠标位置，并更新移动和瞄准向量
func gather_input() -> void:
	# 获取移动方向向量
	# Input.get_vector() 会根据四个输入动作（左、右、上、下）返回一个归一化的方向向量
	# "player_left", "player_right", "player_up", "player_down" 是在项目设置中定义的输入动作名称
	# 返回的向量长度始终为 1（归一化），方向取决于按下的按键组合
	# 例如：同时按下右和上，会返回 (0.707, -0.707) 这样的对角线方向
	movement_vector = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	
	# 计算瞄准方向向量
	# aim_root.global_position 是瞄准根节点的全局位置（世界坐标）
	# aim_root.get_global_mouse_position() 获取鼠标在全局坐标系中的位置
	# direction_to() 方法计算从当前位置指向目标位置的方向向量（归一化，长度为1）
	# 这样可以得到从玩家位置指向鼠标位置的方向向量，用于武器瞄准
	aim_vector = aim_root.global_position.direction_to(aim_root.get_global_mouse_position())