---@class Vector3
---@field X number
---@field Y number
---@field Z number
Vector3 = { }

---@param a Vector3
---@param b Vector3
---@return number
function Vector3.Distance(a, b) return 0 end

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

---@generic T
---@param enumerable any
---@return fun(): T
function luanet.each(enumerable)
    return function() end
end