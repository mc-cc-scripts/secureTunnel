-- secureTunnel Builder
-- Aims to build a tunnel that you can safely walk through without monsters spawning or gravel blocking your way.
-- For more information, check the README.md at <https://github.com/mc-cc-scripts/secureTunnel-prog>
local scm = require("./scm")

local args = {...}

---@class discordWebhook
local discordWebhook = scm:load("discordWebhook")

---@class turtleController
local tC = scm:load("turtleController")
tC.canBreakBlocks = true

local pretty = require "cc.pretty"

---@param name string
---@param value any
---@param condition function | nil
---@param successColor number | nil
---@param failColor number | nil
local function printSetting(name, value, condition, successColor, failColor)
    condition = condition or function(val) return val end
    successColor = successColor or colors.green
    failColor = failColor or colors.red
    pretty.print(
        pretty.group(
            pretty.text(name, colors.yellow) ..
            pretty.text(": ") ..
            pretty.text(
                tostring(value),
                condition == nil and colors.yellow or
                value and condition(value) and successColor or
                failColor
            )
        )
    )
end

---@class secureTunnel
local secureTunnel = {}

secureTunnel["settings"] = {
    -- If torches should be placed (on the left wall).
    ["placeTorches"] = true,
    -- Amount of blocks between torches.
    ["torchQuantity"] = 8,
    -- If the script should continue if we run out of torches
    ["ignoreMissingTorches"] = true,
    -- If the ceiling should be build
    ["buildCeiling"] = true,
    -- If the walls should be build
    ["buildWalls"] = true,
    -- If every block should be replaced (requires loads of building blocks)
    ["replaceBlocks"] = false,
    -- If the discordWebhook is enabled or not.
    ["discordWebhookEnabled"] = false,
    -- The URL for the discordWebhook.
    ["discordWebhookURL"] = "",
    -- If the turtle should return home on success
    ["returnHome"] = true
}

secureTunnel["buildingBlocks"] = {
    "minecraft:cobblestone",
    "minecraft:stone",
    "minecraft:dirt",
    "minecraft:planks",
    "minecraft:log",
    "minecraft:sandstone",
    "minecraft:wool",
    "minecraft:bricks",
    "minecraft:mossy_cobblestone",
    "minecraft:obsidian",
    "minecraft:netherrack",
    "minecraft:stonebrick",
    "minecraft:end_stone"
}

function secureTunnel:init()
    self.canStart = false

    -- init discordWebhook
    if self.settings["discordWebhookEnabled"] and self.settings["discordWebhookURL"] ~= "" then
        discordWebhook:init(self.settings["discordWebhookURL"])
    end

    self:showPrompt()
    if self.canStart then self:run() end
end

function secureTunnel:showPrompt()
    pretty.print(
        pretty.text("secureTunnel", colors.orange)
    )

    pretty.print(
        pretty.group(
            pretty.text("Usage:\n") ..
            pretty.text("secureTunnel <", colors.lightGray) ..
            pretty.text("width", colors.yellow) ..
            pretty.text("> <", colors.lightGray) ..
            pretty.text("height", colors.yellow) ..
            pretty.text("> <", colors.lightGray) ..
            pretty.text("length", colors.yellow) ..
            pretty.text("> (<", colors.lightGray) ..
            pretty.text("placeTorches", colors.yellow) ..
            pretty.text(">)", colors.lightGray)
        )
    )

    self.width = tonumber(args[1]) or nil
    self.height = tonumber(args[2]) or nil
    self.length = tonumber(args[3]) or nil
    self.settings["placeTorches"] = args[4] or self.settings["placeTorches"]

    if self.width and self.height and self.length then
        pretty.print(
            pretty.text("\nStarted with the following settings:", colors.green)
        )
        self.canStart = true
    else
        pretty.print(
            pretty.text("\nFailed to start with the following settings:", colors.red)
        )
    end

    printSetting("width", self.width, nil, colors.yellow)
    printSetting("height", self.height, nil, colors.yellow)
    printSetting("length", self.length, nil, colors.yellow)
    printSetting("placeTorches", self.settings["placeTorches"])
    printSetting("torchQuantity", self.settings["torchQuantity"], nil, colors.yellow)
    printSetting("ignoreMissingTorches", self.settings["ignoreMissingTorches"])
    printSetting("buildCeiling", self.settings["buildCeiling"])
    printSetting("buildWalls", self.settings["buildWalls"])
    printSetting("replaceBlocks", self.settings["replaceBlocks"])
    printSetting("discordWebhookEnabled", self.settings["discordWebhookEnabled"])
