package ldtk

import "core:encoding/json"
import "core:os"

load_from_file :: proc(filename: string, allocator := context.allocator) -> Maybe(Project) {
    data, ok := os.read_entire_file(filename, allocator)
    if !ok {
        return nil
    }
    return load_from_memory(data, allocator)
}

load_from_memory :: proc(data: []byte, allocator := context.allocator) -> Maybe(Project) {
    result: Project
    err := json.unmarshal(data, &result, json.DEFAULT_SPECIFICATION, allocator)
    if err == nil {
        return result
    }
    return nil
}

// This is the root of any Project JSON file. It contains:
// - the project settings,
// - an array of levels,
// - a group of definitions (that can probably be safely ignored for most users).
Project :: struct {
    // LDtk application build identifier.  This is only used to identify the LDtk version
    // that generated this particular project file, which can be useful for specific bug fixing.
    // Note that the build identifier is just the date of the release, so it's not unique to
    // each user (one single global ID per LDtk public release), and as a result, completely
    // anonymous.
    app_build_id:           f32 `json:"appBuildId"`,
    // Number of backup files to keep, if the `backupOnSave` is TRUE
    backup_limit:           i32 `json:"backupLimit"`,
    // If TRUE, an extra copy of the project will be created in a sub folder, when saving.
    backup_on_save:         bool `json:"backupOnSave"`,
    // Project background color
    bg_color:               string `json:"bgColor"`,
    // An array of command lines that can be ran manually by the user
    custom_commands:        []LdtkCustomCommand `json:"customCommands"`,
    // Default grid size for new layers
    default_grid_size:      i32 `json:"defaultGridSize"`,
    // Default background color of levels
    default_level_bg_color: string `json:"defaultLevelBgColor"`,
    // **WARNING**: this field will move to the `worlds` array after the "multi-worlds" update.
    // It will then be `nil`. You can enable the Multi-worlds advanced project option to enable
    // the change immediately.  Default new level height
    default_level_height:   Maybe(i32) `json:"defaultLevelHeight"`,
    // **WARNING**: this field will move to the `worlds` array after the "multi-worlds" update.
    // It will then be `nil`. You can enable the Multi-worlds advanced project option to enable
    // the change immediately.  Default new level width
    default_level_width:    Maybe(i32) `json:"defaultLevelWidth"`,
    // Default X pivot (0 to 1) for new entities
    default_pivot_x:        f32 `json:"defaultPivotX"`,
    // Default Y pivot (0 to 1) for new entities
    default_pivot_y:        f32 `json:"defaultPivotY"`,
    // A structure containing all the definitions of this project
    defs:                   Definitions `json:"defs"`,
    // If TRUE, the exported PNGs will include the level background (color or image).
    export_level_bg:        bool `json:"exportLevelBg"`,
    // **WARNING**: this deprecated value is no longer exported since version 0.9.3  Replaced
    // by: `imageExportMode`
    export_png:             Maybe(bool) `json:"exportPng"`,
    // If TRUE, a Tiled compatible file will also be generated along with the LDtk JSON file
    // (default is FALSE)
    export_tiled:           bool `json:"exportTiled"`,
    // If TRUE, one file will be saved for the project (incl. all its definitions) and one file
    // in a sub-folder for each level.
    external_levels:        bool `json:"externalLevels"`,
    // An array containing various advanced flags (ie. options or other states). Possible
    // values: `DiscardPreCsvIntGrid`, `ExportPreCsvIntGridFormat`, `IgnoreBackupSuggest`,
    // `PrependIndexToLevelFileNames`, `MultiWorlds`, `UseMultilinesType`
    flags:                  []Flag `json:"flags"`,
    // Naming convention for Identifiers (first-letter uppercase, full uppercase etc.) Possible
    // values: `Capitalize`, `Uppercase`, `Lowercase`, `Free`
    identifier_style:       IdentifierStyle `json:"identifierStyle"`,
    // Unique project identifier
    iid:                    string `json:"iid"`,
    // "Image export" option when saving project. Possible values: `None`, `OneImagePerLayer`,
    // `OneImagePerLevel`, `LayersAndLevels`
    image_export_mode:      ImageExportMode `json:"imageExportMode"`,
    // File format version
    json_version:           string `json:"jsonVersion"`,
    // The default naming convention for level identifiers.
    level_name_pattern:     string `json:"levelNamePattern"`,
    // All levels. The order of this array is only relevant in `LinearHorizontal` and
    // `linearVertical` world layouts (see `worldLayout` value).  Otherwise, you should
    // refer to the `worldX`,`worldY` coordinates of each Level.
    levels:                 []Level `json:"levels"`,
    // If TRUE, the Json is partially minified (no indentation, nor line breaks, default is
    // FALSE)
    minify_json:            bool `json:"minifyJson"`,
    // Next Unique integer ID available
    next_uid:               i32 `json:"nextUid"`,
    // File naming pattern for exported PNGs
    png_file_pattern:       Maybe(string) `json:"pngFilePattern"`,
    // If TRUE, a very simplified will be generated on saving, for quicker & easier engine
    // integration.
    simplified_export:      bool `json:"simplifiedExport"`,
    // All instances of entities that have their `exportToToc` flag enabled are listed in this
    // array.
    toc:                    []LdtkTableOfContentEntry `json:"toc"`,
    // This optional description is used by LDtk Samples to show up some informations and
    // instructions.
    tutorial_desc:          Maybe(string) `json:"tutorialDesc"`,
    // **WARNING**: this field will move to the `worlds` array after the "multi-worlds" update.
    // It will then be `nil`. You can enable the Multi-worlds advanced project option to enable
    // the change immediately.  Height of the world grid in pixels.
    world_grid_height:      Maybe(i32) `json:"worldGridHeight"`,
    // **WARNING**: this field will move to the `worlds` array after the "multi-worlds" update.
    // It will then be `nil`. You can enable the Multi-worlds advanced project option to enable
    // the change immediately.  Width of the world grid in pixels.
    world_grid_width:       Maybe(i32) `json:"worldGridWidth"`,
    // **WARNING**: this field will move to the `worlds` array after the "multi-worlds" update.
    // It will then be `nil`. You can enable the Multi-worlds advanced project option to enable
    // the change immediately.  An enum that describes how levels are organized in
    // this project (ie. linearly or in a 2D space). Possible values: &lt;`nil`&gt;, `Free`,
    // `GridVania`, `LinearHorizontal`, `LinearVertical`
    world_layout:           Maybe(WorldLayout) `json:"worldLayout"`,
    // This array is not used yet in current LDtk version (so, for now, it's always
    // empty).In a later update, it will be possible to have multiple Worlds in a
    // single project, each containing multiple Levels.What will change when "Multiple
    // worlds" support will be added to LDtk: - in current version, a LDtk project
    // file can only contain a single world with multiple levels in it. In this case, levels and
    // world layout related settings are stored in the root of the JSON. - after the
    // "Multiple worlds" update, there will be a `worlds` array in root, each world containing
    // levels and layout settings. Basically, it's pretty much only about moving the `levels`
    // array to the `worlds` array, along with world layout related values (eg. `worldGridWidth`
    // etc).If you want to start supporting this future update easily, please refer to
    // this documentation: https://github.com/deepnight/ldtk/issues/231
    worlds:                 []World `json:"worlds"`,
}


