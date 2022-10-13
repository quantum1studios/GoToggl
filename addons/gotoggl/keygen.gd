@tool
extends HBoxContainer

var togglkey = "res://addons/gotoggl/togglkey.json"

var win_dialog: Window

var t_api: TextEdit
var t_workspace: TextEdit
var t_project: TextEdit
var t_desc: TextEdit

var b_confirm: Button
signal updated_gen

func _enter_tree() -> void:
	win_dialog = get_node("windialog")
	t_api = get_node("windialog/vbox/t_api")
	t_workspace = get_node("windialog/vbox/t_workspace")
	t_project = get_node("windialog/vbox/t_project")
	t_desc = get_node("windialog/vbox/t_description")
	b_confirm = get_node("windialog/vbox/b_confirm")

	b_confirm.connect("pressed",Callable(self,"_confirm"))
	win_dialog.connect("visibility_changed",Callable(self,"_clear_lines"))

func show_gen():
	# If the togglkey already exists we show the current values
	var file = File.new()
	if file.file_exists(togglkey):
		var json = JSON.new()
		var error = json.parse(read_file(togglkey))
		var dict = json.get_data()

		if dict.keys().find("api_token") != -1:
			t_api.text = dict["api_token"]

		if dict.keys().find("workspace_id") != -1:
			t_workspace.text = str(dict["workspace_id"])

		if dict.keys().find("project_id") != -1:
			t_project.text = str(dict["project_id"])
		
		if dict.keys().find("description") != -1:
			t_desc.text = dict["description"]
		else:
			t_desc.text = "GoToggl Entry"

	win_dialog.show()
	win_dialog.popup_centered()

func get_api() -> String:
	return t_api.get_text()

func get_workspace() -> int:
	return t_workspace.get_text().to_int()

func get_project() -> int:
	return t_project.get_text().to_int()

func get_desc() -> String:
	return t_desc.get_text()

func _confirm() -> void:
	if get_api().is_empty():
		print("GoToggl: Missing or Invalid API Token")
		return
	
	if t_workspace.text.is_empty() || !t_project.text.is_valid_int():
		print("GoToggl: Missing or Invalid Workspace ID")
		return

	if t_project.text.is_empty() || !t_project.text.is_valid_int():
		print("GoToggl: Missing or Invalid Project ID")
		return

	var keyDict := {
		"api_token": get_api(),
		"workspace_id": get_workspace(),
		"project_id": get_project(),
		"description": get_desc(),
	}
	write_file(togglkey, JSON.stringify(keyDict))
	win_dialog.hide()
	await get_tree().create_timer(1).timeout
	emit_signal("updated_gen")

func _clear_lines():
	if win_dialog.visible:
		return
	
	t_api.text = ""
	t_workspace.text = ""
	t_project.text = ""
	t_desc.text = ""

func write_file(file_name, string:String):
	var file = File.new()
	file.open(file_name, File.WRITE)
	file.store_string(string)
	file.close()

func read_file(file_name) -> String:
	var file = File.new()
	file.open(file_name, file.READ)
	var keyText = file.get_as_text()
	file.close()
	return keyText
