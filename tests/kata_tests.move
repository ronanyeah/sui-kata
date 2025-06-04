#[test_only]
module kata::kata_tests;

use kata::game_of_life;

const SIGNER: address = @0xFADE;

#[test]
fun test_new_game() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(3, 3, ctx);
    test.next_tx(SIGNER);
    let game = test.take_shared<game_of_life::GameOfLife>();
    assert!(game_of_life::width(&game) == 3);
    assert!(game_of_life::height(&game) == 3);

    let mut i = 0;
    while (i < 3) {
        let mut j = 0;
        while (j < 3) {
            assert!(!game_of_life::get_cell(&game, i, j));
            j = j + 1;
        };
        i = i + 1;
    };
    ts::return_shared(game);
    test.end();
}

#[test]
fun test_set_and_get_cell() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(3, 3, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();

    game_of_life::set_cell_for_testing(&mut game, 1, 1, true);
    assert!(game_of_life::get_cell(&game, 1, 1));
    assert!(!game_of_life::get_cell(&game, 0, 0));

    game_of_life::set_cell_for_testing(&mut game, 1, 1, false);
    assert!(!game_of_life::get_cell(&game, 1, 1));

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_out_of_bounds() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(3, 3, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();

    game_of_life::set_cell_for_testing(&mut game, 5, 5, true);
    assert!(!game_of_life::get_cell(&game, 5, 5));

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_blinker_pattern() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(5, 5, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();

    game_of_life::set_cell_for_testing(&mut game, 2, 1, true);
    game_of_life::set_cell_for_testing(&mut game, 2, 2, true);
    game_of_life::set_cell_for_testing(&mut game, 2, 3, true);

    game_of_life::next_generation(&mut game);

    assert!(!game_of_life::get_cell(&game, 2, 1));
    assert!(game_of_life::get_cell(&game, 1, 2));
    assert!(game_of_life::get_cell(&game, 2, 2));
    assert!(game_of_life::get_cell(&game, 3, 2));
    assert!(!game_of_life::get_cell(&game, 2, 3));

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_block_pattern() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(4, 4, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();

    game_of_life::set_cell_for_testing(&mut game, 1, 1, true);
    game_of_life::set_cell_for_testing(&mut game, 1, 2, true);
    game_of_life::set_cell_for_testing(&mut game, 2, 1, true);
    game_of_life::set_cell_for_testing(&mut game, 2, 2, true);

    game_of_life::next_generation(&mut game);

    assert!(game_of_life::get_cell(&game, 1, 1));
    assert!(game_of_life::get_cell(&game, 1, 2));
    assert!(game_of_life::get_cell(&game, 2, 1));
    assert!(game_of_life::get_cell(&game, 2, 2));

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_death_by_underpopulation() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(3, 3, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();

    game_of_life::set_cell_for_testing(&mut game, 1, 1, true);

    game_of_life::next_generation(&mut game);
    assert!(!game_of_life::get_cell(&game, 1, 1));

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_death_by_overpopulation() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(3, 3, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();

    game_of_life::set_cell_for_testing(&mut game, 1, 1, true);
    game_of_life::set_cell_for_testing(&mut game, 0, 0, true);
    game_of_life::set_cell_for_testing(&mut game, 0, 1, true);
    game_of_life::set_cell_for_testing(&mut game, 0, 2, true);
    game_of_life::set_cell_for_testing(&mut game, 1, 0, true);
    game_of_life::set_cell_for_testing(&mut game, 1, 2, true);

    game_of_life::next_generation(&mut game);
    assert!(!game_of_life::get_cell(&game, 1, 1));

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_birth_by_reproduction() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(3, 3, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();

    game_of_life::set_cell_for_testing(&mut game, 0, 1, true);
    game_of_life::set_cell_for_testing(&mut game, 1, 0, true);
    game_of_life::set_cell_for_testing(&mut game, 1, 2, true);

    game_of_life::next_generation(&mut game);
    assert!(game_of_life::get_cell(&game, 1, 1));

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_to_ascii_string_empty() {
    use sui::test_scenario as ts;
    use std::string;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(3, 3, ctx);
    test.next_tx(SIGNER);
    let game = test.take_shared<game_of_life::GameOfLife>();
    let ascii = game_of_life::to_ascii_string(&game);
    let expected = string::utf8(b"...\n...\n...");
    assert!(ascii == expected);

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_to_ascii_string_with_cells() {
    use sui::test_scenario as ts;
    use std::string;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(3, 3, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();
    game_of_life::set_cell_for_testing(&mut game, 0, 0, true);
    game_of_life::set_cell_for_testing(&mut game, 1, 1, true);
    game_of_life::set_cell_for_testing(&mut game, 2, 2, true);

    let ascii = game_of_life::to_ascii_string(&game);
    let expected = string::utf8(b"*..\n.*.\n..*");
    assert!(ascii == expected);

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_single_cell_grid() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(1, 1, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();
    game_of_life::set_cell_for_testing(&mut game, 0, 0, true);

    game_of_life::next_generation(&mut game);
    assert!(!game_of_life::get_cell(&game, 0, 0));

    ts::return_shared(game);
    test.end();
}

#[test]
fun test_glider_pattern() {
    use sui::test_scenario as ts;

    let mut test = ts::begin(SIGNER);

    let ctx = &mut tx_context::dummy();
    game_of_life::new(5, 5, ctx);
    test.next_tx(SIGNER);
    let mut game = test.take_shared<game_of_life::GameOfLife>();

    game_of_life::set_cell_for_testing(&mut game, 0, 1, true);
    game_of_life::set_cell_for_testing(&mut game, 1, 2, true);
    game_of_life::set_cell_for_testing(&mut game, 2, 0, true);
    game_of_life::set_cell_for_testing(&mut game, 2, 1, true);
    game_of_life::set_cell_for_testing(&mut game, 2, 2, true);

    game_of_life::next_generation(&mut game);
    game_of_life::next_generation(&mut game);
    game_of_life::next_generation(&mut game);
    game_of_life::next_generation(&mut game);

    assert!(game_of_life::get_cell(&game, 1, 2));
    assert!(game_of_life::get_cell(&game, 2, 3));
    assert!(game_of_life::get_cell(&game, 3, 1));
    assert!(game_of_life::get_cell(&game, 3, 2));
    assert!(game_of_life::get_cell(&game, 3, 3));

    ts::return_shared(game);
    test.end();
}
