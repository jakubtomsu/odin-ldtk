#+build !js
package ldtk

import "core:os"

load_from_file :: proc(filename: string, allocator := context.allocator) -> Maybe(Project) {
    data, err := os.read_entire_file(filename, allocator)
    if err != os.ERROR_NONE {
        return nil
    }
    return load_from_memory(data, allocator)
}
