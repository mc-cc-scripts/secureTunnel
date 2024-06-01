-- secureTunnel Builder
-- Aims to build a tunnel that you can safely walk through without monsters spawning or gravel blocking your way.
-- For more information, check the README.md at <@TODO>
local scm = require "scm"

local args = {...}

---@class discordWebhook
local discordWebhook = scm:load("discordWebhook")

---@class turtleController
-- local tC = scm:load("turtleController")

local pretty = require "cc.pretty"

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
    -- If torches should be placed (in the middle).
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
    pretty.print(
        pretty.text("Note: <width> must be odd.", colors.lightGray)
    )

    self.width = args[1] or nil
    self.height = args[2] or nil
    self.length = args[3] or nil
    self.settings["placeTorches"] = args[4] or self.settings["placeTorches"]

    if self.width and self.height and self.length and math.fmod(self.width, 2) ~= 0 then
        pretty.print(
            pretty.text("\nStarted with the following settings:", colors.green)
        )
        self.canStart = true
    else
        pretty.print(
            pretty.text("\nFailed to start with the following settings:", colors.red)
        )
    end

    printSetting("width", self.width, function(val) return math.fmod(val, 2) ~= 0 end, colors.yellow)
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

function secureTunnel:run()
    -- self.blocksMoved = 0
    -- -- The following would be useful as output on fail
    -- self.blocksLeft = self.length

    -- while self.blocksLeft > 0 do

    --     self.blocksLeft = self.blocksLeft - self.blocksMoved
    -- end
end

function secureTunnel:succeded()
    pretty.print(
        pretty.text("Tunnel completed.", colors.green)
    )
    if self.settings["discordWebhookEnabled"] then
        discordWebhook:send("secureTunnelBuilder", "Tunnel completed.")
    end
end

function secureTunnel:failed()
    pretty.print(
        pretty.text("Failed to build tunnel.", colors.red)
    )
    --@TODO: Print more information
    if self.settings["discordWebhookEnabled"] then
        discordWebhook:send("secureTunnelBuilder", "Failed to build tunnel. Please check on me.")
    end
end

secureTunnel:init()
