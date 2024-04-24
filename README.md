# odin-ldtk
Loader for [LDtk](https://ldtk.io/) files. Uses Odin's `core:json` to unmarshal data into structs.

> LDtk is a modern 2D level editor from the creator of Dead Cells,
with a strong focus on user-friendliness.

Current version: `1.3.3`

The data definitions were generated with [JSON scheme and QuickType](https://ldtk.io/docs/game-dev/loading/?menu=1#2-the-quicktype-way) for rust and then manually edited.

## How to use
Put the `ldtk.odin` file to a `ldtk` folder somewhere in your project. Then you can just do this (the path might be different):
```odin
import "../ldtk"
```
And then:
```odin
if project, ok := ldtk.load_from_file("foo.ldtk", context.temp_allocator).?; ok {
    for biome in project.defs.biomes {
        // use biomes ...
    }

    for level in proj.levels {
        for layer in level.layers {
            switch layer.type {
            case .IntGrid:
            case .Entities:
            case .Tiles:
            case .AutoLayer:
            }
        }
    }

    // ...
}
```
Note: `value` in `Field_Instance` can be a different type depending on the data.
For this reason the type is `json.Value`, which works like `any` in this case, and you can do whatever you want with it.

## Example
There is an example of a basic 2d platformer in the [example](example/) folder. It uses raylib for the tilemap rendering. The initial implementation is by @Smilex.

Hot to use:
```
cd example
odin run .
```

## Contributing
Contributions are welcome!
