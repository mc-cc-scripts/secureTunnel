# secureTunnel
Currently builds a tunnel with a given width and height and places torches on the left side.

# Usage
Place turtle on the lower left corner of where you want your tunnel to be build and start it with your desired width, height and length.
```
secureTunnel <width> <height> <length> [<placeTorches>]
```

The following settings can currently only be changed by editing the program:
```lua
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
```

# TODO
- Make sure gravel and sand are removed
- Make sure there are no holes
- Make sure the light sources are enough so that no monsters spawn
- Make sure there is no lava / water inside the tunnel
- Allow better configuration (via commandline as well)
- Add proper error messages
