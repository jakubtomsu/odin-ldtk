package main

import "vendor:raylib"
import ldtk "../"
import "core:time"
import "core:math"

player: struct {
    pos: raylib.Vector2,
    vel: raylib.Vector2,
    last_anim_change: time.Tick,
    current_src_name: player_src_names,
    frame: u32,
    in_air: bool,
    running: bool,
    flip_x: bool,
}

tile :: struct {
    src: raylib.Vector2,
    dst: raylib.Vector2,
    flip_x: bool,
    flip_y: bool,
}

screen_width := 1280
screen_height := 720

tile_offset : raylib.Vector2;
tile_size := 32
tile_columns := -1
tile_rows := -1
collision_tiles: []u8
tile_data: []tile

player_src_names :: enum {
    IDLE0,
    IDLE1,
    IDLE2,
    IDLE3,
    RUN0,
    RUN1,
    RUN2,
    RUN3,
    RUN4,
    RUN5,
    IN_AIR0,
    IN_AIR1,
    IN_AIR2,
}

player_srcs: [player_src_names]raylib.Rectangle

main :: proc() {
    raylib.InitWindow(i32(screen_width), i32(screen_height), "Platt")

    raylib.SetTargetFPS(60);

    spritesheet := raylib.LoadTexture("12 Animated Character Template.png")
    player_srcs[.IDLE0] = {24.0 - 32.0 / 2.0, 32.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.IDLE1] = {72.0 - 32.0 / 2.0, 32.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.IDLE2] = {120.0 - 32.0 / 2.0, 32.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.IDLE3] = {168.0 - 32.0 / 2.0, 32.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.RUN0] = {24.0 - 32.0 / 2.0, 128.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.RUN1] = {72.0 - 32.0 / 2.0, 128.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.RUN2] = {120.0 - 32.0 / 2.0, 128.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.RUN3] = {168.0 - 32.0 / 2.0, 128.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.RUN4] = {220.0 - 32.0 / 2.0, 128.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.RUN5] = {268.0 - 32.0 / 2.0, 128.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.IN_AIR0] = {120.0 - 32.0 / 2.0, 174.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.IN_AIR1] = {168.0 - 32.0 / 2.0, 172.0 - 32.0 / 2.0, 32.0, 32.0}
    player_srcs[.IN_AIR2] = {220.0 - 32.0 / 2.0, 174.0 - 32.0 / 2.0, 32.0, 32.0}
    tileset := raylib.LoadTexture("Cavernas_by_Adam_Saltsman.png")


    if project, ok := ldtk.load_from_file("foo.ldtk", context.temp_allocator).?; ok {
        for level in project.levels {
            for layer in level.layer_instances.? {
                switch layer.type {
                case .IntGrid:
                    tile_columns = layer.c_width
                    tile_rows = layer.c_height
                    //tile_size = 720 / tile_rows
                    collision_tiles = make([]u8, tile_columns * tile_rows)
                    tile_offset.x = f32(layer.px_total_offset_x)
                    tile_offset.y = f32(layer.px_total_offset_y)

                    for val, idx in layer.int_grid_csv {
                        collision_tiles[idx] = u8(val)
                    }


                    tile_data = make([]tile, len(layer.auto_layer_tiles))

                    multiplier : f32 = f32(tile_size) / f32(layer.grid_size)
                    for val, idx in layer.auto_layer_tiles {
                        tile_data[idx].dst.x = f32(val.px.x) * multiplier
                        tile_data[idx].dst.y = f32(val.px.y) * multiplier
                        tile_data[idx].src.x = f32(val.src.x)
                        f := val.f
                        tile_data[idx].src.y = f32(val.src.y)
                        tile_data[idx].flip_x = bool(f & 1)
                        tile_data[idx].flip_y = bool(f & 2)
                    }
                case .Entities:
                case .Tiles:
                case .AutoLayer:
                }
            }
        }

        // ...
    }

    if tile_columns == -1 || tile_rows == -1 {
        return
    }

    player.pos.x = 100
    player.pos.y = 300
    player.in_air = true

    dt : f32 = 1.0 / 60.0
    for !raylib.WindowShouldClose() {
        raylib.BeginDrawing()
            raylib.ClearBackground(raylib.RAYWHITE)

            jump_power :: 580.0
            spd :: 50.0
            if !player.in_air {
                if raylib.IsKeyDown(.W) {
                    player.in_air = true
                    player.vel.y -= jump_power
                }
            }
            player.running = false
            if raylib.IsKeyDown(.A) {
                player.vel.x -= spd
                player.running = true
                player.flip_x = true
            }
            if raylib.IsKeyDown(.D) {
                player.vel.x += spd
                player.running = true
                player.flip_x = false
            }

            epsilon : f32 = 2.0
            if player.vel.x < -epsilon || player.vel.x > epsilon {
                player.vel.x *= 0.88
            } else {
                player.vel.x = 0.0
            }

            if time.tick_since(player.last_anim_change) > 80 * time.Millisecond {
                player.last_anim_change = time.tick_now()

                if (player.in_air) {
                    if player.vel.y > 0.0 {
                        player.frame = 2
                    } else if player.vel.y == 0.0 {
                        player.frame = 1
                    } else if player.vel.y < 0.0 {
                        player.frame = 0
                    }
                } else {
                    if (player.running) {
                        player.frame = (player.frame + 1) % 6
                    } else {
                        player.frame = (player.frame + 1) % 4
                    }
                }
            }

            if player.in_air {
                player.current_src_name = player_src_names(u32(player_src_names.IN_AIR0) + (player.frame % 3))
            } else {
                if player.running {
                    player.current_src_name = player_src_names(u32(player_src_names.RUN0) + player.frame)
                } else {
                    player.current_src_name = player_src_names(u32(player_src_names.IDLE0) + player.frame)
                }
            }

            player.vel.y += 900 * dt

            new_pos : raylib.Vector2 = player.pos + player.vel * dt

            offset: raylib.Vector2
            offset.x = f32(screen_width - (tile_size * tile_columns)) / 2.0

            player_coll : raylib.Rectangle = {new_pos.x - 16.0, new_pos.y - 64.0, 32.0, 64.0}
            player_center_row := int(math.round((new_pos.y - 32.0) / f32(tile_size)))
            player_upper_row := int(math.round((new_pos.y - 64.0) / f32(tile_size)))
            player_column := int(math.round(new_pos.x / f32(tile_size)))
            for row := 0; row < tile_rows; row += 1 {
                for column := 0; column < tile_columns; column += 1 {
                    collider := collision_tiles[row * tile_columns + column]

                    if collider != 0 {
                        coll : raylib.Rectangle = {f32(column * tile_size) + offset.x + tile_offset.x - f32(tile_size) / 2.0, f32(row * tile_size) + offset.y + tile_offset.y - f32(tile_size) / 2.0, f32(tile_size), f32(tile_size)}
                        raylib.DrawRectangleRec(coll, raylib.RED)
                        if raylib.CheckCollisionRecs(player_coll, coll) {

                            if player.in_air {
                                if row <= player_upper_row {
                                    if player.vel.y < 0 {
                                        player.vel.y = 0
                                        new_pos.y = player.pos.y
                                    }
                                }
                            }
                            
                            if row > player_center_row {
                                if player.vel.y > 0 {
                                    player.in_air = false
                                    player.vel.y = 0
                                    new_pos.y = player.pos.y
                                }

                            } else {
                                if column > player_column || column < player_column {
                                    player.vel.x = 0
                                    new_pos.x = player.pos.x
                                }


                            }
                        }
                    }
                }
            }

            player.pos.x = new_pos.x
            player.pos.y = new_pos.y

            for val, idx in tile_data {
                source_rect : raylib.Rectangle = {val.src.x, val.src.y, 8.0, 8.0}
                if val.flip_x {
                    source_rect.width *= -1.0
                }
                if val.flip_y {
                    source_rect.height *= -1.0
                }
                dst_rect : raylib.Rectangle = {val.dst.x + offset.x + tile_offset.x, val.dst.y + offset.y + tile_offset.y, f32(tile_size), f32(tile_size)}
                raylib.DrawTexturePro(tileset, source_rect, dst_rect, {f32(tile_size/2),f32(tile_size/2)}, 0, raylib.WHITE)
            }

            pos := player.pos
            source_rect := player_srcs[player.current_src_name]
            if player.flip_x {
                source_rect.width *= -1.0
            }
            dst_rect : raylib.Rectangle = {pos.x, pos.y - 32.0, 64.0, 64.0}
            raylib.DrawTexturePro(spritesheet, source_rect, dst_rect, {32.0,32.0}, 0, raylib.WHITE)

            //raylib.DrawRectangleRec(player_coll, raylib.BLUE)
        raylib.EndDrawing()
    }

    raylib.CloseWindow()
}
