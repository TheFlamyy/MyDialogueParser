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

# The table of all IDs
var _ids := {}

# The current dialogue
var current := {}

func set_dialogue_path(path: String) -> void:
	dialogue_path = path
	request_ready()


# Walks through the given dictionary and checks if it has a key with the given identifier. Adds the found dictionary to destination
func _check_ids(dict: Dictionary) -> void:
	for key in dict:
		var value = dict[key]
		if key == "_id":
			_ids[value] = dict
			continue
		
		if value is Array:
			for elem in value:
				if elem is Dictionary:
					_check_ids(elem)
		elif value is Dictionary:
			_check_ids(value)


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
	_check_ids(dialogue)


# Emits the current dialogue
# Furthermore if choices are available those will be emitted
func display() -> void:
	emit_signal("advanced", current)
	var next = current.get("_next")
	if next:
		if next is Array && next.size() > 1:
			emit_signal("choices_emitted", next)


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
	
	go_to(path)
	display()


# Advances the dialogue with the given choice if choices were available
func advance(choice := 0) -> void:
	if !current:
		return
	
	var next = current.get("_next")
	var advanced = null
	match typeof(next):
		TYPE_ARRAY:
			if next.size() == 1:
				advanced = next[0]
			elif next.size() > choice:
				advanced = next[choice]
		
		_:
			advanced = next
	
	match typeof(advanced):
		TYPE_DICTIONARY:
			current = advanced
		
		TYPE_STRING:
			if advanced.begins_with("@"):
				jump_to(advanced.substr(1, len(advanced) - 1))
			else:
				var path := []
				if advanced:
					for number in advanced.split("/"):
						path.append(int(number))
				
				go_to(path)
			
		_:
			current = {}
	
	
	if current:
		display()
	else:
		end()


# Goes to the dialogue's ID
func jump_to(id: String) -> void:
	if !_ids.has(id):
		push_error("Can't execute go_to. Missing id '%s' in file %s" % [id, dialogue_path])
		breakpoint 
	
	current = _ids[id]


# Goes down the given path from the given `relative` (default: dialogue)
# Won't work if the given path includes other `jump_to`s
func go_to(path: Array, relative := dialogue) -> void:
	current = relative
	for index in path:
		var next = current.get("_next")
		match typeof(next):
			TYPE_ARRAY:
				current = next[index]
			
			TYPE_DICTIONARY:
				current = next
			
			TYPE_STRING:
				push_error("Can't have a string in jump_to in file %s" % dialogue_path)
				breakpoint 


# Pre-emptively exits the dialogue
func end() -> void:
	emit_signal("finished")
	current = {}