// This section contains all the level data. It can be found in 2 distinct forms, depending
// on Project current settings:  - If "*Separate level files*" is **disabled** (default):
// full level data is *embedded* inside the main Project JSON file, - If "*Separate level
// files*" is **enabled**: level data is stored in *separate* standalone `.ldtkl` files (one
// per level). In this case, the main Project JSON file will still contain most level data,
// except heavy sections, like the `layerInstances` array (which will be nil). The
// `externalRelPath` string points to the `ldtkl` file.  A `ldtkl` file is just a JSON file
// containing exactly what is described below.
Level :: struct {
    // Position informations of the background image, if there is one.
    bg_pos:              Maybe(LevelBackgroundPosition) `json:"__bgPos"`,
    // An array listing all other levels touching this one on the world map.  Only relevant
    // for world layouts where level spatial positioning is manual (ie. GridVania, Free). For
    // Horizontal and Vertical layouts, this array is always empty.
    neighbours:          []NeighbourLevel `json:"__neighbours"`,
    // The "guessed" color for this level in the editor, decided using either the background
    // color or an existing custom field.
    smart_color:         string `json:"__smartColor"`,
    // Background color of the level. If `nil`, the project `defaultLevelBgColor` should be
    // used.
    bg_color:            Maybe(string) `json:"bgColor"`,
    // Background image X pivot (0-1)
    bg_pivot_x:          f32 `json:"bgPivotX"`,
    // Background image Y pivot (0-1)
    bg_pivot_y:          f32 `json:"bgPivotY"`,
    // An enum defining the way the background image (if any) is positioned on the level. See
    // `__bgPos` for resulting position info. Possible values: &lt;`nil`&gt;, `Unscaled`,
    // `Contain`, `Cover`, `CoverDirty`
    bg_pos_type:         Maybe(BgPos) `json:"bgPos"`,
    // The *optional* relative path to the level background image.
    bg_rel_path:         Maybe(string) `json:"bgRelPath"`,
    // This value is not nil if the project option "*Save levels separately*" is enabled. In
    // this case, this **relative** path points to the level Json file.
    external_rel_path:   Maybe(string) `json:"externalRelPath"`,
    // An array containing this level custom field values.
    field_instances:     []FieldInstance `json:"fieldInstances"`,
    // User defined unique identifier
    identifier:          string `json:"identifier"`,
    // Unique instance identifier
    iid:                 string `json:"iid"`,
    // An array containing all Layer instances. **IMPORTANT**: if the project option "*Save
    // levels separately*" is enabled, this field will be `nil`.  This array is **sorted
    // in display order**: the 1st layer is the top-most and the last is behind.
    layer_instances:     Maybe([]LayerInstance) `json:"layerInstances"`,
    // Height of the level in pixels
    px_height:           i32 `json:"pxHei"`,
    // Width of the level in pixels
    px_width:            i32 `json:"pxWid"`,
    // Unique Int identifier
    uid:                 i32 `json:"uid"`,
    // If TRUE, the level identifier will always automatically use the naming pattern as defined
    // in `Project.levelNamePattern`. Becomes FALSE if the identifier is manually modified by
    // user.
    use_auto_identifier: bool `json:"useAutoIdentifier"`,
    // Index that represents the "depth" of the level in the world. Default is 0, greater means
    // "above", lower means "below".  This value is mostly used for display only and is
    // intended to make stacking of levels easier to manage.
    world_depth:         i32 `json:"worldDepth"`,
    // World X coordinate in pixels.  Only relevant for world layouts where level spatial
    // positioning is manual (ie. GridVania, Free). For Horizontal and Vertical layouts, the
    // value is always -1 here.
    world_x:             i32 `json:"worldX"`,
    // World Y coordinate in pixels.  Only relevant for world layouts where level spatial
    // positioning is manual (ie. GridVania, Free). For Horizontal and Vertical layouts, the
    // value is always -1 here.
    world_y:             i32 `json:"worldY"`,
}

