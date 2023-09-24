-- gun baby gun baby gunnn babyy mobnkey
function sandbox(var,func)
	local env = getfenv(func)
	local newenv = setmetatable({},{
		__index = function(self,k)
			if k=="script" then
				return var
			else
				return env[k]
			end
		end,
	})
	setfenv(func,newenv)
	return func
end
cors = {}

AR0 = Instance.new("Tool")
AR0.Name = "AR"
AR0.Parent = game.Players.LocalPlayer.Backpack
AR0.Grip = CFrame.new(0, 0, 0, -0.0050099371, 0, 0.999987423, 0, 1, 0, -0.999987423, 0, -0.0050099371)
AR0.GripForward = Vector3.new(-0.9999874234199524, -0, 0.005009937100112438)
AR0.GripRight = Vector3.new(-0.005009937100112438, 0, -0.9999874234199524)

LocalGui1 = Instance.new("LocalScript")
LocalGui1.Name = "LocalGui"
LocalGui1.Parent = AR0
table.insert(cors,sandbox(LocalGui1,function()
-------------------------------------Gun info
ToolName="AR15"

ClipSize=30
ReloadTime=.25
Firerate=.09
MinSpread=0
MaxSpread=0
SpreadRate=0
BaseDamage=25
automatic=true
burst=false
shot=false			--Shotgun
BarrlePos=Vector3.new(-2,.60,0)
Cursors={"rbxasset://textures\\GunCursor.png"}
ReloadCursor="rbxasset://textures\\GunWaitCursor.png"
-------------------------------------
equiped=false
sp=script.Parent
RayLength=1000
Spread=0
enabled=true
reloading=false
down=false
r=game:service("RunService")
last=0
last2=0
last3=0
last4=0
last5=0
last6=0

Bullet=Instance.new("Part")
Bullet.Name="Bullet"
Bullet.BrickColor=BrickColor.new("New Yeller")
Bullet.Anchored=true
Bullet.CanCollide=false
Bullet.Locked=true
Bullet.Size=Vector3.new(1,1,1)
--Bullet.Transparency=.65
Bullet.formFactor=0
Bullet.TopSurface=0
Bullet.BottomSurface=0
mesh=Instance.new("SpecialMesh")
mesh.Parent=Bullet
mesh.MeshType="Brick"
mesh.Name="Mesh"
mesh.Scale=Vector3.new(.15,.15,1)

function check()
	sp.Name=ToolName.."-("..tostring(sp.Ammo.Value)..")"
end

function computeDirection(vec)
	local lenSquared = vec.magnitude * vec.magnitude
	local invSqrt = 1 / math.sqrt(lenSquared)
	return Vector3.new(vec.x * invSqrt, vec.y * invSqrt, vec.z * invSqrt)
end

------------------------------------------------------------------------------------Raycasting functions
function cross(vector1, vector2)
	return Vector3.new(vector1.y * vector2.z - vector2.y * vector1.z, vector1.z * vector2.x - vector1.x * vector2.z, vector1.x * vector2.y - vector2.x * vector1.y)
end
function dot(vector1, vector2)
	return (vector1.x * vector2.x + vector1.y * vector2.y + vector1.z * vector2.z)
end
function getLineSphereCollide(linePoint1, lineVector, sphereCenter, radius)
	local a = lineVector.x * lineVector.x + lineVector.y * lineVector.y + lineVector.z * lineVector.z
	local b = lineVector.x * (linePoint1.x - sphereCenter.x) + lineVector.y * (linePoint1.y - sphereCenter.y) + lineVector.z * (linePoint1.z - sphereCenter.z)
	local c = (linePoint1.x - sphereCenter.x) * (linePoint1.x - sphereCenter.x) + (linePoint1.y - sphereCenter.y) * (linePoint1.y - sphereCenter.y) + (linePoint1.z - sphereCenter.z) * (linePoint1.z - sphereCenter.z) - radius * radius
	if (a > 0) and (b * b >= a * c) then
		local diff = math.sqrt(b * b - a * c)
		return ((-b - diff) / a), ((diff - b) / a)
	else
		return -1, -1
	end
end
--Returns hit, position, normal, time
function raycast(model, start, vector, brickFunction)
	local hit, normal, time = raycastRecursive(model, start, vector, brickFunction, vector.unit, dot(start, vector.unit))
	if (dot(normal, vector) > 0) then
		normal = -normal
	end
	return hit, start + time * vector, normal.unit, time
end
function raycastRecursive(model, start, vector, brickFunction, unitVec, startDist)
	if (model.className == "Part") or (model.className == "Seat") or (model.className =="SpawnLocation") then
		local range = model.Size.magnitude / 2
		local dist = dot(model.Position, unitVec) - startDist
		if (dist + range > 0) and (dist - range < vector.magnitude) and ((dist * unitVec + start - model.Position).magnitude < range) and brickFunction(model) then
			local halfSize = model.Size / 2
			if (model.Shape == Enum.PartType.Ball) then
				local time, timeMax = getLineSphereCollide(start, vector, model.Position, halfSize.x)
				if (time < 1) and (time >= 0) then
					return model, (time * vector + start - model.Position), time
				else
					return nil, Vector3.new(0, 0, 0), 1
				end
			elseif (model.Shape == Enum.PartType.Block) then
				local time = 1
				local cf = model.CFrame - model.Position
				local xvec = cf * Vector3.new(1, 0, 0)
				local yvec = cf * Vector3.new(0, 1, 0)
				local zvec = cf * Vector3.new(0, 0, 1)
				local xspd = -dot(xvec, vector)
				local yspd = -dot(yvec, vector)
				local zspd = -dot(zvec, vector)
				local xmin, xmax, ymin, ymax, zmin, zmax = -1
				local dotProd = dot(xvec, start - model.Position)
				if (xspd ~= 0) then
					xmin = (dotProd - halfSize.x) / xspd
					xmax = (dotProd + halfSize.x) / xspd
					if (xmax < xmin) then
						local swap = xmin
						xmin = xmax
						xmax = swap
					end
				else
					if (math.abs(dotProd) < halfSize.x) then
						xmax = 1
						xmin = 0
					else
						return nil, Vector3.new(0, 0, 0), 1
					end
				end
				local dotProd = dot(yvec, start - model.Position)
				if (yspd ~= 0) then
					ymin = (dotProd - halfSize.y) / yspd
					ymax = (dotProd + halfSize.y) / yspd
					if (ymax < ymin) then
						local swap = ymin
						ymin = ymax
						ymax = swap
					end
				else
					if (math.abs(dotProd) < halfSize.y) then
						ymax = 1
						ymin = 0
					else
						return nil, Vector3.new(0, 0, 0), 1
					end
				end
				local dotProd = dot(zvec, start - model.Position)
				if (zspd ~= 0) then
					zmin = (dotProd - halfSize.z) / zspd
					zmax = (dotProd + halfSize.z) / zspd
					if (zmax < zmin) then
						local swap = zmin
						zmin = zmax
						zmax = swap
					end
				else
					if (math.abs(dotProd) < halfSize.z) then
						zmax = 1
						zmin = 0
					else
						return nil, Vector3.new(0, 0, 0), 1
					end
				end
				if (xmin <= ymax) and (xmax >= ymin) and (xmin <= zmax) and (xmax >= zmin) and (zmin <= ymax) and (zmax >= ymin) then
					local normal = xvec
					local min = xmin
					if (ymin > min) then
						min = ymin
						normal = yvec
					end
					if (zmin > min) then
						min = zmin
						normal = zvec
					end
					if (min >= 0) and (min < 1) then
						time = min
					elseif (xmax > 0) and (ymax > 0) and (zmax > 0) and (min < 0) then
						time = 0
						normal = Vector3.new(0, 0, 0)
					end
					return model, normal, time
				else
					return nil, Vector3.new(0, 0, 0), 1
				end
			else	--	Cylinder
				local time = 1
				local cf = model.CFrame - model.Position
				local xvec = cf * Vector3.new(1, 0, 0)
				local xspd = -dot(xvec, vector)
				local xmin, xmax = -1
				local dotProd = dot(xvec, start - model.Position)
				if (xspd ~= 0) then
					xmin = (dotProd - halfSize.x) / xspd
					xmax = (dotProd + halfSize.x) / xspd
					if (xmax < xmin) then
						local swap = xmin
						xmin = xmax
						xmax = swap
					end
				else
					if (math.abs(dotProd) < halfSize.x) then
						xmax = 1
						xmin = 0
					else
						return nil, Vector3.new(0, 0, 0), 1
					end
				end

				local relVec = cf:pointToObjectSpace(vector) * Vector3.new(0, 1, 1)
				local relPos = model.CFrame:pointToObjectSpace(start) * Vector3.new(0, 1, 1)
				local rmin, rmax = getLineSphereCollide(relPos, relVec, Vector3.new(0, 0, 0), halfSize.y)
				if (xmin <= rmax) and (xmax >= rmin) and (rmax > 0) then
					local normal = xvec
					local min = xmin
					if (rmin > min) then
						min = rmin
						normal = cf * (relPos + relVec * min)
					end
					if (min >= 0) and (min < 1) then
						time = min
					elseif (xmax > 0) and (rmax > 0) and (min < 0) then
						time = 0
						normal = Vector3.new(0, 0, 0)
					end
					return model, normal, time
				else
					return nil, Vector3.new(0, 0, 0), 1
				end
				return nil, Vector3.new(0, 0, 0), 1
			end
		end
		return nil, Vector3.new(0, 0, 0), 1
	elseif (model.className=="Model") or (model.className=="Workspace") or (model.className=="Hat") or (model.className == "Tool") then
		local children=model:GetChildren()
		local time=1
		local normal=Vector3.new(0, 0, 0)
		local hit=nil
		for n = 1, #children do
			if children[n]~= nil then
				local newHit, newNormal, newTime = raycastRecursive(children[n], start, vector, brickFunction, unitVec, startDist)
				if (newTime < time) then
					time = newTime
					hit = newHit
					normal = newNormal
				end
			end
		end
		return hit, normal, time
	else
		return nil, Vector3.new(0, 0, 0), 1
	end
end
-------------------------------------------------------------------------------






function tagHumanoid(humanoid)
	local plr=game.Players:playerFromCharacter(sp.Parent)
	if plr~=nil then
		local tag=Instance.new("ObjectValue")
		tag.Value=plr
		tag.Name="creator"
		tag.Parent=humanoid
		delay(2,function()
			if tag~=nil then
				tag.Parent=nil
			end
		end)
	end
end


function reload(mouse)
	reloading=true
	mouse.Icon=ReloadCursor
	while sp.Ammo.Value<ClipSize and reloading and enabled do
		wait(ReloadTime/ClipSize)
		if reloading then
			sp.Ammo.Value=sp.Ammo.Value+1
			check()
		else
			break
		end
	end
	check()
	mouse.Icon=Cursors[1]
	reloading=false
end

function onKeyDown(key,mouse)
	key=key:lower()
	if key=="r" and not reloading then
		reload(mouse)
	end
end

function movecframe(p,pos)
	p.Parent=game.Lighting
	p.Position=pos
	p.Parent=game.Workspace
end


function fire(aim)
	sp.Handle.Fire:Play()

	t=r.Stepped:wait()
	last6=last5
	last5=last4
	last4=last3
	last3=last2
	last2=last
	last=t

	local bullet=Bullet:clone()
	local totalDist=0
	Lengthdist=-RayLength/.5
	local startpoint=sp.Handle.CFrame*BarrlePos
	local dir=(aim)-startpoint
	dir=computeDirection(dir)
	local cfrm=CFrame.new(startpoint, dir+startpoint)
	local hit,pos,normal,time=raycast(game.Workspace, startpoint, cfrm*Vector3.new(0,0,Lengthdist)-startpoint, function(brick)
		if brick.Name=="Glass" then
			return true
		elseif brick.Name=="Bullet" or brick.Name=="BulletTexture" then
			return false
		elseif brick:IsDescendantOf(sp.Parent) then
			return false
		elseif brick.Name=="Handle" then
			if brick.Parent:IsDescendantOf(sp.Parent) then
				return false
			else
				return true
			end
		end
		return true
	end)
	bullet.Parent=game.Workspace
	if hit~=nil then
		local humanoid=hit.Parent:FindFirstChild("Humanoid")
		if humanoid~=nil then
			local damage=math.random(BaseDamage-(BaseDamage*.25),BaseDamage+(BaseDamage*.25))
			if hit.Name=="Head" then
				damage=damage*1.3
			elseif hit.Name=="Torso" then
			else
				damage=damage*.75
			end
			if humanoid.Health>0 then
				local eplr=game.Players:playerFromCharacter(humanoid.Parent)
				local plr=game.Players:playerFromCharacter(sp.Parent)
				if eplr~=nil and plr~=nil then
				--	if eplr.TeamColor~=plr.TeamColor or eplr.Neutral or plr.Neutral then
						tagHumanoid(humanoid)
						humanoid:TakeDamage(damage)
				--	end
				else
					tagHumanoid(humanoid)
					humanoid:TakeDamage(damage)
				end
			end
		end
		if (hit.Name == "Part10") or (hit.Name == "Part11") or (hit.Name == "Part21") or (hit.Name == "Part23") or (hit.Name == "Part24") or (hit.Name == "Part8") then
			rand = math.random(1,5)
			if rand == 3 then
				workspace.GlassSound:play()
				hit:breakJoints()
			end
		end
		if (hit.Parent:findFirstChild("Hit")) then
			hit.Parent.Health.Value = hit.Parent.Health.Value - BaseDamage/3
		end
		distance=(startpoint-pos).magnitude
		bullet.CFrame=cfrm*CFrame.new(0,0,-distance/2)
		bullet.Mesh.Scale=Vector3.new(.15,.15,distance)
	else
		bullet.CFrame=cfrm*CFrame.new(0,0,-RayLength/2) 
		bullet.Mesh.Scale=Vector3.new(.15,.15,RayLength)
	end
	if pos~=nil then
	end
	local deb=game:FindFirstChild("Debris")
	if deb==nil then
		local debris=Instance.new("Debris")
		debris.Parent=game
	end
	check()
	game.Debris:AddItem(bullet,.05)
end

function onButton1Up(mouse)
	down=false
end

function onButton1Down(mouse)
	h=sp.Parent:FindFirstChild("Humanoid")
	if not enabled or reloading or down or h==nil then
		return
	end
	if sp.Ammo.Value>0 and h.Health>0 then
		--[[if sp.Ammo.Value<=0 then
			if not reloading then
				reload(mouse)
			end
			return
		end]]
		down=true
		enabled=false
		while down do
			if sp.Ammo.Value<=0 then
				break
			end
			if burst then
				local startpoint=sp.Handle.CFrame*BarrlePos
				local mag=(mouse.Hit.p-startpoint).magnitude
				local rndm=Vector3.new(math.random(-(Spread/10)*mag,(Spread/10)*mag),math.random(-(Spread/10)*mag,(Spread/10)*mag),math.random(-(Spread/10)*mag,(Spread/10)*mag))
				fire(mouse.Hit.p+rndm)
				sp.Ammo.Value=sp.Ammo.Value-1
				if sp.Ammo.Value<=0 then
					break
				end
				wait(.05)
				local startpoint=sp.Handle.CFrame*BarrlePos
				local mag2=((mouse.Hit.p+rndm)-startpoint).magnitude
				local rndm2=Vector3.new(math.random(-(.1/10)*mag2,(.1/10)*mag2),math.random(-(.1/10)*mag2,(.1/10)*mag2),math.random(-(.1/10)*mag2,(.1/10)*mag2))
				fire(mouse.Hit.p+rndm+rndm2)
				sp.Ammo.Value=sp.Ammo.Value-1
				if sp.Ammo.Value<=0 then
					break
				end
				wait(.05)
				fire(mouse.Hit.p+rndm+rndm2+rndm2)
				sp.Ammo.Value=sp.Ammo.Value-1
			elseif shot then
				sp.Ammo.Value=sp.Ammo.Value-1
				local startpoint=sp.Handle.CFrame*BarrlePos
				local mag=(mouse.Hit.p-startpoint).magnitude
				local rndm=Vector3.new(math.random(-(Spread/10)*mag,(Spread/10)*mag),math.random(-(Spread/10)*mag,(Spread/10)*mag),math.random(-(Spread/10)*mag,(Spread/10)*mag))
				fire(mouse.Hit.p+rndm)
				local mag2=((mouse.Hit.p+rndm)-startpoint).magnitude
				local rndm2=Vector3.new(math.random(-(.2/10)*mag2,(.2/10)*mag2),math.random(-(.2/10)*mag2,(.2/10)*mag2),math.random(-(.2/10)*mag2,(.2/10)*mag2))
				fire(mouse.Hit.p+rndm+rndm2)
				local rndm3=Vector3.new(math.random(-(.2/10)*mag2,(.2/10)*mag2),math.random(-(.2/10)*mag2,(.2/10)*mag2),math.random(-(.2/10)*mag2,(.2/10)*mag2))
				fire(mouse.Hit.p+rndm+rndm3)
				local rndm4=Vector3.new(math.random(-(.2/10)*mag2,(.2/10)*mag2),math.random(-(.2/10)*mag2,(.2/10)*mag2),math.random(-(.2/10)*mag2,(.2/10)*mag2))
				fire(mouse.Hit.p+rndm+rndm4)
			else
				sp.Ammo.Value=sp.Ammo.Value-1
				local startpoint=sp.Handle.CFrame*BarrlePos
				local mag=(mouse.Hit.p-startpoint).magnitude
				local rndm=Vector3.new(math.random(-(Spread/10)*mag,(Spread/10)*mag),math.random(-(Spread/10)*mag,(Spread/10)*mag),math.random(-(Spread/10)*mag,(Spread/10)*mag))
				fire(mouse.Hit.p+rndm)
			end
			wait(Firerate)
			if not automatic then
				break
			end
		end	
		enabled=true
	else
		sp.Handle.Trigger:Play()
	end
end

function onEquippedLocal(mouse)
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	mouse.Icon=Cursors[1]
	mouse.KeyDown:connect(function(key) onKeyDown(key,mouse) end)
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
	mouse.Button1Up:connect(function() onButton1Up(mouse) end)
	check()
	equiped=true
	if #Cursors>1 then
		while equiped do
			t=r.Stepped:wait()
			local action=sp.Parent:FindFirstChild("Pose")
			if action~=nil then
				if sp.Parent.Pose.Value=="Standing" then
					Spread=MinSpread
				else
					Spread=MinSpread+((4/10)*(MaxSpread-MinSpread))
				end
			else
				Spread=MinSpread
			end
			if t-last<SpreadRate then
				Spread=Spread+.1*(MaxSpread-MinSpread)
			end
			if t-last2<SpreadRate then
				Spread=Spread+.1*(MaxSpread-MinSpread)
			end
			if t-last3<SpreadRate then
				Spread=Spread+.1*(MaxSpread-MinSpread)
			end
			if t-last4<SpreadRate then
				Spread=Spread+.1*(MaxSpread-MinSpread)
			end
			if t-last5<SpreadRate then
				Spread=Spread+.1*(MaxSpread-MinSpread)
			end
			if t-last6<SpreadRate then
				Spread=Spread+.1*(MaxSpread-MinSpread)
			end
			if not reloading then
				local percent=(Spread-MinSpread)/(MaxSpread-MinSpread)
				for i=0,#Cursors-1 do
					if percent>(i/(#Cursors-1))-((1/(#Cursors-1))/2) and percent<(i/(#Cursors-1))+((1/(#Cursors-1))/2) then
						mouse.Icon=Cursors[i+1]
					end
				end
			end
			wait(Firerate*.9)
		end
	end
end
function onUnequippedLocal(mouse)
	equiped=false
	reloading=false
end
sp.Equipped:connect(onEquippedLocal)
sp.Unequipped:connect(onUnequippedLocal)
check()
end))

WeldArm2 = Instance.new("Script")
WeldArm2.Name = "WeldArm"
WeldArm2.Parent = AR0
table.insert(cors,sandbox(WeldArm2,function()
Tool = script.Parent;
local arms = nil
local torso = nil
local welds = {}

function Equip(mouse)
wait(0.01)
arms = {Tool.Parent:FindFirstChild("Left Arm"), Tool.Parent:FindFirstChild("Right Arm")}
torso = Tool.Parent:FindFirstChild("Torso")
if arms ~= nil and torso ~= nil then
local sh = {torso:FindFirstChild("Left Shoulder"), torso:FindFirstChild("Right Shoulder")}
if sh ~= nil then
local yes = true
if yes then
yes = false
sh[1].Part1 = nil
sh[2].Part1 = nil
local weld1 = Instance.new("Weld")
weld1.Part0 = torso
weld1.Parent = torso
weld1.Part1 = arms[1]
weld1.C1 = CFrame.new(-0.249, 1.35, 0.6) * CFrame.fromEulerAnglesXYZ(math.rad(290), 0, math.rad(-90))
welds[1] = weld1
local weld2 = Instance.new("Weld")
weld2.Part0 = torso
weld2.Parent = torso
weld2.Part1 = arms[2]
weld2.C1 = CFrame.new(-1, -0.2, 0.35) * CFrame.fromEulerAnglesXYZ(math.rad(-90), math.rad(-15), 0)
welds[2] = weld2
end
else
print("sh")
end
else
print("arms")
end
end

function Unequip(mouse)
if arms ~= nil and torso ~= nil then
local sh = {torso:FindFirstChild("Left Shoulder"), torso:FindFirstChild("Right Shoulder")}
if sh ~= nil then
local yes = true
if yes then
yes = false
sh[1].Part1 = arms[1]
sh[2].Part1 = arms[2]
welds[1].Parent = nil
welds[2].Parent = nil
end
else
print("sh")
end
else
print("arms")
end
end
Tool.Equipped:connect(Equip)
Tool.Unequipped:connect(Unequip)

end))

Ammo3 = Instance.new("NumberValue")
Ammo3.Name = "Ammo"
Ammo3.Parent = AR0
Ammo3.Value = 30

AdvancedCrouch4 = Instance.new("LocalScript")
AdvancedCrouch4.Name = "AdvancedCrouch"
AdvancedCrouch4.Parent = AR0
table.insert(cors,sandbox(AdvancedCrouch4,function()
-- initial script made by who knows, anti jump added by ColonelGraff! thanks for using


AJ = false

on = 0
Tool = script.Parent



welds = {}
sh = {}
arms = nil
torso = nil
f = nil
function Crouch(ison)

Tool.Parent:findFirstChild("Humanoid").WalkSpeed = 9


if arms == nil and torso == nil then
arms = {Tool.Parent:FindFirstChild("Left Leg"), Tool.Parent:FindFirstChild("Right Leg")}
torso = Tool.Parent:FindFirstChild("Torso")
end
if arms ~= nil and torso ~= nil then
sh = {torso:FindFirstChild("Left Hip"), torso:FindFirstChild("Right Hip")}
if sh ~= nil then
local yes = true
if yes then
yes = false
if ison == 1 then
sh[1].Part1 = nil
sh[2].Part1 = nil
local weld1 = Instance.new("Weld")
weld1.Part0 = torso
weld1.Parent = torso
weld1.Part1 = arms[1]
weld1.C1 = CFrame.new(-0.5, 0.75, 1)
arms[1].Name = "LDave"
arms[1].CanCollide = true
welds[1] = weld1
-------------------------------------------
local weld2 = Instance.new("Weld")
weld2.Part0 = torso
weld2.Parent = torso
weld2.Part1 = arms[2]
weld2.C1 = CFrame.new(0.5,0.495,1.25) * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
arms[2].Name = "RDave"
arms[2].CanCollide = true
welds[2] = weld2
---------------------------------
local force = Instance.new("BodyForce")
force.Parent = torso
f = force
if AJ == false then
AJ = true
antijump = script.AntiJump:clone()
antijump.Parent = Tool.Parent
antijump.Disabled = false
elseif AJ == true then
antijump.Disabled = false
end


wait(0.01)

elseif ison == 0 then
if arms then
sh[1].Part1 = arms[1]
sh[2].Part1 = arms[2]
f.Parent = nil
arms[2].Name = "Right Leg"
arms[1].Name = "Left Leg"
welds[1].Parent = nil
welds[2].Parent = nil
Tool.Parent:findFirstChild("Humanoid").WalkSpeed = 16
antijump.Disabled = true
end
end
--
end
else
print("sh")
end
else
print("arms")
end
end
function Key(key)
if key then
key = string.lower(key)
if (key=="c") then
if on == 1 then
on = 0
elseif on == 0 then
on = 1
end
Crouch(on)
end
end
end
function Equip(mouse)
mouse.KeyDown:connect(Key)
end
script.Parent.Equipped:connect(Equip)


end))

AntiJump5 = Instance.new("Script")
AntiJump5.Name = "AntiJump"
AntiJump5.Parent = AdvancedCrouch4
AntiJump5.Enabled = false
table.insert(cors,sandbox(AntiJump5,function()
h = script.Parent.Humanoid

function BLAAARGH()
h.Jump = false
end

h.Changed:connect(BLAAARGH)

end))
AntiJump5.Disabled = true

Handle6 = Instance.new("Part")
Handle6.Name = "Handle"
Handle6.Parent = AR0
Handle6.CFrame = CFrame.new(29.8313065, 1.10001743, -20.7955856, 0, 0, -1, 0, 1, 0, 1, 0, 0)
Handle6.Orientation = Vector3.new(0, -90, 0)
Handle6.Position = Vector3.new(29.83130645751953, 1.1000174283981323, -20.79558563232422)
Handle6.Rotation = Vector3.new(0, -90, 0)
Handle6.Color = Color3.new(0.388235, 0.372549, 0.384314)
Handle6.Transparency = 1
Handle6.Size = Vector3.new(0.20000000298023224, 0.20000000298023224, 0.20000000298023224)
Handle6.BackSurface = Enum.SurfaceType.Weld
Handle6.BottomSurface = Enum.SurfaceType.Weld
Handle6.BrickColor = BrickColor.new("Dark stone grey")
Handle6.CanCollide = false
Handle6.FrontSurface = Enum.SurfaceType.Weld
Handle6.LeftSurface = Enum.SurfaceType.Weld
Handle6.RightSurface = Enum.SurfaceType.Weld
Handle6.TopSurface = Enum.SurfaceType.Weld
Handle6.brickColor = BrickColor.new("Dark stone grey")
Handle6.FormFactor = Enum.FormFactor.Custom
Handle6.formFactor = Enum.FormFactor.Custom

Fire7 = Instance.new("Sound")
Fire7.Name = "Fire"
Fire7.Parent = Handle6
Fire7.Pitch = 0.8999999761581421
Fire7.PlaybackSpeed = 0.8999999761581421
Fire7.SoundId = "http://roblox.com/asset/?id=10209859"
Fire7.Volume = 1

Trigger8 = Instance.new("Sound")
Trigger8.Name = "Trigger"
Trigger8.Parent = Handle6
Trigger8.SoundId = "rbxasset://sounds//switch.wav"
Trigger8.Volume = 0.75

Weld9 = Instance.new("Weld")
Weld9.Parent = Handle6
Weld9.C0 = CFrame.new(-0.100000001, 0, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0)
Weld9.C1 = CFrame.new(0, -0.399999619, -0.399983048, -1, 0, 0, 0, 0, 1, 0, 1, 0)
Weld9.Part0 = Handle6
Weld9.Part1 = Part12
Weld9.part1 = Part12

BackupWeld10 = Instance.new("LocalScript")
BackupWeld10.Name = "BackupWeld"
BackupWeld10.Parent = AR0
table.insert(cors,sandbox(BackupWeld10,function()
function Weld(x,y)
	local W = Instance.new("Weld")
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
end

function Get(A)
	if A.className == "Part" then
		Weld(script.Parent.Handle, A)
		A.Anchored = false
	else
		local C = A:GetChildren()
		for i=1, #C do
		Get(C[i])
		end
	end
end

function Finale()
	Get(script.Parent)
end

script.Parent.Equipped:connect(Finale)
script.Parent.Unequipped:connect(Finale)
Finale()
end))

Welding11 = Instance.new("Script")
Welding11.Name = "Welding"
Welding11.Parent = AR0
table.insert(cors,sandbox(Welding11,function()
function Weld(x,y)
	local W = Instance.new("Weld")
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
end

function Get(A)
	if A.className == "Part" then
		Weld(script.Parent.Handle, A)
		A.Anchored = false
	else
		local C = A:GetChildren()
		for i=1, #C do
		Get(C[i])
		end
	end
end

function Finale()
	Get(script.Parent)
end

script.Parent.Equipped:connect(Finale)
script.Parent.Unequipped:connect(Finale)
Finale()
end))

Part12 = Instance.new("Part")
Part12.Parent = AR0
Part12.CFrame = CFrame.new(29.8313065, 1.50000048, -21.2955856, 1, 0, 0, 0, 0, 1, 0, -1, 0)
Part12.Orientation = Vector3.new(-90, 0, 0)
Part12.Position = Vector3.new(29.83130645751953, 1.5000004768371582, -21.29558563232422)
Part12.Rotation = Vector3.new(-90, 0, 0)
Part12.Color = Color3.new(0.388235, 0.372549, 0.384314)
Part12.Size = Vector3.new(0.20000000298023224, 0.7999995946884155, 1)
Part12.BackSurface = Enum.SurfaceType.Weld
Part12.BottomSurface = Enum.SurfaceType.Weld
Part12.BrickColor = BrickColor.new("Dark stone grey")
Part12.FrontSurface = Enum.SurfaceType.Weld
Part12.LeftSurface = Enum.SurfaceType.Weld
Part12.RightSurface = Enum.SurfaceType.Weld
Part12.TopSurface = Enum.SurfaceType.Weld
Part12.brickColor = BrickColor.new("Dark stone grey")
Part12.FormFactor = Enum.FormFactor.Custom
Part12.formFactor = Enum.FormFactor.Custom

Mesh13 = Instance.new("SpecialMesh")
Mesh13.Parent = Part12
Mesh13.MeshId = "http://www.roblox.com/asset/?id=72012671"
Mesh13.VertexColor = Vector3.new(2, 2, 2)
Mesh13.TextureId = "http://www.roblox.com/asset/?id=72012605"
Mesh13.MeshType = Enum.MeshType.FileMesh

for i,v in pairs(cors) do
	spawn(function()
		pcall(v)
	end)
end
