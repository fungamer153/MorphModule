# MorphModule

A server-sided class that allows you to apply accessories to characters with ease.

# Use Instructions

This module is written with an OOP style. Simply place the source into a ModuleScript in a server-only environment (e.g. ServerScriptService) and require it. For making morphs compatible with this module, create one main morphs folder in ServerStorage. You can then create folders in that main folder which contain the accessories you want attachable to characters. Clothing assets can also be added here! Example layout:

```plain
ServerStorage
	Folder Morphs
		Folder General
			Accessory Beret
			Shirt GeneralShirt
		Folder Officer
		Folder Recruit
```

Make sure that folder names do not conflict with each other if they are children of the same parent! The module might get the incorrect morph folder.

Please note that this only works with accessories; models and individual parts should be added a different way.

# API

## Constructor

### Morph.new()

```lua
Morph.new(Folder morphFolder)
```

Creates a Morph object using the morphFolder as the main folder where all morphs are stored in. Generally only needs to be used once and stored; all other scripts can access this created object to morph characters.

## Methods

### Morph:ApplyMorph()

```lua
Morph:ApplyMorph(Player player, string name)
```

Applies accessories to a player's character by name if it exists. Sugar for Morph:ApplyFullMorph(Player, "MorphName", false).

### Morph:ApplyFullMorph()

```lua
Morph:ApplyFullMorph(Player player, string name, boolean includeClothes)
```

Applies accessories to a player's character by name if it exists with the option to include clothes.

### Morph:RemoveMorph()

```lua
Morph:RemoveMorph(Player player)
```

Removes any accessories from the character applied by this module. Sugar for Morph:RemoveFullMorph(Player, false).

\* RemoveMorph does not restore original player accessories and clothing.

### Morph:RemoveFullMorph()

```lua
Morph:RemoveFullMorph(Player player, boolean includeClothes)
```

Removes any accessories from the character applied by this module with the option to also destroy clothes.

\* RemoveFullMorph does not restore original player accessories and clothing.

### Morph:Destroy()

```lua
Morph:Destroy()
```

Detaches strong references and the metatable preventing it from being further used and preparing it for garbage collecting. Note that if any script still holds a strong reference to the Morph object it will not be garbage collected. Destruction can be checked with `getmetatable(object) == nil`.

# Licensing

There is no fee or copyright on this meaning that you can use it freely! Credit is not needed but would be appreciated since it supports my work.