// If you're writing your own LDtk importer, you should probably just ignore *most* stuff in
// the `defs` section, as it contains data that are mostly important to the editor. To keep
// you away from the `defs` section and avoid some unnecessary JSON parsing, important data
// from definitions is often duplicated in fields prefixed with a double underscore (eg.
// `__identifier` or `__type`).  The 2 only definition types you might need here are
// **Tilesets** and **Enums**.
//
// A structure containing all the definitions of this project
Definitions :: struct {
    // All entities definitions, including their custom fields
    entities:       []EntityDefinition `json:"entities"`,
    // All internal enums
    enums:          []EnumDefinition `json:"enums"`,
    // Note: external enums are exactly the same as `enums`, except they have a `relPath` to
    // point to an external source file.
    external_enums: []EnumDefinition `json:"externalEnums"`,
    // All layer definitions
    layers:         []LayerDefinition `json:"layers"`,
    // All custom fields available to all levels.
    level_fields:   []FieldDefinition `json:"levelFields"`,
    // All tilesets
    tilesets:       []TilesetDefinition `json:"tilesets"`,
}


EntityDefinition :: struct {
    // Base entity color
    color:              string `json:"color"`,
    // User defined documentation for this element to provide help/tips to level designers.
    doc:                Maybe(string) `json:"doc"`,
    // If enabled, all instances of this entity will be listed in the project "Table of content"
    // object.
    export_to_toc:      bool `json:"exportToToc"`,
    // Array of field definitions
    field_defs:         []FieldDefinition `json:"fieldDefs"`,
    fill_opacity:       f32 `json:"fillOpacity"`,
    // Pixel height
    height:             i32 `json:"height"`,
    hollow:             bool `json:"hollow"`,
    // User defined unique identifier
    identifier:         string `json:"identifier"`,
    // Only applies to entities resizable on both X/Y. If TRUE, the entity instance width/height
    // will keep the same aspect ratio as the definition.
    keep_aspect_ratio:  bool `json:"keepAspectRatio"`,
    // Possible values: `DiscardOldOnes`, `PreventAdding`, `MoveLastOne`
    limit_behavior:     LimitBehavior `json:"limitBehavior"`,
    // If TRUE, the maxCount is a "per world" limit, if FALSE, it's a "per level". Possible
    // values: `PerLayer`, `PerLevel`, `PerWorld`
    limit_scope:        LimitScope `json:"limitScope"`,
    line_opacity:       f32 `json:"lineOpacity"`,
    // Max instances count
    max_count:          i32 `json:"maxCount"`,
    // An array of 4 dimensions for the up/right/down/left borders (in this order) when using
    // 9-slice mode for `tileRenderMode`.  If the tileRenderMode is not NineSlice, then
    // this array is empty.  See: https://en.wikipedia.org/wiki/9-slice_scaling
    nine_slice_borders: []i32 `json:"nineSliceBorders"`,
    // Pivot X coordinate (from 0 to 1.0)
    pivot_x:            f32 `json:"pivotX"`,
    // Pivot Y coordinate (from 0 to 1.0)
    pivot_y:            f32 `json:"pivotY"`,
    // Possible values: `Rectangle`, `Ellipse`, `Tile`, `Cross`
    render_mode:        RenderMode `json:"renderMode"`,
    // If TRUE, the entity instances will be resizable horizontally
    resizable_x:        bool `json:"resizableX"`,
    // If TRUE, the entity instances will be resizable vertically
    resizable_y:        bool `json:"resizableY"`,
    // Display entity name in editor
    show_name:          bool `json:"showName"`,
    // An array of strings that classifies this entity
    tags:               []string `json:"tags"`,
    // **WARNING**: this deprecated value is no longer exported since version 1.2.0  Replaced
    // by: `tileRect`
    tile_id:            Maybe(i32) `json:"tileId"`,
    tile_opacity:       f32 `json:"tileOpacity"`,
    // An object representing a rectangle from an existing Tileset
    tile_rect:          Maybe(TilesetRectangle) `json:"tileRect"`,
    // An enum describing how the the Entity tile is rendered inside the Entity bounds. Possible
    // values: `Cover`, `FitInside`, `Repeat`, `Stretch`, `FullSizeCropped`,
    // `FullSizeUncropped`, `NineSlice`
    tile_render_mode:   TileRenderMode `json:"tileRenderMode"`,
    // Tileset ID used for optional tile display
    tileset_id:         Maybe(i32) `json:"tilesetId"`,
    // Unique Int identifier
    uid:                i32 `json:"uid"`,
    // Pixel width
    width:              i32 `json:"width"`,
}

