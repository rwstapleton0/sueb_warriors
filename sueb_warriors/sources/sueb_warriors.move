module sueb_warriors::sueb_warriors {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self,TxContext};
    use std::string::{utf8, String};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::clock::{Self, Clock};
    use std::option::{Self, Option};
    use sui::package;
    use sui::display;

    const PICK_WARRIOR: u8 = 0;
    const DECLARE_MOVE: u8 = 1;
    // const 

    const EGameIsFull: u64 = 5;
    const EGameIsInProgress: u64 = 6;

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
        sueb1: Option<address>,
        sueb2: Option<address>,
        game_state: u8,
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
            sueb2: option::none(),
            game_state: 0,
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

    // Sueb warriors game engine.
    public entry fun join_game(sueb: &mut SuebWarrior, game: &mut SuebGame, _: &mut TxContext) {
        assert!(game.game_state != PICK_WARRIOR, EGameIsInProgress);
        assert!(option::is_none(&game.sueb1) || option::is_none(&game.sueb2), EGameIsFull);

        // should put my sueb address into open player slot.
        
        // should check if the other slot is take if so start the game timer
        // the game timer is the thing i want to test really.

        // if timer goes past a point without both player sumbiting moves 
        // the kick function should be open kicking the player(s) that hasnt 
    }

    public entry fun leave_game(sueb: &mut SuebWarrior, game: &mut SuebGame, _: &mut TxContext) {}

}

// just make 1 shared game and recycle it to begin with.