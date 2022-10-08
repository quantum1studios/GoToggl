tool
extends EditorPlugin

var togglkey = "res://addons/gotoggl/togglkey.json"
var keyDict = {}

var authToken: String
var apiKey: String
var workspace: int
var project: int
var description: String

var dialog_scene = preload("res://addons/gotoggl/keysetup.tscn")
var dialog
var button_scene = preload("res://addons/gotoggl/GoTogglLogo.tscn")
var button
var b_toggl: Button
var b_toggl_inactive = preload("res://addons/gotoggl/toggl-logo.png")
var b_toggl_active = preload("res://addons/gotoggl/toggl-logo-active.png")
var is_Initialized: bool = false
var isActive: bool = false

var editorNode
var httpContainer: VBoxContainer
var httpClient: HTTPRequest
var headers

var time_start = 0
var time_end = 0
var datetime: Dictionary

func _enter_tree() -> void:
	editorNode = get_tree().root.get_node("EditorNode")
	dialog = dialog_scene.instance()
	dialog.connect("updated_gen", self, "setup")
	editorNode.add_child(dialog)
	add_tool_menu_item("GoToggl Wizard", self, "_show_gen")

	httpContainer = VBoxContainer.new()
	httpClient = HTTPRequest.new()
	httpContainer.add_child(httpClient)
	editorNode.add_child(httpContainer)
	httpClient.connect("request_completed", self, "_on_request_completed")

	var file = File.new()
	if file.file_exists(togglkey):
		setup()
	else:
		print("GoToggl: togglkey.json does not exist. Generate using Project > Tool > GoToggl Wizard.")
	pass

func setup():
	var file = File.new()
	file.open(togglkey, file.READ)
	var keyText = file.get_as_text()
	keyDict = JSON.parse(keyText).result
	file.close()

	if keyDict.keys().find("api_token") == -1:
		print("GoToggl: api_token not found, please check GoToggl Wizard or togglkey.json")
		return
	apiKey = keyDict["api_token"]

	if keyDict.keys().find("workspace_id") == -1:
		print("GoToggl: workspace_id not found, please check GoToggl Wizard or togglkey.json")
		return
	workspace = keyDict["workspace_id"]

	if keyDict.keys().find("project_id") == -1:
		print("GoToggl: project_id not found, please check GoToggl Wizard or togglkey.json")
		return
	project = keyDict["project_id"]

	if keyDict.keys().find("description") == -1:
		description = "GoToggl Entry"
	else:
		description = keyDict["description"]

	_authenticate()

func _exit_tree() -> void:
	remove_tool_menu_item("GoToggl Wizard")
	httpContainer.queue_free()
	httpContainer.free()
	dialog.queue_free()
	dialog.free()

	if is_Initialized:
		remove_control_from_container(0, button)
		button.queue_free()
		button.free()
	pass

func _authenticate():
	authToken = "Basic "
	var newKey = apiKey + ":api_token"
	newKey = Marshalls.utf8_to_base64(newKey)
	authToken += newKey

	headers = ["Content-Type: application/json", "Authorization: " + authToken]
	httpClient.request("http://api.track.toggl.com/api/v9/me", headers, true, HTTPClient.METHOD_GET)

func _post_time():
	var url = ("http://api.track.toggl.com/api/v9/workspaces/" + str(workspace) + "/time_entries")
	var body := {
		"description": description,
		"created_with": "GoToggl",
		"wid": workspace,
		"tags": ["billed"],
		"duration": time_end - time_start,
		"start": "%04d-%02d-%02dT%02d:%02d:%02d.000Z" % [datetime["year"], datetime["month"], datetime["day"], datetime["hour"], datetime["minute"], datetime["second"]],
		"pid": project,
	}
	var query = JSON.print(body)
	httpClient.request(url, headers, true, HTTPClient.METHOD_POST, query)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())

	if json.error == OK:
		if json.result.keys().find("default_workspace_id") != -1:
			print("GoToggl Authenticated")
			if !is_Initialized:
				button = button_scene.instance()
				add_control_to_container(0, button)
				b_toggl = button
				b_toggl.flat = true
				b_toggl.connect("pressed", self, "_button_pressed")
				is_Initialized = true

func _button_pressed():
	if !isActive: #start the counter
		_set_icon(true)
		time_start = OS.get_unix_time()
		datetime = OS.get_datetime()
	else: #reset counter and submit time to Toggl
		_set_icon(false)
		time_end = OS.get_unix_time()
		_post_time()

func _set_icon(active:bool):
	isActive = active
	if active:
		b_toggl.icon = b_toggl_active
	else:
		b_toggl.icon = b_toggl_inactive

func _show_gen(i):
	dialog.call("show_gen")