LayerDefinition :: struct {
    // Type of the layer as Enum Possible values: `IntGrid`, `Entities`, `Tiles`, `AutoLayer`
    type:                      Type `json:"type"`,
    // Contains all the auto-layer rule definitions.
    auto_rule_groups:          []AutoLayerRuleGroup `json:"autoRuleGroups"`,
    auto_source_layer_def_uid: Maybe(i32) `json:"autoSourceLayerDefUid"`,
    // **WARNING**: this deprecated value is no longer exported since version 1.2.0  Replaced
    // by: `tilesetDefUid`
    auto_tileset_def_uid:      Maybe(i32) `json:"autoTilesetDefUid"`,
    // Allow editor selections when the layer is not currently active.
    can_select_when_inactive:  bool `json:"canSelectWhenInactive"`,
    // Opacity of the layer (0 to 1.0)
    display_opacity:           f32 `json:"displayOpacity"`,
    // User defined documentation for this element to provide help/tips to level designers.
    doc:                       Maybe(string) `json:"doc"`,
    // An array of tags to forbid some Entities in this layer
    excluded_tags:             []string `json:"excludedTags"`,
    // Width and height of the grid in pixels
    grid_size:                 i32 `json:"gridSize"`,
    // Height of the optional "guide" grid in pixels
    guide_grid_height:         i32 `json:"guideGridHei"`,
    // Width of the optional "guide" grid in pixels
    guide_grid_width:          i32 `json:"guideGridWid"`,
    hide_fields_when_inactive: bool `json:"hideFieldsWhenInactive"`,
    // Hide the layer from the list on the side of the editor view.
    hide_in_list:              bool `json:"hideInList"`,
    // User defined unique identifier
    identifier:                string `json:"identifier"`,
    // Alpha of this layer when it is not the active one.
    inactive_opacity:          f32 `json:"inactiveOpacity"`,
    // An array that defines extra optional info for each IntGrid value.  WARNING: the
    // array order is not related to actual IntGrid values! As user can re-order IntGrid values
    // freely, you may value "2" before value "1" in this array.
    int_grid_values:           []IntGridValueDefinition `json:"intGridValues"`,
    // Parallax horizontal factor (from -1 to 1, defaults to 0) which affects the scrolling
    // speed of this layer, creating a fake 3D (parallax) effect.
    parallax_factor_x:         f32 `json:"parallaxFactorX"`,
    // Parallax vertical factor (from -1 to 1, defaults to 0) which affects the scrolling speed
    // of this layer, creating a fake 3D (parallax) effect.
    parallax_factor_y:         f32 `json:"parallaxFactorY"`,
    // If true (default), a layer with a parallax factor will also be scaled up/down accordingly.
    parallax_scaling:          bool `json:"parallaxScaling"`,
    // X offset of the layer, in pixels (IMPORTANT: this should be added to the `LayerInstance`
    // optional offset)
    px_offset_x:               i32 `json:"pxOffsetX"`,
    // Y offset of the layer, in pixels (IMPORTANT: this should be added to the `LayerInstance`
    // optional offset)
    px_offset_y:               i32 `json:"pxOffsetY"`,
    // An array of tags to filter Entities that can be added to this layer
    required_tags:             []string `json:"requiredTags"`,
    // If the tiles are smaller or larger than the layer grid, the pivot value will be used to
    // position the tile relatively its grid cell.
    tile_pivot_x:              f32 `json:"tilePivotX"`,
    // If the tiles are smaller or larger than the layer grid, the pivot value will be used to
    // position the tile relatively its grid cell.
    tile_pivot_y:              f32 `json:"tilePivotY"`,
    // Reference to the default Tileset UID being used by this layer definition.
    // **WARNING**: some layer *instances* might use a different tileset. So most of the time,
    // you should probably use the `__tilesetDefUid` value found in layer instances.  Note:
    // since version 1.0.0, the old `autoTilesetDefUid` was removed and merged into this value.
    tileset_def_uid:           Maybe(i32) `json:"tilesetDefUid"`,
    // Unique Int identifier
    uid:                       i32 `json:"uid"`,
}


AutoLayerRuleGroup :: struct {
    active:      bool `json:"active"`,
    // *This field was removed in 1.0.0 and should no longer be used.*
    collapsed:   Maybe(bool) `json:"collapsed"`,
    is_optional: bool `json:"isOptional"`,
    name:        string `json:"name"`,
    rules:       []AutoLayerRuleDefinition `json:"rules"`,
    uid:         i32 `json:"uid"`,
    uses_wizard: bool `json:"usesWizard"`,
}

// This complex section isn't meant to be used by game devs at all, as these rules are
// completely resolved internally by the editor before any saving. You should just ignore
// this part.
AutoLayerRuleDefinition :: struct {
    // If FALSE, the rule effect isn't applied, and no tiles are generated.
    active:              bool `json:"active"`,
    // When TRUE, the rule will prevent other rules to be applied in the same cell if it matches
    // (TRUE by default).
    break_on_match:      bool `json:"breakOnMatch"`,
    // Chances for this rule to be applied (0 to 1)
    chance:              f32 `json:"chance"`,
    // Checker mode Possible values: `None`, `Horizontal`, `Vertical`
    checker:             Checker `json:"checker"`,
    // If TRUE, allow rule to be matched by flipping its pattern horizontally
    flip_x:              bool `json:"flipX"`,
    // If TRUE, allow rule to be matched by flipping its pattern vertically
    flip_y:              bool `json:"flipY"`,
    // Default IntGrid value when checking cells outside of level bounds
    out_of_bounds_value: Maybe(i32) `json:"outOfBoundsValue"`,
    // Rule pattern (size x size)
    pattern:             []i32 `json:"pattern"`,
    // If TRUE, enable Perlin filtering to only apply rule on specific random area
    perlin_active:       bool `json:"perlinActive"`,
    perlin_octaves:      f32 `json:"perlinOctaves"`,
    perlin_scale:        f32 `json:"perlinScale"`,
    perlin_seed:         f32 `json:"perlinSeed"`,
    // X pivot of a tile stamp (0-1)
    pivot_x:             f32 `json:"pivotX"`,
    // Y pivot of a tile stamp (0-1)
    pivot_y:             f32 `json:"pivotY"`,
    // Pattern width & height. Should only be 1,3,5 or 7.
    size:                i32 `json:"size"`,
    // Array of all the tile IDs. They are used randomly or as stamps, based on `tileMode` value.
    tile_ids:            []i32 `json:"tileIds"`,
    // Defines how tileIds array is used Possible values: `Single`, `Stamp`
    tile_mode:           TileMode `json:"tileMode"`,
    // Unique Int identifier
    uid:                 i32 `json:"uid"`,
    // X cell coord modulo
    x_modulo:            i32 `json:"xModulo"`,
    // X cell start offset
    x_offset:            i32 `json:"xOffset"`,
    // Y cell coord modulo
    y_modulo:            i32 `json:"yModulo"`,
    // Y cell start offset
    y_offset:            i32 `json:"yOffset"`,
}

