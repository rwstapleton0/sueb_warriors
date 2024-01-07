#[allow(unused_assignment, unused_use, unused_const, unused_variable, unused_mut_parameter, unused_function)]
module sueb_warriors::sueb_warriors {
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self,TxContext};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::package;
    use sui::display;
    use std::string::{utf8, String};
    use std::option::{Self, Option};

    struct SuebWarrior has key, store {
        id: UID,
        name: String,
        image_url: String,
        energy: u64,
        power: u64,
        rush: u64,
        current_game: Option<ID>,
    }

    struct SUEB_WARRIORS has drop {}

    public fun get_sueb_id(self: &SuebWarrior): &ID {
        object::uid_as_inner(&self.id)
    }

    public fun add_current_game(self: &mut SuebWarrior, game_id: ID) {
        if (option::is_none(&self.current_game)) {
            option::fill(&mut self.current_game, game_id);
        }
    }

    public fun not_in_game(self: &SuebWarrior): bool {
        option::is_none(&self.current_game)
    }

    fun init(otw: SUEB_WARRIORS, ctx: &mut TxContext) {
        // not sure whether to include stats here?
        // they can change regulaly so maybe better handled with events for fe?
        // events might be better for item updates too?
        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
        ];
        let values = vector[
            utf8(b"Sueb {name}"),
            utf8(b"{image_url}"),
        ];
        let publisher = package::claim(otw, ctx);
        let display = display::new_with_fields<SuebWarrior>(
            &publisher, keys, values, ctx
        );
        display::update_version(&mut display);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));

    }

    // Mint and display a Sueb Warrior.
    public entry fun mint_to_kiosk(
        kiosk: &mut Kiosk, 
        cap: &KioskOwnerCap, 
        name: String,
        energy: u64, 
        power: u64, 
        rush: u64,
        image_url: String, 
        ctx: &mut TxContext
    ) {
        let sueb = SuebWarrior {
            id: object::new(ctx), 
            name,
            energy,
            power,
            rush,
            image_url,
            current_game: option::none()
        };

        kiosk::place(kiosk, cap, sueb);
    }

    // I think this needs kiosk?
    public fun burn(sueb: SuebWarrior, _: &mut TxContext) {
        let SuebWarrior { id, name: _, energy:_, power: _, rush: _, image_url: _, current_game: _ } = sueb;
        object::delete(id)
    }

    #[test_only]
    public fun create_test(energy: u64, power: u64, rush: u64, ctx: &mut TxContext): SuebWarrior {
        SuebWarrior {
            id: object::new(ctx), 
            name: utf8(b"Sueb"),
            energy,
            power,
            rush,
            image_url: utf8(b""),
            current_game: option::none()
        }
    }
}

// just make 1 shared game and recycle it to begin with.