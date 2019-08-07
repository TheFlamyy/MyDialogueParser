# MyDialogueParser

This is a simple ".json-dialogue" parser. This plugin creates a custom node which is used to parse dialogue.


An example can be found in the [demo folder](https://github.com/TheFlamyy/MyDialogueParser/tree/master/mdp-demo).

----

## Documentation

The callbacks are handled by signals. The following list displays all available signals:

| Signal | Arguments | Description |
| ---- | ---- | ---- |
| `started` | | Emitted when the dialogue is started with either `start` or `force_advance` |
| `finished` | | Emitted when the dialogue is finished by either advancing to the end or invoking `end` |
| `advanced` | `dialogue: Dictionary` | Emitted when the dialogue is changed. `dialogue` is the new dialogue |
| `choices_emitted` | `choices: Array` | Emitted when the new dialogue contains multiple next dialogues. `choices` contains all the new dialogues |


The functionality relies on user calling methods. Here's a list of all exposed functions:

| Function | Return type | Arguments | Description |
| ---- | ---- | ---- | ---- |
| `force_advance` | `void` | `path: Array = [], choice: int = 0` | Starts the dialogue if it isn't active and behaves like the normal `advance` in other cases |
| `start` | `void` | `path: Array = []` | Starts the dialogue at the given `path` |
| `advance` | `void` | `choice: int = 0` | Advances the dialogue with the given choice if choices were available |
| `end` | `void` | | Pre-emptively exits the dialogue |
| `display` | `void` | | Emits the current dialogue. If choices are detected those will be emitted as well |
| `jump_to` | `void` | `id: String` | Finds and changes the current dialogue based on the `id` (Don't have the string start with `@` when calling the method directly) |
| `go_to` | `void` | `path: Array, relative: Dictionary = dialogue` | Starts at `relative` and loops through the path to determine the new current dialogue|
----

### File structure

The example file can be found [here](https://github.com/TheFlamyy/MyDialogueParser/blob/master/mdp-demo/Demo.json). It's assumed that you are familiar with the basic JSON-notation.


Almost all fields are user/developer based.

The code relevant fields are listed below:

| Field | Type | Description |
| ---- | ---- | ---- |
| `_next` | `Dictionary` | The next dialogue in the sequence |
| `_next` | `Array` | If the size is bigger than 1 a choice signal will be emitted otherwise the first element will be chosen as the next dialogue |
| `_next` | `String` | Can be either used as `go_to` (List of indices e.g. `0/1/0/3`) or as `jump_to` (`@_id_`) |
| `_id` | `String` | The unique identifier used for `jump_to` to find this dialogue |

----

## Roadmap

Since this is a personal project the following roadmap is subject to change and might not be fulfilled.

- [ ] _Conditional dialogue_ Should be up to the developer. Maybe include a demo with conditions
- [x] `jump_to` in order to jump to a specific `path` in the dialogue (function/`_next`)