// IntGrid value definition
IntGridValueDefinition :: struct {
    color:      string `json:"color"`,
    // User defined unique identifier
    identifier: Maybe(string) `json:"identifier"`,
    // The IntGrid value itself
    value:      i32 `json:"value"`,
}

// The `Tileset` definition is the most important part among project definitions. It
// contains some extra informations about each integrated tileset. If you only had to parse
// one definition section, that would be the one.
TilesetDefinition :: struct {
    // Grid-based height
    c_height:             i32 `json:"__cHei"`,
    // Grid-based width
    c_width:              i32 `json:"__cWid"`,
    // An array of custom tile metadata
    custom_data:          []TileCustomMetadata `json:"customData"`,
    // If this value is set, then it means that this atlas uses an internal LDtk atlas image
    // instead of a loaded one. Possible values: &lt;`nil`&gt;, `LdtkIcons`
    embed_atlas:          Maybe(EmbedAtlas) `json:"embedAtlas"`,
    // Tileset tags using Enum values specified by `tagsSourceEnumId`. This array contains 1
    // element per Enum value, which contains an array of all Tile IDs that are tagged with it.
    enum_tags:            []EnumTagValue `json:"enumTags"`,
    // User defined unique identifier
    identifier:           string `json:"identifier"`,
    // Distance in pixels from image borders
    padding:              i32 `json:"padding"`,
    // Image height in pixels
    px_height:            i32 `json:"pxHei"`,
    // Image width in pixels
    px_width:             i32 `json:"pxWid"`,
    // Path to the source file, relative to the current project JSON file  It can be nil
    // if no image was provided, or when using an embed atlas.
    rel_path:             Maybe(string) `json:"relPath"`,

    // Space in pixels between all tiles
    spacing:              i32 `json:"spacing"`,
    // An array of user-defined tags to organize the Tilesets
    tags:                 []string `json:"tags"`,
    // Optional Enum definition UID used for this tileset meta-data
    tags_source_enum_uid: Maybe(i32) `json:"tagsSourceEnumUid"`,
    tile_grid_size:       i32 `json:"tileGridSize"`,
    // Unique Intidentifier
    uid:                  i32 `json:"uid"`,
}

// In a tileset definition, user defined meta-data of a tile.
TileCustomMetadata :: struct {
    data:    string `json:"data"`,
    tile_id: i32 `json:"tileId"`,
}

// In a tileset definition, enum based tag infos
EnumTagValue :: struct {
    enum_value_id: string `json:"enumValueId"`,
    tile_ids:      []i32 `json:"tileIds"`,
}

EntityInstance :: struct {
    // Grid-based coordinates (`[x,y]` format)
    grid:            [2]i32 `json:"__grid"`,
    // Entity definition identifier
    identifier:      string `json:"__identifier"`,
    // Pivot coordinates  (`[x,y]` format, values are from 0 to 1) of the Entity
    pivot:           [2]f32 `json:"__pivot"`,
    // The entity "smart" color, guessed from either Entity definition, or one its field
    // instances.
    smart_color:     string `json:"__smartColor"`,
    // Array of tags defined in this Entity definition
    tags:            []string `json:"__tags"`,
    // Optional TilesetRect used to display this entity (it could either be the default Entity
    // tile, or some tile provided by a field value, like an Enum).
    tile:            Maybe(TilesetRectangle) `json:"__tile"`,
    // Reference of the **Entity definition** UID
    def_uid:         i32 `json:"defUid"`,
    // An array of all custom fields and their values.
    field_instances: []FieldInstance `json:"fieldInstances"`,
    // Entity height in pixels. For non-resizable entities, it will be the same as Entity
    // definition.
    height:          i32 `json:"height"`,
    // Unique instance identifier
    iid:             string `json:"iid"`,
    // Pixel coordinates (`[x,y]` format) in current level coordinate space. Don't forget
    // optional layer offsets, if they exist!
    px:              [2]i32 `json:"px"`,
    // Entity width in pixels. For non-resizable entities, it will be the same as Entity
    // definition.
    width:           i32 `json:"width"`,
}

FieldInstance :: struct {
    // Field definition identifier
    identifier: string `json:"__identifier"`,
    // Optional TilesetRect used to display this field (this can be the field own Tile, or some
    // other Tile guessed from the value, like an Enum).
    tile:       Maybe(TilesetRectangle) `json:"__tile"`,
    // Type of the field, such as `Int`, `Float`, `string`, `Enum(my_enum_name)`, `Bool`,
    // etc.  NOTE: if you enable the advanced option **Use Multilines type**, you will have
    // "*Multilines*" instead of "*string*" when relevant.
    type:       string `json:"__type"`,
    // Actual value of the field instance. The value type varies, depending on `__type`:
    // - For **classic types** (ie. Integer, Float, Boolean, string, Text and FilePath), you
    // just get the actual value with the expected type.   - For **Color**, the value is an
    // hexadecimal string using "#rrggbb" format.   - For **Enum**, the value is a string
    // representing the selected enum value.   - For **Point**, the value is a
    // [GridPoint](#ldtk-GridPoint) object.   - For **Tile**, the value is a
    // [TilesetRect](#ldtk-TilesetRect) object.   - For **EntityRef**, the value is an
    // [EntityReferenceInfos](#ldtk-EntityReferenceInfos) object.  If the field is an
    // array, then this `__value` will also be a JSON array.
    value:      json.Value `json:"__value"`,
    // Reference of the **Field definition** UID
    def_uid:    i32 `json:"defUid"`,
    // Editor internal raw values
    // realEditorValues: []Maybe(any),
}

