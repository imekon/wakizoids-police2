extends PanelContainer

onready var list = $Panel/ItemList

func scan_miners():
	var ships = get_tree().get_nodes_in_group("mining_ship")
	for ship in ships:
		list.add_item(ship.get_parent().registration)