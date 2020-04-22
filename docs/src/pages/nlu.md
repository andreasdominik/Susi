# NLU

The NLU component replaces the Snips NLU and is independent from the
Snips console.
It is configured only with a configuration file `nlu.xx.toml` for
each skill, where 'xx'
denotes a 2-letter language code. The nlu configuration files must be present
somewhere in the skill's mother or sundiretories.

### Format of the NLU definition file

The nlu.xx.toml file includes the parts:

#### Head

The head defines the name of the configured skill and the name of the skill
developer (the developer name is used to generate Snips-compatible
intent names).

The inventory section lists all intents and slots configured and
used in the file:

```
# head:
#
skill = "RollerShutter"
developer = "andreasdominik"

[inventory]
slots = ["room", "device", "Action"]
intents = ["RollerUpDown"]
```

#### Slot definitions

The scope slot definitions is one skill; i.e. a defined slot can be
used in all intents of a skill.

For each listed slot, a slot definition section must be present in the
toml file, including the keys `slot_type`, optional `allow_empty` and
optional sub-section `slotname.synonyms`:

```
# slot definitions:
#
[room]
slot_type = "ListOfValues"
allow_empty = true

        [room.synonyms]
        "house" = ["everywhere", "in the house", "house"]
        "dining" = ["dining room", "dining"]
        "stairs" = ["staircase", "stairs"]
        "kitchen" = "kitchen"
        "bedroom" = ["bedroom", "parents bedroom"]
```

**slot_type** is one of 'ListOfValues', 'Any', 'Number', 'Ordinal' or 'Time';
see below for details.    
If **allow_empty** is specified as true, an expression will match, even if the
slot is not parsed. If the key 'allow_empty' is missing, the default
`false` is assumed.

##### Slot type `ListOfValues`

A slot type `ListOfValues` needs a mandatory subsection with synonymes,
consisting of alternatives with a name and a list of values.
In contrast to Snips, the names are not included in the list.

When parsing a command the slot will match if one of the words or phrases
in one of the lists is recognised and the name of the respective
synonym is returned as slot value.
This way it is easy to write language-independent skill code, because
the returned slot values are indepentent from the actual parsed commands.


##### Slot type `Any`

A slot of tyle `Any` will match any word or phrase.

In addition it is possible to add synonyms to a slot of type `Any`.


##### Slot types `Number`, `Ordinal` and `Time`

Slots of one of these types will be extracted from the command
and passed to Duckling to get a number or timestring.


#### Intent definition
The last part of the configuration file holds *match phrases*, which are
compared with transcribed commands to identify intents (actions to be
executed within skills) and to extract slot values.
The following rules apply:
* each intent is configured in a separate section of the toml file
  `[intentname]`
* several match phrases may be defined for each intent
* each match phrase constists of a *name*, a *type* and the phrase to be
  matched
* match phrases are matched in alphabetic order of their names
* a match phrase can be of type `regex`, `complete`, `partial` or
  `ordered`.

