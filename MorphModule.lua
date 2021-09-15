local CollectionService: CollectionService = game:GetService("CollectionService")

local MORPH_OBJECT_TAG_NAME: string = "MorphModuleObject"

local Constructors = {}

local Morph = {}
Morph.__index = Morph

local function clearCharacterAppearance(character: Model, doAccessories: boolean?, doClothes: boolean?, doFaces: boolean?)
	if not character then
		warn(debug.traceback("Cannot clear character appearance: no model specified"))
		return
	elseif not doAccessories and not doClothes and not doFaces then
		warn(debug.traceback("No appearance items to clear"))
		return
	end

	local humanoid: Instance? = character:FindFirstChildOfClass("Humanoid")

	if doAccessories and humanoid then
		(humanoid :: Humanoid):RemoveAccessories()
	end

	if doClothes then
		for _: number, object: Instance in ipairs((character :: Model):GetChildren()) do
			if object:IsA("Clothing") then
				object:Destroy()
			elseif doAccessories and object:IsA("Accessory") then
				-- Take advantage of the loop to remove accessories that couldn't be removed
				-- if a Humanoid didn't exist to call RemoveAccessories on
				object:Destroy()
			end
		end
	end
	
	if doFaces then
		for _, Face in ipairs(character.Head):GetChildren()) do
			if Face:Isa("Texture") or Face:Isa("Decal") then
				Face:Destroy()
			end
		end
	end
end

-- Required properties like Folder will be nil at a class-level
-- Expose constructors instead to work with morphs
function Constructors.new(folder: Folder)
	if not folder then
		warn(debug.traceback("No folder specified; no object created from constructor"))
		return
	end

	return setmetatable({
		Folder = folder
	}, Morph)
end

function Morph:_SeekFolder(folderName: string): Folder?
	if not folderName then
		-- Traceback provided by function calling _SeekFolder
		return nil
	end

	for _, object in ipairs(self.Folder:GetDescendants()) do
		if object:IsA("Folder") and object.Name == folderName then
			return object
		end
	end
	return nil
end

function Morph:ApplyFullMorph(player: Player, folderName: string, includeClothes: boolean?, includeFaces: boolean?)
	local character: Model
	local humanoid: Humanoid
	local selectedFolder: Folder = self:_SeekFolder(folderName)

	if not selectedFolder then
		warn(debug.traceback(string.format("No morph named %s exists", folderName or "null")))
		return
	elseif not player then
		warn(debug.traceback("No player specified"))
		return
	elseif not character then
		character = player.Character :: Model
		if not character then
			warn(debug.traceback(string.format("%s does not have a character", player.Name)))
			return
		end
	else
		humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid
		if not humanoid then
			warn(debug.traceback(string.format("%s does not have a Humanoid", player.Name)))
			return
		end
	end

	clearCharacterAppearance((character :: Model), true, includeClothes)

	for _: number, item: Instance in ipairs(selectedFolder:GetChildren()) do
		if item:IsA("Accessory") then
			local newAccessory = item:Clone()
			CollectionService:AddTag(newAccessory, MORPH_OBJECT_TAG_NAME)
			humanoid:AddAccessory(newAccessory)
		elseif includeClothes and item:IsA("Clothing") then
			local newClothing = item:Clone()
			CollectionService:AddTag(newClothing, MORPH_OBJECT_TAG_NAME)
			newClothing.Parent = character
		elseif includeFaces and item:IsA("Decal") or item:IsA("Texture") then
			local NewFace = item:Clone()
			CollectionService:AddtAG(NewFace, MORPH_OBJECT_TAG_NAME)
			NewFace.Parent = character.Head
		end
	end
end

function Morph:ApplyMorph(player: Player, folderName: string)
	self:ApplyFullMorph(player, folderName, false)
end

function Morph:RemoveFullMorph(player: Player, doClothes: boolean?, doFaces: boolean?)
	local character: Model

	if not player then
		warn(debug.traceback("No player specified"))
		return
	elseif not character then
		character = player.Character :: Model
		if not character then
			warn(debug.traceback(string.format("%s does not have a character", player.Name)))
			return
		end
	end

	for _: number, item: Instance in ipairs((character :: Model):GetChildren()) do
		if item:IsA("Accessory") and CollectionService:HasTag(item, MORPH_OBJECT_TAG_NAME) then
			item:Destroy()
		elseif doClothes and item:IsA("Clothing") and CollectionService:HasTag(item, MORPH_OBJECT_TAG_NAME) then
			item:Destroy()
		end
	end

	if doFaces then
		for _, Face in ipairs(character):GetChildren()) do
			if Face:IsA("Texture") or Face:Isa("Decal") then
				Face:Destroy()
			end
		end
	end

end

function Morph:RemoveMorph(player: Player)
	self:RemoveFullMorph(player, false)
end

function Morph:Destroy()
	self.Folder = nil
	setmetatable(self, nil)
end

print("MorphModule v1 fully loaded!")

return Constructors
