extends "res://CharacterPuppets/Scripts/Puppets/TopDownPuppet2D.gd"

var xp = 0 #XP is gained from multiple actions and contributes to leveling up the ship

var level = 1 #Level is how far along you are in ship development
#Level Documentation
#Level 1-5 is planetary travel
#Level 6+ will be space travel if I decide to make it that far later on

var can_move : bool = false


