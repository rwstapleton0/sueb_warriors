module sueb_warriors::sueb_warriors {
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self,TxContext};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::clock::{Self, Clock};
    use sui::package;
    use sui::display;
    use std::vector;
    use std::string::{utf8, String};
    use std::option::{Self, Option};

    const PICK_WARRIOR: u8 = 0;
    const DECLARE_MOVE: u8 = 1;
    const RESOLVE_GAME: u8 = 2;

    const EGameIsFull: u64 = 5;
    const EGameIsInProgress: u64 = 6;
    const EGameIsNotWaitingForMove: u64 = 7;
    const EGameIsNotWaitingToResolve: u64 = 8;
    const EWrongAddress: u64 = 9;

    struct SuebWarrior has key, store {
        id: UID,
        name: String,
        energy: u64,
        power: u64,
        rush: u64,
        image_url: String,
    }

    struct SuebGame has key, store {
        id: UID,
        sueb1: Option<ID>,
        sueb1_move: vector<u8>,
        sueb2: Option<ID>,
        sueb2_move: vector<u8>,
        game_state: u8,
        started_at: u64,
    }

    struct SUEB_WARRIORS has drop {}

    fun init(otw: SUEB_WARRIORS, ctx: &mut TxContext) {
        // display
        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
        ];
        let values = vector[
            utf8(b"Sueb {name}"),
            utf8(b"https://amethyst-hidden-rodent-621.mypinata.cloud/ipfs/{image_url}"),
        ];
        let publisher = package::claim(otw, ctx);
        let display = display::new_with_fields<SuebWarrior>(
            &publisher, keys, values, ctx
        );
        display::update_version(&mut display);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));

        // engine
        let suebGame = SuebGame {
            id: object::new(ctx),
            sueb1: option::none(),
            sueb1_move: vector::empty(),
            sueb2: option::none(),
            sueb2_move: vector::empty(),
            game_state: 0,
            started_at: 0
        };
        transfer::public_transfer(suebGame, tx_context::sender(ctx));
    }

    // Mint and display a Sueb Warrior.
    public entry fun mint_sueb_to_kiosk(
        name: String,
        energy: u64, 
        power: u64, 
        rush: u64,
        image_url: String, 
        kiosk: &mut Kiosk, 
        cap: &KioskOwnerCap, 
        ctx: &mut TxContext
    ) {
        let sueb = SuebWarrior {
            id: object::new(ctx), 
            name, energy, power, rush, image_url,
        };

        kiosk::place(kiosk, cap, sueb);
    }

    public fun burn(sueb: SuebWarrior, _: &mut TxContext) {
        let SuebWarrior { id, name: _, energy:_, power: _, rush: _, image_url: _ } = sueb;
        object::delete(id)
    }


        // should put my sueb address into open player slot.
        
        // should check if the other slot is take if so start the game timer
        // the game timer is the thing i want to test really.

        // if timer goes past a point without both player sumbiting moves 
        // the kick function should be open kicking the player(s) that hasnt 

    // Sueb warriors game engine.
    public entry fun join_game(sueb: &mut SuebWarrior, preferedPos: u64, game: &mut SuebGame, clock: &Clock, _: &mut TxContext) {
        assert!(game.game_state != PICK_WARRIOR, EGameIsInProgress);
        assert!(option::is_none(&game.sueb1) || option::is_none(&game.sueb2), EGameIsFull);

        if (preferedPos == 1 && option::is_none(&game.sueb1)) {
            game.sueb1 = option::some(object::uid_to_inner(&sueb.id));
        } else if (preferedPos == 1 && option::is_some(&game.sueb1)) {
            game.sueb2 = option::some(object::uid_to_inner(&sueb.id));
        };

        if (preferedPos == 2 && option::is_none(&game.sueb2)) {
            game.sueb2 = option::some(object::uid_to_inner(&sueb.id));
        } else if (preferedPos == 2 && option::is_some(&game.sueb2)) {
            game.sueb1 = option::some(object::uid_to_inner(&sueb.id));
        };

        if (option::is_none(&game.sueb1) && option::is_none(&game.sueb2)) {
            game.started_at = clock::timestamp_ms(clock);
            game.game_state = 1;
        };

    }

    public entry fun declare_moves(moves: vector<u8>, sueb: &mut SuebWarrior, game: &mut SuebGame, _: &mut TxContext) {
        assert!(game.game_state != DECLARE_MOVE, EGameIsNotWaitingForMove);
        assert!(check_address(object::uid_as_inner(&sueb.id), game), EWrongAddress);

        if (object::uid_as_inner(&sueb.id) == option::borrow(&game.sueb1)) {
            game.sueb1_move = moves;
        } else {
            game.sueb2_move = moves;
        };
    }

    public entry fun resolve_game(salt: vector<u8>, sueb: &mut SuebWarrior, game: &mut SuebGame, _: &mut TxContext) {
        assert!(game.game_state != RESOLVE_GAME, EGameIsNotWaitingToResolve);
        assert!(check_address(object::uid_as_inner(&sueb.id), game), EWrongAddress);

        
    }

    public entry fun leave_game(sueb: &mut SuebWarrior, game: &mut SuebGame, _: &mut TxContext) {}

    fun check_address(sueb_address: &ID, game: &SuebGame): bool {
        sueb_address == option::borrow(&game.sueb1) && sueb_address == option::borrow(&game.sueb2) 
    }
}

// just make 1 shared game and recycle it to begin with.