// This object describes the "location" of an Entity instance in the project worlds.
EntityReferenceInfos :: struct {
    // IID of the refered EntityInstance
    entity_iid: string `json:"entityIid"`,
    // IID of the LayerInstance containing the refered EntityInstance
    layer_iid:  string `json:"layerIid"`,
    // IID of the Level containing the refered EntityInstance
    level_iid:  string `json:"levelIid"`,
    // IID of the World containing the refered EntityInstance
    world_iid:  string `json:"worldIid"`,
}

// This object is just a grid-based coordinate used in Field values.
GridPoint :: struct {
    // X grid-based coordinate
    cx: i32 `json:"cx"`,
    // Y grid-based coordinate
    cy: i32 `json:"cy"`,
}

// IntGrid value instance
IntGridValueInstance :: struct {
    // Coordinate ID in the layer grid
    coord_id: i32 `json:"coordId"`,
    // IntGrid value
    v:        i32 `json:"v"`,
}


LayerInstance :: struct {
    // Grid-based height
    c_height:             i32 `json:"__cHei"`,
    // Grid-based width
    c_width:              i32 `json:"__cWid"`,
    // Grid size
    grid_size:            i32 `json:"__gridSize"`,
    // Layer definition identifier
    identifier:           string `json:"__identifier"`,
    // Layer opacity as Float [0-1]
    opacity:              f32 `json:"__opacity"`,
    // Total layer X pixel offset, including both instance and definition offsets.
    px_total_offset_x:    i32 `json:"__pxTotalOffsetX"`,
    // Total layer Y pixel offset, including both instance and definition offsets.
    px_total_offset_y:    i32 `json:"__pxTotalOffsetY"`,
    // The definition UID of corresponding Tileset, if any.
    tileset_def_uid:      Maybe(i32) `json:"__tilesetDefUid"`,
    // The relative path to corresponding Tileset, if any.
    tileset_rel_path:     Maybe(string) `json:"__tilesetRelPath"`,
    // Layer type (possible values: IntGrid, Entities, Tiles or AutoLayer)
    type:                 LayerType `json:"__type"`,
    // An array containing all tiles generated by Auto-layer rules. The array is already sorted
    // in display order (ie. 1st tile is beneath 2nd, which is beneath 3rd etc.).
    // Note: if multiple tiles are stacked in the same cell as the result of different rules,
    // all tiles behind opaque ones will be discarded.
    auto_layer_tiles:     []TileInstance `json:"autoLayerTiles"`,
    entity_instances:     []EntityInstance `json:"entityInstances"`,
    grid_tiles:           []TileInstance `json:"gridTiles"`,
    // Unique layer instance identifier
    iid:                  string `json:"iid"`,
    // **WARNING**: this deprecated value is no longer exported since version 1.0.0  Replaced
    // by: `intGridCsv`
    int_grid:             Maybe([]IntGridValueInstance) `json:"intGrid"`,
    // A list of all values in the IntGrid layer, stored in CSV format (Comma Separated
    // Values).  Order is from left to right, and top to bottom (ie. first row from left to
    // right, followed by second row, etc).  `0` means "empty cell" and IntGrid values
    // start at 1.  The array size is `__cWid` x `__cHei` cells.
    int_grid_csv:         []i32 `json:"intGridCsv"`,
    // Reference the Layer definition UID
    layer_def_uid:        i32 `json:"layerDefUid"`,
    // Reference to the UID of the level containing this layer instance
    level_id:             i32 `json:"levelId"`,
    // An Array containing the UIDs of optional rules that were enabled in this specific layer
    // instance.
    optional_rules:       []i32 `json:"optionalRules"`,
    // This layer can use another tileset by overriding the tileset UID here.
    override_tileset_uid: Maybe(i32) `json:"overrideTilesetUid"`,
    // X offset in pixels to render this layer, usually 0 (IMPORTANT: this should be added to
    // the `LayerDef` optional offset, so you should probably prefer using `__pxTotalOffsetX`
    // which contains the total offset value)
    px_offset_x:          i32 `json:"pxOffsetX"`,
    // Y offset in pixels to render this layer, usually 0 (IMPORTANT: this should be added to
    // the `LayerDef` optional offset, so you should probably prefer using `__pxTotalOffsetX`
    // which contains the total offset value)
    px_offset_y:          i32 `json:"pxOffsetY"`,
    // Random seed used for Auto-Layers rendering
    seed:                 i32 `json:"seed"`,
    // Layer instance visibility
    visible:              bool `json:"visible"`,
}

// This structure represents a single tile from a given Tileset.
TileInstance :: struct {
    // Internal data used by the editor.  For auto-layer tiles: `[ruleId, coordId]`.
    // For tile-layer tiles: `[coordId]`.
    d:   [2]i32 `json:"d"`,
    // "Flip bits", a 2-bits integer to represent the mirror transformations of the tile.
    // - Bit 0 = X flip   - Bit 1 = Y flip   Examples: f=0 (no flip), f=1 (X flip
    // only), f=2 (Y flip only), f=3 (both flips)
    f:   i32 `json:"f"`,
    // Pixel coordinates of the tile in the **layer** (`[x,y]` format). Don't forget optional
    // layer offsets, if they exist!
    px:  [2]i32 `json:"px"`,
    // Pixel coordinates of the tile in the **tileset** (`[x,y]` format)
    src: [2]i32 `json:"src"`,
    // The *Tile ID* in the corresponding tileset.
    t:   i32 `json:"t"`,
}

// Level background image position info
LevelBackgroundPosition :: struct {
    // An array of 4 float values describing the cropped sub-rectangle of the displayed
    // background image. This cropping happens when original is larger than the level bounds.
    // Array format: `[ cropX, cropY, cropWidth, cropHeight ]`
    crop_rect:   [4]f32 `json:"cropRect"`,
    // An array containing the `[scaleX,scaleY]` values of the **cropped** background image,
    // depending on `bgPos` option.
    scale:       [2]f32 `json:"scale"`,
    // An array containing the `[x,y]` pixel coordinates of the top-left corner of the
    // **cropped** background image, depending on `bgPos` option.
    top_left_px: [2]i32 `json:"topLeftPx"`,
}

