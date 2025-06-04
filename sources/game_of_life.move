module kata::game_of_life;

use std::string::{Self, String};

public enum CellState has copy, drop, store {
    Dead,
    Alive,
}

public struct GameOfLife has key {
    id: UID,
    width: u64,
    height: u64,
    cells: vector<vector<CellState>>,
}

public fun new(width: u64, height: u64, ctx: &mut TxContext) {
    let id = object::new(ctx);
    let mut cells = vector::empty<vector<CellState>>();
    let mut i = 0;
    while (i < height) {
        let mut row = vector::empty<CellState>();
        let mut j = 0;
        while (j < width) {
            vector::push_back(&mut row, CellState::Dead);
            j = j + 1;
        };
        vector::push_back(&mut cells, row);
        i = i + 1;
    };
    let obj = GameOfLife { id, width, height, cells };
    transfer::share_object(obj);
}

public fun get_cell(game: &GameOfLife, row: u64, col: u64): bool {
    if (row < game.height && col < game.width) {
        let row_ref = vector::borrow(&game.cells, row);
        match (*vector::borrow(row_ref, col)) {
            CellState::Alive => true,
            CellState::Dead => false,
        }
    } else {
        false
    }
}

public fun to_ascii_string(game: &GameOfLife): String {
    let mut result = string::utf8(b"");
    let mut i = 0;

    while (i < game.height) {
        let mut j = 0;
        while (j < game.width) {
            let cell_char = if (get_cell(game, i, j)) {
                string::utf8(b"*")
            } else {
                string::utf8(b".")
            };
            string::append(&mut result, cell_char);
            j = j + 1;
        };
        if (i < game.height - 1) {
            string::append(&mut result, string::utf8(b"\n"));
        };
        i = i + 1;
    };

    result
}

public fun width(game: &GameOfLife): u64 {
    game.width
}

public fun height(game: &GameOfLife): u64 {
    game.height
}

//// TESTING

#[test_only]
public fun next_generation(game: &mut GameOfLife) {
    let mut next_cells = vector::empty<vector<CellState>>();
    let mut i = 0;

    // Calculate the next state
    while (i < game.height) {
        let mut row = vector::empty<CellState>();
        let mut j = 0;
        while (j < game.width) {
            let neighbors = count_neighbors(game, i, j);
            let current_alive = get_cell(game, i, j);

            let next_alive = if (current_alive) {
                neighbors == 2 || neighbors == 3
            } else {
                neighbors == 3
            };

            let cell_state = if (next_alive) CellState::Alive else CellState::Dead;
            vector::push_back(&mut row, cell_state);
            j = j + 1;
        };
        vector::push_back(&mut next_cells, row);
        i = i + 1;
    };

    // Apply the next state
    game.cells = next_cells;
}

#[test_only]
fun count_neighbors(game: &GameOfLife, row: u64, col: u64): u8 {
    let mut count = 0;
    let mut i = if (row == 0) 0 else row - 1;
    let max_i = if (row + 1 >= game.height) game.height - 1 else row + 1;

    while (i <= max_i) {
        let mut j = if (col == 0) 0 else col - 1;
        let max_j = if (col + 1 >= game.width) game.width - 1 else col + 1;

        while (j <= max_j) {
            if (!(i == row && j == col) && get_cell(game, i, j)) {
                count = count + 1;
            };
            j = j + 1;
        };
        i = i + 1;
    };
    count
}

#[test_only]
public fun set_cell_for_testing(game: &mut GameOfLife, row: u64, col: u64, alive: bool) {
    if (row < game.height && col < game.width) {
        let row_ref = vector::borrow_mut(&mut game.cells, row);
        let cell_value = if (alive) CellState::Alive else CellState::Dead;
        *vector::borrow_mut(row_ref, col) = cell_value;
    }
}
