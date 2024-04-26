local todo = require(script.Parent:WaitForChild("todoModule"))
local b64 = require(script.Parent:WaitForChild("b64"))
local json = require(script.Parent:WaitForChild("JSON"))
local HttpService = game:GetService("HttpService")

local RTB = {}

RTB.PartTypes = {	
	-- physics 
	"Thruster", "Servo", "Servo_Physics", "Propeller", "BallSocket",
	"SteeringGyro", "MatchingGyro", "StaringGyro", "Gyro", "RockingChair",
	"Wheel", "Wing", "Piston", "Cannon", "BowlingBall", "BouncyBall", 
	"BeachBall", "Balloon","RubberBand", "Rope", "Sledge", "__end-physics__",
	--
	
	-- building
	"Base", "Board", "GlassBase", "Bumper", "Tire", "Connector", 
	"ConnectorBall", "HalfConnectorBall", "ShortStick", "Stick", 
	"LongStick", "Pipes", "Part", "Chassis", "ShoppingCart",  "Cinderblock",
	"__end-building__",
	--
	
	-- sensors/wiring/logic
	"Delayer", "InputSensor", "VelocitySensor", "AltitudeSensor",
	"Looper", "Splitter_4", "Splitter_3", "Splitter_2", 
	"Splitter_1", "Not-Gate", "And-Gate", "Or-Gate", "Wire", 
	"RemoteButton", "EntitySensor", "Detacher", "PressurePlate",
	"TripWire", "__end-wiring__",
	--
	
	-- tools
	"Uzi", "Shotgun", "Gun", "MountedGun", "Magazine", "Grenade", 
	"RPG", "Leafblower", "Plunger", "Shield","SprayPaint", "Rocket",
	"__end-tools__",
	--
	
	-- misc. 
	"Sprite", "Jug", "Poop", "DoorA", "DoorB", "DoorC", "DoorD",
	"Radio", "Leg", "Googie", "Spoiler", "Pie", "Toilet", "Joint",
	"Carrot", "SpringJuice", "FuelTank", "SteeringWheel",  "PotatoEngine", 
	"GoldPotatoEngine", "Light", "Lock", "HulaDoll", "Cone", "BrakeLight",
	"Canister", "Roof", "GasCap", "FishBowl", "CannonBall", "Arm", "Gramby",
	"Trunk", "Recorder", "__end-misc__",
	--
	
	--unknown/not marked/not in spawn menu
	"BeachChair", "WoodenChair", "Clipboard", "Successor", "FuzzyDice",
	"__end-unknown__"
	--
}

RTB.GetPartsFromType = {}

function RTB.GetPartsFromType:TypeHelper(startpattern:string | number, endpattern:string) -- WHAT DOES THIS DO?
	local parttypeclone = RTB.PartTypes
	local outtable = {}
	
	local startindex = (if type(startpattern) ~= "number" then table.find(RTB.PartTypes, startpattern) else startpattern)
	local endindex = table.find(RTB.PartTypes, endpattern)

	if (startindex and RTB.PartTypes[startindex+1]) and (endindex and RTB.PartTypes[endindex-1]) then
		return table.move(parttypeclone, startindex + (if type(startpattern)=="number" then 0 else 1), endindex-1, 1, outtable)
	end
end

function RTB.GetPartsFromType:All()
	local out = RTB.PartTypes
	
	for index, value:string in pairs(out) do
		if value:match("__end-") then
			table.remove(out, index)
		end
	end
	
	return out
end

function RTB.GetPartsFromType:Get(typeint:number)
	local types = {1, "__end-physics__", "__end-building__",  "__end-wiring__", "__end-misc__", "__end-unknown"}
	if typeint < 2 or typeint > #types then error(`Failed to get type. {typeint} is not a valid type interger.`) end
	return RTB.GetPartsFromType:TypeHelper(types[typeint-1], types[typeint])
end

--==--==--
RTB.Blueprint = {}
RTB.Blueprint.Readable = {}

function RTB.Blueprint:Insert(value:string | {})
	table.insert(RTB.Blueprint.Readable,value)
end

function RTB.Blueprint:Encode()
	return b64:btoa(HttpService:JSONEncode(RTB.Blueprint.Readable))
end

function RTB.Blueprint:JSON()
	return json.stringify(RTB.Blueprint.Readable)
end

function RTB:Import(str:string)
	if not str then return end
	
	local compiled = json.parse(b64:atob(str))
	
	for index = #compiled, 1, -1 do
		RTB.Blueprint:Insert(compiled[1][index])
	end
	
	return compiled
end

function RTB:Clear()
	table.clear(self.Blueprint.Readable)
end


function RTB:CreateItem(Name:string?, unknown:string | number?, face:string? | number?, id:number?, ox:number?, oy:number?, oz:number?, rgb:{number}?)
	if not Name then error("Name is nil.") end
	if not table.find(RTB.PartTypes, Name) or Name:find("__end-", 0) then error(`Failed to compile item: {Name} is not a valid part type.`) end
	
	local Item = {
		Name,
		{},
		{}
	}
	
	if rgb then Item[3].RGB = rgb end
	if ox and ox > 0 then Item[3].OrientationX = ox end
	if oy and oy > 0 then Item[3].OrientationY = oy end
	if oz and oz > 0 then Item[3].OrientationZ = oz end
	if unknown and face and id then Item[2][1] = {unknown, face, id} end
	function Item:AddValue(name:string, value:string | number | boolean)
		if not name then error("To add a value you must include a value name.") end
		Item[3][name] = value
		return Item
	end
	function Item:SubValue(name:string)
		if not name then error("To remove a value you must include a value name.") end
		Item[3][name] = nil
		return Item
	end
	return Item
end

return RTB