end

function secureTunnel:findBuildingBlock()
    for i=1, #self.buildingBlocks, 1 do
        local slot = tC:findItemInInventory(self.buildingBlocks[i])
        if slot ~= nil then
            turtle.select(slot)
            return true
        end
    end
    return false
end

function secureTunnel:place(position)
    local digString = position == "down" and "digD" or
                          position == "up" and "digU" or
                          "dig"
    local placeFunction = position == "down" and turtle.placeDown or
                          position == "up" and turtle.placeUp or
                          turtle.place

    if self.settings["replaceBlocks"] then
        tC:tryAction(digString)
    end

    local success, error = placeFunction()
    if not success and error == "No items to place" then
        if self:findBuildingBlock() then
            placeFunction()
            return true
        else
            table.insert(self.errors, "Not enough building blocks.")
            return false
        end
    end

    return true
end

function secureTunnel:run()
    self.blocksMoved = 0
    -- The following would be useful as output on fail
    self.blocksLeft = self.length + 1
    self.errors = {}

    while self.blocksLeft > 0 do
        -- Check building blocks
        local foundBuildingBlock = self:findBuildingBlock()
        if not foundBuildingBlock then
            table.insert(self.errors, "Not enough building blocks.")
            return self:failed()
        end

        -- If everything is ok, continue with current position
        -- if not self:place("down") then return self:failed() end

        
        tC:tryMove("tL")

        local facingRight = false

        for y = 1, self.height, 1 do
            if self.settings["buildWalls"] then
                if not self:place() then return self:failed() end
            end

            tC:tryMove("tA")
            facingRight = not facingRight

            for x = 1, self.width, 1 do
                if y == 1 then
                    if not self:place("down") then return self:failed() end
                end

                if y == self.height and self.settings["buildCeiling"] then
                    if not self:place("up") then return self:failed() end
                end

                if x < self.width then tC:tryMove("f") end
            end

            if self.settings["buildWalls"] then
                if not self:place() then return self:failed() end
            end

            if y < self.height then tC:tryMove("u") end
        end

        if self.settings["buildWalls"] then
            if not self:place() then return self:failed() end
        end

        for y = 1, self.height - 1, 1 do
            tC:tryMove("d")
        end

        if facingRight then
            tC:tryMove("tA")
            for x = 1, self.width - 1, 1 do
                tC:tryMove("f")
            end
        end

        -- Check if torch should be placed
        if math.fmod(self.blocksMoved, self.settings["torchQuantity"]) == 0 then
            local slot = tC:findItemInInventory("minecraft:torch")
            if slot then
                local oldSlot = turtle.getSelectedSlot()
                turtle.select(slot)
                turtle.placeUp()
                turtle.select(oldSlot)
            elseif not self.settings["ignoreMissingTorches"] then
                table.insert(self.errors, "Not enough torches.")
                return self:failed()
            end
        end

        tC:tryMove("tR")

        -- Move forward and increase self.blocksMoved
        self.blocksMoved = self.blocksMoved + 1
        self.blocksLeft = self.blocksLeft - 1
        if self.blocksLeft > 0 then
            tC:tryMove("f")
        end
    end

    if self.blocksLeft == 0 then
        return self:succeded()
    else
        return self:failed()
    end
end

function secureTunnel:returnHome()
    tC:tryMove("tA")
    for i = 1, self.blocksMoved, 1 do
        tC:tryMove("f")
    end
end

function secureTunnel:succeded()
    pretty.print(
        pretty.text("Tunnel completed.", colors.green)
    )
    if self.settings["discordWebhookEnabled"] then
        discordWebhook:send("secureTunnelBuilder", "Tunnel completed.")
    end

    if self.settings["returnHome"] then self:returnHome() end

    return true
end

function secureTunnel:failed()
    pretty.print(
        pretty.text("Failed to build tunnel.", colors.red)
    )
    --@TODO: Print more information
    -- self.errors
    -- self.blocksLeft
    -- maybe allow continuing aswell
    if self.settings["discordWebhookEnabled"] then
        discordWebhook:send("secureTunnelBuilder", "Failed to build tunnel. Please check on me.")
    end

    return false
end

secureTunnel:init()
