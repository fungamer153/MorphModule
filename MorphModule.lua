local Morph = {}
Morph.__index = Morph

local Instructions = {
	[[Thank you for using the MorphModule provided be le_fishe, this module runs serverside meaning that you need to use server scripts in orde to require it
	or use any of It's functions.
	
	*There is no fee or copyright on this meaning that you can use it freely without needing to give me any ownership of your project! but it would be nice
	of you to at least credit me or keep this message here as it shows appreciation towards my work.
	
	**This only works for accessories which are in my opinion the easier option of doing morphs so using models or parts only won't work.**
	
	Here is the full list of thing you can do:
	
	.new(Morph folder name) -- Will set this as the default folder that all morphs are stored in, only needs to be ran once on a server script for the whole game
	
	:ApplyFullMorph(Player instance, Folder name, Clothes: true/false, Faces: true/false) -- This applies whole morph to the directed user in the first argument 
	:ApplyMorph(Player, Folder name) -- This only applies the morph but can be considered a faster way of applying as it doesn't check if you want clothes with it or not
	:RemoveWholeMorph(Player, Morph name aka the folder name) -- Removes the whole of the morph including the clothes with it without touching anything else that doesn't exist in the original folder
	:RemoveMorph(Player, Morph name aka the folder name) -- Removes only the morph without the clothes without touching any other accessories that aren't named the same at least
	
	Keep in mind that you need to create a folder inside ServerStorage named `Morphs` and from there you can split morphs into team folders or individual folders 
	than the script will find itself unless there are duplicate instances of those
	
	*Make sure that all of the morphs are unanchored or your character will get stuck in place!!*
	You can as well insert any shirts or pants inside the folder you want to be applied and they can be named anything you want.
	]]
}


function Morph.new(MorphFolder)
	local MorphStuff = {}
	setmetatable(MorphStuff, Morph)

	MorphStuff.MorphFolder = MorphFolder;

	return MorphStuff
end

function Morph:SeekFolder(Folder)
	for i,v in pairs(self.MorphFolder:GetDescendants()) do
		if v:IsA('Folder') then
			if v.Name == Folder then
				return v
			end
		end
	end
end

function Morph:RemoveNotNeededItems(plr, Accessories, Clothes)
	for i,Items in pairs(plr.Character:GetChildren()) do
		if Accessories then
			if Items:IsA("Accessory") then
				Items:Destroy()
			end
		end

		if Clothes then
			if Items:IsA("Pants") or Items:IsA("Shirt") then
				Items:Destroy()
			end
		end

	end
end

function Morph:ApplyMorph(Player, Folder)
	local SelectedFolder = self:SeekFolder(Folder)

	assert(Player and SelectedFolder, "Please specify the morph folder you want to use! or Specify the player you're targetting this at!")

	self:RemoveNotNeededItems(Player, true, false)

	for i,Item in pairs(SelectedFolder:GetChildren()) do
		if Item:IsA("Accessory") then
			local MorphPiece = Item:Clone()
			Player.Character.Humanoid:AddAccessory(MorphPiece)

			if MorphPiece.Name:gsub("%s", "") == "LeftUpperLeg" or MorphPiece.Name:gsub("%s", "") == "RightUpperLeg" or MorphPiece.Name:gsub("%s", "") == "LeftUpperArm" or MorphPiece.Name:gsub("%s", "") == "RightUpperArm"  then
				local Attachment = MorphPiece:FindFirstChild(MorphPiece.Name:sub(0, string.find(MorphPiece.Name:gsub("%s", ""), "Upper") - 1).. (string.find(MorphPiece.Name, "Leg") and "HipRigAttachment" or "ShoulderAttachment"), true)

				if Attachment then
					local CharacterAttachment = nil

					if Player.Character:FindFirstChild(MorphPiece.Name:gsub("%s", "")) then
						local priorityAttachment = Player.Character[MorphPiece.Name:gsub("%s", "")]:FindFirstChild(Attachment.Name)

						if priorityAttachment then
							CharacterAttachment = priorityAttachment
						end
					end

					if CharacterAttachment then
						local Weld = Instance.new("Weld")

						Weld.Name = "AccessoryWeld"
						Weld.C0 = CharacterAttachment.CFrame
						Weld.C1 = Attachment.CFrame
						Weld.Part0 = CharacterAttachment.Parent
						Weld.Part1 = Attachment.Parent

						pcall(function() MorphPiece.Handle:WaitForChild("AccessoryWeld", 1):Destroy() end)

						Weld.Parent = MorphPiece.Handle
					end
				end
			end
		end
	end