// Nearby level info

NeighbourLevel :: struct {
    // A single lowercase character tipping on the level location (`n`orth, `s`outh, `w`est,
    // `e`ast).
    dir:       string `json:"dir"`,
    // Neighbour Instance Identifier
    level_iid: string `json:"levelIid"`,
    // **WARNING**: this deprecated value is no longer exported since version 1.2.0  Replaced
    // by: `levelIid`
    level_uid: Maybe(i32) `json:"levelUid"`,
}


LdtkTableOfContentEntry :: struct {
    identifier: string `json:"identifier"`,
    instances:  []EntityReferenceInfos `json:"instances"`,
}

// This section is mostly only intended for the LDtk editor app itself. You can safely
// ignore it.
FieldDefinition :: struct {
    // Human readable value type. Possible values: `Int, Float, string, Bool, Color,
    // ExternEnum.XXX, LocalEnum.XXX, Point, FilePath`.  If the field is an array, this
    // field will look like `Array<...>` (eg. `Array<Int>`, `Array<Point>` etc.)  NOTE: if
    // you enable the advanced option **Use Multilines type**, you will have "*Multilines*"
    // instead of "*string*" when relevant.
    type_string:            string `json:"__type"`,
    // Optional list of accepted file extensions for FilePath value type. Includes the dot:
    // `.ext`
    accept_file_types:      Maybe([]string) `json:"acceptFileTypes"`,
    // Possible values: `Any`, `OnlySame`, `OnlyTags`
    allowed_refs:           AllowedRefs `json:"allowedRefs"`,
    allowed_ref_tags:       []string `json:"allowedRefTags"`,
    allow_out_of_level_ref: bool `json:"allowOutOfLevelRef"`,
    // Array max length
    array_max_length:       Maybe(i32) `json:"arrayMaxLength"`,
    // Array min length
    array_min_length:       Maybe(i32) `json:"arrayMinLength"`,
    auto_chain_ref:         bool `json:"autoChainRef"`,
    // TRUE if the value can be nil. For arrays, TRUE means it can contain nil values
    // (exception: array of Points can't have nil values).
    can_be_nil:             bool `json:"canBeNil"`,
    // Default value if selected value is nil or invalid.
    // defaultOverride:     Maybe(any),
    // User defined documentation for this field to provide help/tips to level designers about
    // accepted values.
    doc:                    Maybe(string) `json:"doc"`,
    editor_always_show:     bool `json:"editorAlwaysShow"`,
    editor_cut_long_values: bool `json:"editorCutLongValues"`,
    // Possible values: `Hidden`, `ValueOnly`, `NameAndValue`, `EntityTile`, `Points`,
    // `PointStar`, `PointPath`, `PointPathLoop`, `RadiusPx`, `RadiusGrid`,
    // `ArrayCountWithLabel`, `ArrayCountNoLabel`, `RefLinkBetweenPivots`,
    // `RefLinkBetweenCenters`
    editor_display_mode:    EditorDisplayMode `json:"editorDisplayMode"`,
    // Possible values: `Above`, `Center`, `Beneath`
    editor_display_pos:     EditorDisplayPos `json:"editorDisplayPos"`,
    // Possible values: `ZigZag`, `StraightArrow`, `CurvedArrow`, `ArrowsLine`, `DashedLine`
    editor_link_style:      EditorLinkStyle `json:"editorLinkStyle"`,
    editor_show_in_world:   bool `json:"editorShowInWorld"`,
    editor_text_prefix:     Maybe(string) `json:"editorTextPrefix"`,
    editor_text_suffix:     Maybe(string) `json:"editorTextSuffix"`,
    // User defined unique identifier
    identifier:             string `json:"identifier"`,
    // TRUE if the value is an array of multiple values
    is_array:               bool `json:"isArray"`,
    // Max limit for value, if applicable
    max:                    Maybe(f32) `json:"max"`,
    // Min limit for value, if applicable
    min:                    Maybe(f32) `json:"min"`,
    // Optional regular expression that needs to be matched to accept values. Expected format:
    // `/some_reg_ex/g`, with optional "i" flag.
    regex:                  Maybe(string) `json:"regex"`,
    symmetrical_ref:        bool `json:"symmetricalRef"`,
    // Possible values: &lt;`nil`&gt;, `LangPython`, `LangRuby`, `LangJS`, `LangLua`, `LangC`,
    // `LangHaxe`, `LangMarkdown`, `LangJson`, `LangXml`, `LangLog`
    text_language_mode:     Maybe(TextLanguageMode) `json:"textLanguageMode"`,
    // UID of the tileset used for a Tile
    tileset_uid:            Maybe(i32) `json:"tilesetUid"`,
    // Internal enum representing the possible field types. Possible values: F_Int, F_Float,
    // F_string, F_Text, F_Bool, F_Color, F_Enum(...), F_Point, F_Path, F_EntityRef, F_Tile
    // TODO
    type:                   string `json:"type"`,
    // Unique Int identifier
    uid:                    i32 `json:"uid"`,
    // If TRUE, the color associated with this field will override the Entity or Level default
    // color in the editor UI. For Enum fields, this would be the color associated to their
    // values.
    use_for_smart_color:    bool `json:"useForSmartColor"`,
}

// This object represents a custom sub rectangle in a Tileset image.
TilesetRectangle :: struct {
    // Height in pixels
    h:           i32 `json:"h"`,
    // UID of the tileset
    tileset_uid: i32 `json:"tilesetUid"`,
    // Width in pixels
    w:           i32 `json:"w"`,
    // X pixels coordinate of the top-left corner in the Tileset image
    x:           i32 `json:"x"`,
    // Y pixels coordinate of the top-left corner in the Tileset image
    y:           i32 `json:"y"`,
}


