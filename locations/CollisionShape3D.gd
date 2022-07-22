extends CollisionShape3D
@export_node_path(Resource) var bone

# Called when the node enters the scene tree for the first time.
func _ready():
	bone = get_node("../CharacterArmature/Skeleton3D/Position3D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = Vector3(0, bone.position.y + 0.2, 0)
	self.shape.height = bone.position.y * 2 + 0.2
	pass
