---@class Vector3
---@field X number
---@field Y number
---@field Z number
Vector3 = { }

---@class Luanet
luanet = {}

---Loads a .NET assembly by name
---@param name string
function luanet.load_assembly(name) end

---Imports a .NET type by fully qualified name
---@param typeName string
---@return any
function luanet.import_type(typeName) end

---Loads an enum or returns .NET constant value
---@param enumName string
---@return any
function luanet.enum(enumName) end