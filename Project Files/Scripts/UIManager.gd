extends CanvasLayer

var current_menu = ""


func change_menu(new_menu):
	if current_menu != "" and new_menu != "": return
	
	current_menu = new_menu