EnumDefinition :: struct {
    external_file_checksum: Maybe(string) `json:"externalFileChecksum"`,
    // Relative path to the external file providing this Enum
    external_rel_path:      Maybe(string) `json:"externalRelPath"`,
    // Tileset UID if provided
    icon_tileset_uid:       Maybe(i32) `json:"iconTilesetUid"`,
    // User defined unique identifier
    identifier:             string `json:"identifier"`,
    // An array of user-defined tags to organize the Enums
    tags:                   []string `json:"tags"`,
    // Unique Int identifier
    uid:                    i32 `json:"uid"`,
    // All possible enum values, with their optional Tile infos.
    values:                 []EnumValueDefinition `json:"values"`,
}

EnumValueDefinition :: struct {
    // An array of 4 Int values that refers to the tile in the tileset image: `[ x, y, width,
    // height ]`
    tile_src_rect: Maybe([4]i32) `json:"__tileSrcRect"`,
    // Optional color
    color:         i32 `json:"color"`,
    // Enum value
    id:            string `json:"id"`,
    // The optional ID of the tile
    tile_id:       Maybe(i32) `json:"tileId"`,
}

LdtkCustomCommand :: struct {
    command: string `json:"command"`,
    // Possible values: `Manual`, `AfterLoad`, `BeforeSave`, `AfterSave`
    when_:   When `json:"when_"`,
}


When :: enum {
    AfterLoad,
    AfterSave,
    BeforeSave,
    Manual,
}

AllowedRefs :: enum {
    Any,
    OnlySame,
    OnlyTags,
}

EditorDisplayMode :: enum {
    ArrayCountNoLabel,
    ArrayCountWithLabel,
    EntityTile,
    Hidden,
    NameAndValue,
    PointPath,
    PointPathLoop,
    PointStar,
    Points,
    RadiusGrid,
    RadiusPx,
    RefLinkBetweenCenters,
    RefLinkBetweenPivots,
    ValueOnly,
}

EditorDisplayPos :: enum {
    Above,
    Beneath,
    Center,
}

EditorLinkStyle :: enum {
    ArrowsLine,
    CurvedArrow,
    DashedLine,
    StraightArrow,
    ZigZag,
}

TextLanguageMode :: enum {
    LangC,
    LangHaxe,
    LangJS,
    LangJson,
    LangLog,
    LangLua,
    LangMarkdown,
    LangPython,
    LangRuby,
    LangXml,
}

LimitBehavior :: enum {
    DiscardOldOnes,
    MoveLastOne,
    PreventAdding,
}

// If TRUE, the maxCount is a "per world" limit, if FALSE, it's a "per level". 
LimitScope :: enum {
    PerLayer,
    PerLevel,
    PerWorld,
}

RenderMode :: enum {
    Cross,
    Ellipse,
    Rectangle,
    Tile,
}

// An enum describing how the the Entity tile is rendered inside the Entity bounds. 
TileRenderMode :: enum {
    Cover,
    FitInside,
    FullSizeCropped,
    FullSizeUncropped,
    NineSlice,
    Repeat,
    Stretch,
}

Checker :: enum {
    Horizontal,
    None,
    Vertical,
}

TileMode :: enum {
    Single,
    Stamp,
}

Type :: enum {
    AutoLayer,
    Entities,
    IntGrid,
    Tiles,
}

EmbedAtlas :: enum {
    LdtkIcons,
}

Flag :: enum {
    DiscardPreCsvIntGrid,
    ExportPreCsvIntGridFormat,
    IgnoreBackupSuggest,
    MultiWorlds,
    PrependIndexToLevelFileNames,
    UseMultilinesType,
}

BgPos :: enum {
    Contain,
    Cover,
    CoverDirty,
    Unscaled,
}

WorldLayout :: enum {
    Free,
    GridVania,
    LinearHorizontal,
    LinearVertical,
}

// Naming convention for Identifiers (first-letter uppercase, full uppercase etc.) 
IdentifierStyle :: enum {
    Capitalize,
    Free,
    Lowercase,
    Uppercase,
}

// "Image export" option when saving project.
ImageExportMode :: enum {
    LayersAndLevels,
    None,
    OneImagePerLayer,
    OneImagePerLevel,
}

LayerType :: enum {
    IntGrid,
    Entities,
    Tiles,
    AutoLayer,
}

// **IMPORTANT**: this type is not used *yet* in current LDtk version. It's only presented
// here as a preview of a planned feature.  A World contains multiple levels, and it has its
// own layout settings.
World :: struct {
    // Default new level height
    default_level_height: i32 `json:"defaultLevelHeight"`,
    // Default new level width
    default_level_width:  i32 `json:"defaultLevelWidth"`,
    // User defined unique identifier
    identifier:           string `json:"identifier"`,
    // Unique instance identifer
    iid:                  string `json:"iid"`,
    // All levels from this world. The order of this array is only relevant in
    // `LinearHorizontal` and `linearVertical` world layouts (see `worldLayout` value).
    // Otherwise, you should refer to the `worldX`,`worldY` coordinates of each Level.
    levels:               []Level `json:"levels"`,
    // Height of the world grid in pixels.
    world_grid_height:    i32 `json:"worldGridHeight"`,
    // Width of the world grid in pixels.
    world_grid_width:     i32 `json:"worldGridWidth"`,
    // An enum that describes how levels are organized in this project (ie. linearly or in a 2D
    // space). Possible values: `Free`, `GridVania`, `LinearHorizontal`, `LinearVertical`, `nil`
    world_layout:         Maybe(WorldLayout) `json:"worldLayout"`,
}
