extends Node

# Emitted when the dialogue is started
signal started()
# Emitted when the dialogue is ended
signal finished()

# Emitted when the dialogue is changed
signal advanced(dialogue)
# Emitted when choices appear. Use this to create a custom choice selection system
signal choices_emitted(choices)

export(String, FILE, "*.json") var dialogue_path setget set_dialogue_path

# The entirety of the loaded dialogue
var dialogue := {}

# The current dialogue
var current := {}

func set_dialogue_path(path: String) -> void:
	dialogue_path = path
	request_ready()


# Loads the dialogue and tries to convey important information in the debugger
func _ready() -> void:
	if !dialogue_path:
		push_warning("Empty dialogue path at \"%s\"" % get_path())
		return
	
	var file: File = File.new()
	var file_error := file.open(dialogue_path, File.READ)
	if file_error != OK:
		push_error("Could not load file \"\" in node \"\"" % [dialogue_path, get_path()])
		breakpoint
	
	var content := file.get_as_text()
	var json: JSONParseResult = JSON.parse(content)
	
	if json.error != OK:
		var message := "Invalid JSON in \"%s\" at line %s: \"%s\""
		push_error(message % [dialogue_path, json.error_line, json.error_string])
		breakpoint
	
	dialogue = json.result


# Starts the dialogue if it isn't active and behaves like the normal `advance` in other cases
func force_advance(path := [], choice := 0) -> void:
	if current:
		advance(choice)
	else:
		start(path)


# Starts the dialogue
# Optionally a start dialogue can be described
func start(path := []) -> void:
	emit_signal("started")
	
	current = dialogue
	for index in path:
		if current.next is Array:
			current = current.next[index]
		else:
			current = current.next
	
	display()


# Emits the current dialogue
# Furthermore if choices are available those will be emitted
func display() -> void:
	emit_signal("advanced", current)
	var next = current.get("_next")
	if next:
		if next is Array && next.size() > 1:
			emit_signal("choices_emitted", next)


# Advances the dialogue with the given choice if choices were available
func advance(choice := 0) -> void:
	if !current:
		return
	
	var next = current.get("_next")
	if next is Array:
		if next.size() == 1:
			next = next[0]
		elif next.size() > choice:
			next = next[choice]
	
	if next is Dictionary:
		current = next
		display()
	else:
		end()


# Pre-emptively exits the dialogue
func end() -> void:
	emit_signal("finished")
	current = {}