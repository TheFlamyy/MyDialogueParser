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

----

### File structure

The example file can be found [here](https://github.com/TheFlamyy/MyDialogueParser/blob/master/mdp-demo/Demo.json). It's assumed that you are familiar with the basic JSON-notation.


Almost all fields are user/developer based.

The code relevant fields are listed below:

| Field | Type | Description |
| ---- | ---- | ---- |
| `_next` | `Array` or `Dictionary` | Determines what the next dialogue will be. If an `Array` (with a size bigger than 1) is used, choices will be assumed |

----

## Roadmap

Since this is a personal project the following roadmap is subject to change and might not be fulfilled.

- [ ] Conditional dialogue
- [ ] `jump_to` in order to jump to a specific `path` in the dialogue (function/`_next`)