# odin-ldtk
Loader for [LDtk](https://ldtk.io/) files. Uses Odin's `core:json` to unmarshal data into structs.

Current version: `1.3.3`

The data definitions were generated with [QuickType](https://ldtk.io/docs/game-dev/loading/?menu=1#2-the-quicktype-way) for rust and then manually edited.

## How to use
```odin
import "ldtk"
```
And then:
```odin
if project, ok := ldtk.load_from_file("foo.ldtk, context.temp_allocator).?; ok {
    // use project ...
}
```