##### match phrase type `regex`
It is possible to write match phrases as Perl-compatible regular expresisons
with a syntax, provided by the PCRE library (see http://www.pcre.org/current/doc/html/pcre2syntax.html for the syntax).
Slots are defined as named capture groups with the slot name as capture
group name.


##### match phrase type `complete`
Instead of writing plain regular expressions, the types
`complete`, `partial` and `ordered` provide an simplified syntax.
However, every *match phrase* will eventually be translated into a regular expression.
For this reason it is possible to use default regular expresison syntax in any place
(in match phrases, word lists and synonym lists).

For `complete`, the phrase is a sentence that must
match completely, with several types of placeholders allowed:

* **<<slotname>>:** the slot value is expected at this position.
  If the slot is configured as `allow_empty = true`, the phrase will
  match even if the slot is not present.
* **<<word1|words and more|word3>>:** one of the listed words or phrases
  is expected at this position. Words are separated by the pipe charater `|`.
  An empty alternative (<<word1|words and more|>> or <<word1||words and more>>)
  will match missing words as well.
* **<<>>:** the empty placeholder will match exactly one or no words.

Examples:    
the match phrase  
```
[RollerUpDown]
roller_a = "complete: <<action>> the <<rollershutter|roller>> <<in|>> <<the|>> <<room>>"
```
will match the commands `"Open the rollershutter in the kitchen"` and
`"Open the rollershutter in kitchen"` as well as
`"Open the rollershutter"`, because the placeholders "<<in|>>" and "<<the|>>" allow
empty values and "<<room>>" is allowed to be empty as well.

However the match phrase will **not** match
`"Please open the rollershutter in the kitchen"`, because not the complete
phrase matches.

To be more specific optional words may be added, such as
```
roller_b = "complete: <<please|>> <<action>> the <<rollershutter|roller>> <<in|>> <<the|>> <<room>> <<please|>>"
```

##### match phrase type `partial`
Match phrases of type `partial` follow the same rules as of type `complete`,
with the difference that only parts of the command must match the phrase.

Examples:
the match phrase
```
[RollerUpDown]
roller_b = "partial: <<action>> the <<rollershutter|roller>> <<in|>> <<the|>> <<room>>"
```
will match `"Please open the rollershutter in the kitchen"`
as well as `"Please open the rollershutter in the kitchen and get me a coffee"`.


##### match phrase type `ordered`
Match phrases of type `ordered` follow the same rules but are much more
vague, as only all elements of the match phrase must be present in the
command in the correct order. Additional words may be occure before,
after or inbetween the specified elements.


#### Example file nlu.xx.toml for the rollershutter skill:

A complete (but very simple and not yet sufficent) example nlu configuration
file is shown in versions for 3 different languages.
It must be pointet out, that the slot values extracted to the intent
and sent to the skill code
are exactly the same for all languages, which makes it easy to
write language-intependant skill code.


##### nlu.en.toml
```
# nlu definition for RollerShutter skill
#
# head:
#
skill = "RollerShutter"
developer = "andreasdominik"

[inventory]
intents = ["RollerUpDown"]
slots = ["room", "action"]


# slot definitions:
#
[room]
slot_type = "ListOfValues"
allow_empty = true

        [room.synonyms]
        "house" = ["everywhere", "in the house", "house"]
        "dining" = ["dining room", "dining"]
        "stairs" = ["staircase", "stairs"]
        "kitchen" = "kitchen"
        "bedroom" = ["bedroom", "parents bedroom"]

[action]
slot_type = "ListOfValues"

        [action.synonyms]
        "open" = ["open", "up"]
        "close" = ["close", "down", "shut"]

# match phrases for intent recognion:
#
[RollerUpDown]
roller_a = "partial: <<action>> the <<rollershutter|roller>> <<in|>> <<the|>> <<room>>"
roller_b = "complete: <<please|>> make the <<rollershutter|roller>> in the <<room|>> <<room>> <<action>> <<please|>>"
roller_c = "partial: make the <<rollershutter|roller>> <<>> <<action>>"
```



##### nlu.fr.toml
```
# nlu definition for RollerShutter skill
#
# head:
#
skill = "RollerShutter"
developer = "andreasdominik"

[inventory]
intents = ["RollerUpDown"]
slots = ["room", "action"]


# slot definitions:
#
[room]
slot_type = "ListOfValues"
allow_empty = true

        [room.synonyms]
        "house" = ["partout dans la maison", "dans toute la maison", "maison"]
        "dining" = "salle à manger"
        "stairs" = ["cage d'escalier"]
        "kitchen" = "cuisine"
        "bedroom" = ["chambre"]

[action]
slot_type = "ListOfValues"

        [action.synonyms]
        "open" = ["ouvrir", "ouvrez"]
        "close" = ["fermez"]

# match phrases for intent recognion:
#
[RollerUpDown]
roller_a = "<<veuillez|>> <<action>> <<le volet roulant|les volets|le volet>> <<de la|dans la|>> <<room>> <<s'il vous plaît|>>"
```


##### nlu.de.toml
```
# nlu definition for RollerShutter skill
#
# head:
#
skill = "RollerShutter"
developer = "andreasdominik"

[inventory]
intents = ["RollerUpDown"]
slots = ["room", "action"]


# slot definitions:
#
[room]
slot_type = "ListOfValues"
allow_empty = true

        [room.synonyms]
        "house" = ["überall", "im ganzen Haus", "Haus"]
        "dining" = "Esszimmer"
        "stairs" = ["Treppenhaus", "Treppe"]
        "kitchen" = "Küche"
        "bedroom" = ["schlafzimmer"]

[action]
slot_type = "ListOfValues"

        [action.synonyms]
        "open" = ["auf", "nach oben", "öffne"]
        "close" = ["zu", "herunter", "runter", "schließe"]

# match phrases for intent recognion:
#
[RollerUpDown]
roller_a = "partial: <<bitte|>> <<action>> <<bitte|>> den <<Rolladen|Rollo>> <<in der|im|>> <<room>>"
roller_c = "partial: mach <<bitte|>> den <<Rolladen|Rollo>> <<in der|im>> <<room>> <<action>>"
roller_d = "partial: mach <<bitte|>> den <<Rolladen|Rollo>> <<action>>"
```