end

function Morph:RemoveMorph(Player, MorphName)

	assert(MorphName and Player, "Please make sure you pass over Player instance and morph you wanted to remove string")

	local SelectedFolder = self:SeekFolder(MorphName)
	local MorphItems = {}

	for i,v in pairs(SelectedFolder:GetChildren()) do
		if v:IsA('Accessory') then
			table.insert(MorphItems, v.Name)
		end
	end 

	for i,v in pairs(Player.Character:GetChildren()) do
		if v:IsA("Accessory") then
			if table.find(MorphItems, v.Name) then
				v:Destroy()
			end		
		end
	end		
end

function Morph:RemoveWholeMorph(Player, MorphName)

	assert(Player and MorphName, "Please make sure you pass over Player instance and morph you wanted to remove string")

	local SelectedFolder = self:SeekFolder(MorphName)
	local MorphItems = {}

	for i,v in pairs(SelectedFolder:GetChildren()) do
		if v:IsA('Accessory') or v:IsA("Pants") or v:IsA("Shirt") then
			table.insert(MorphItems, v.Name)
		end
	end 

	for i,v in pairs(Player.Character:GetChildren()) do
		if v:IsA("Accessory") or v:IsA("Pants") or v:IsA("Shirt") then
			if table.find(MorphItems, v.Name) then
				v:Destroy()
			end	
		end
	end		
end

function Morph:ApplyFullMorph(Player, Folder, Clothes, faces)
	local SelectedFolder = self:SeekFolder(Folder)

	assert(Player and SelectedFolder, "Please specify the morph folder you want to use! or Specify the player you're targetting this at!")

	if SelectedFolder == nil then
		assert("Specified folder doesn't exist. Please create the folder and use a string for the folder's name.")
	else
		self:RemoveNotNeededItems(Player, true, true)
		for i,Item in pairs(SelectedFolder:GetChildren()) do
			if Clothes == nil then
				assert("Please state if you want clothes to be applied as well. false = no, true = yes")
			else
				if Clothes then
					if Item:IsA("Pants") or Item:IsA("Shirt") then
						local ClonedUniform = Item:Clone()
						ClonedUniform.Parent = Player.Character
					end
				end

				if faces then
					if Player.Character.Head:FindFirstChildOfClass('Decal') then
						Player.Character.Head:FindFirstChildOfClass('Decal'):Destroy()
					end

					if Item:IsA('Decal') then
						local NewFace = Item:Clone()
						NewFace.Parent = Player.Character.Head
					end
				end

				if Item:IsA("Accessory") then
					local MorphPiece = Item:Clone()
					Player.Character.Humanoid:AddAccessory(MorphPiece)

					if MorphPiece.Name:gsub("%s", "") == "LeftUpperLeg" or MorphPiece.Name:gsub("%s", "") == "RightUpperLeg" or MorphPiece.Name:gsub("%s", "") == "LeftUpperArm" or MorphPiece.Name:gsub("%s", "") == "RightUpperArm"  then
						local Attachment = MorphPiece:FindFirstChild(MorphPiece.Name:sub(0, string.find(MorphPiece.Name:gsub("%s", ""), "Upper") - 1).. (string.find(MorphPiece.Name, "Leg") and "HipRigAttachment" or "ShoulderAttachment"), true)

						if Attachment then
							local CharacterAttachment = nil

							if Player.Character:FindFirstChild(MorphPiece.Name:gsub("%s", "")) then
								local priorityAttachment = Player.Character[MorphPiece.Name:gsub("%s", "")]:FindFirstChild(Attachment.Name)

								if priorityAttachment then
									CharacterAttachment = priorityAttachment
								end
							end

							if CharacterAttachment then
								local Weld = Instance.new("Weld")

								Weld.Name = "AccessoryWeld"
								Weld.C0 = Attachment.CFrame
								Weld.C1 = CharacterAttachment.CFrame
								Weld.Part0 = Attachment.Parent
								Weld.Part1 = CharacterAttachment.Parent

								Weld.Parent = MorphPiece.Handle
							end
							
							for _,weld:Weld in next, MorphPiece.Handle:GetChildren() do
								if weld:IsA("Weld") and weld.Part1.Name ~= "LeftUpperLeg" and weld.Part1.Name ~= "RightUpperLeg" and weld.Part1.Name ~= "LeftUpperArm" and weld.Part1.Name ~= "RightUpperArm"  then
									weld:Destroy()
								end
							end
						end
					end
				end
			end
		end
	end
end

print("MorphModule v1 fully loaded!")

return Morph
