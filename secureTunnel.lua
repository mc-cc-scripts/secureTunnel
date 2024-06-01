-- secureTunnel Builder
-- Aims to build a tunnel that you can safely walk through without monsters spawning or gravel blocking your way.
-- For more information, check the README.md at <@TODO>
local scm = require "scm"

local args = {...}

local log = scm:load("log")
local logFile = "./secureTunnel.log"

---@class discordWebhook
local discordWebhook = scm:load("discordWebhook")

---@class turtleController
-- local tC = scm:load("turtleController")

local pretty = require "cc.pretty"

settings.define("placeTorches", {
    description = "If torches should be placed (in the middle).",
    default = true,
    type = "boolean"
})

settings.define("torchQuantity", {
    description = "Amount of blocks between torches.",
    default = 8,
    type = "number"
})

settings.define("discordWebhookEnabled", {
    description = "If the discordWebhook is enabled or not.",
    default = false,
    type = "boolean"
})

settings.define("discordWebhookURL", {
    description = "The URL for the discordWebhook.",
    default = "",
    type = "string"
})

settings.define("width", {
    description = "Width of the tunnel.",
    default = "3",
    type = "number"
})

settings.define("height", {
    description = "Height of the tunnel.",
    default = "2",
    type = "number"
})

settings.define("length", {
    description = "Length of the tunnel.",
    default = "10",
    type = "number"
})


---@class secureTunnel
local secureTunnel = {}

function secureTunnel:init()
    -- init log
    log.write("", logFile)

    -- init discordWebhook
    if settings.get("discordWebhookEnabled") and settings.get("discordWebhookURL") ~= "" then
        discordWebhook:init(settings.get("discordWebhookURL"))
    end

    self:showPrompt()
end

function secureTunnel:showPrompt()
    pretty.print(
        pretty.text("secureTunnel", colors.orange)
    )

    pretty.print(
        pretty.group(
            pretty.text("Usage: ") ..
            pretty.text("secureTunnel <", colors.lightGray) ..
            pretty.text("width", colors.yellow) ..
            pretty.text("> <", colors.lightGray) ..
            pretty.text("height", colors.yellow) ..
            pretty.text("> <", colors.lightGray) ..
            pretty.text("length", colors.yellow) ..
            pretty.text(">", colors.lightGray)
        )
    )

    self.width = args[1] or nil
    self.height = args[2] or nil
    self.length = args[3] or nil
    if self.width and self.height and self.length then
        pretty.print(
            pretty.text("\nStarted with the following settings:", colors.green)
        )
    else
        pretty.print(
            pretty.text("\nFailed to start with the following settings:", colors.red)
        )
    end
    
    pretty.print(
        pretty.group(
            pretty.text("width", colors.yellow) ..
            pretty.text(": ") ..
            pretty.text(tostring(self.width), self.width and colors.yellow or colors.red)
        )
    )

    pretty.print(
        pretty.group(
            pretty.text("height", colors.yellow) ..
            pretty.text(": ") ..
            pretty.text(tostring(self.height), self.height and colors.yellow or colors.red)
        )
    )

    pretty.print(
        pretty.group(
            pretty.text("length", colors.yellow) ..
            pretty.text(": ") ..
            pretty.text(tostring(self.length), self.length and colors.yellow or colors.red)
        )
    )

    pretty.print(
        pretty.group(
            pretty.text("placeTorches", colors.yellow) ..
            pretty.text(": ") ..
            pretty.text(
                tostring(settings.get("placeTorches")),
                settings.get("placeTorches") and colors.green or colors.red
            )
        )
    )

    pretty.print(
        pretty.group(
            pretty.text("torchQuantity", colors.yellow) ..
            pretty.text(": ") ..
            pretty.text(tostring(settings.get("torchQuantity")), colors.yellow)
        )
    )

    pretty.print(
        pretty.group(
            pretty.text("discordWebhookEnabled", colors.yellow) ..
            pretty.text(": ") ..
            pretty.text(
                tostring(settings.get("discordWebhookEnabled")),
                settings.get("discordWebhookEnabled") and colors.green or colors.red
            )
        )
    )
end

secureTunnel:init()
-- if settings.get("discordWebhookEnabled") then
--     discordWebhook:send("secureTunnelBuilder", "exampleMessage")
-- end
