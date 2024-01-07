// should put my sueb address into open player slot.
// this might need to

// should check if the other slot is take if so start the game timer
// the game timer is the thing i want to test really.

// if timer goes past a point without both player sumbiting moves 
// the kick function should be open kicking the player(s) that hasnt 

// might swap join game so if no players with good elo build new game and wait
// although that would create unnesseary object, if players leave early? so no?

// will look into a different way to handle this
/*
    sueb1: Option<ID>,
    sueb1_hash: vector<u8>,
    sueb1_move: Option<u8>,
*/

#[allow(unused_assignment, unused_use, unused_const, unused_variable, unused_mut_parameter, unused_function)]

module sueb_warriors::sueb_arena {
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use sui::clock::{Self, Clock};
    
    use std::vector;
    use std::option::{Self, Option};
    use std::hash;
    
    use sueb_warriors::sueb_warriors::{Self, SuebWarrior};
    
    const ENERGY: u8 = 0;
    const POWER: u8 = 1;
    const RUSH: u8 = 2;

    const PICK_WARRIOR: u8 = 5;
    const DECLARE_MOVE: u8 = 6;
    const REVEAL_MOVE: u8 = 7;
    const RESOLVE_GAME: u8 = 8;


    const EGameIsFull: u64 = 11;
    const EGameIsInProgress: u64 = 12;
    const EGameIsNotWaitingForMove: u64 = 13;
    const EGameIsNotWaitingToResolve: u64 = 14;
    const EWrongAddress: u64 = 15;
    const EUnresolvedGame: u64 = 16;
    const EMoveOrSaltWrong: u64 = 17;

    // should use some system to check elo, elo = some equation (sueb lvl + items owns)
    struct WaitingRoom has key, store {
        id: UID,
        waiting: vector<ID>
    }

    public fun is_suebs_waiting(self: &WaitingRoom): bool {
        !vector::is_empty(&self.waiting)
    }

    struct SuebArena has key, store {
        id: UID,
        sueb1: Option<ID>,
        sueb1_hash: vector<u8>,
        sueb1_move: Option<u8>,
        sueb2: Option<ID>,
        sueb2_hash: vector<u8>,
        sueb2_move: Option<u8>,
        game_state: u8,
        started_at: u64,
    }

    public fun set_moves(self: &mut SuebArena, sueb: &SuebWarrior, checked: u8) {
        if (sueb_warriors::get_sueb_id(sueb) == option::borrow(&self.sueb1)) {
            option::fill(&mut self.sueb1_move, checked);
        } else {
            option::fill(&mut self.sueb2_move, checked);
        }
    }

    public fun update_game_state(self: &mut SuebArena, state: u8) {
        self.game_state = state;
    }

    public fun hashes_match(self: &SuebArena, sueb: &SuebWarrior, test: vector<u8>): bool {
        if (sueb_warriors::get_sueb_id(sueb) == option::borrow(&self.sueb1)) {
            test == self.sueb1_hash
        } else {
            test == self.sueb1_hash
        }
    }

    public fun all_moves_submitted(self: &SuebArena): bool {
        vector::is_empty(&self.sueb1_hash) && vector::is_empty(&self.sueb1_hash)
    }

    public fun all_moves_revealed(self: &SuebArena): bool {
        option::is_some(&self.sueb1_move) && option::is_some(&self.sueb2_move)
    }

    public fun is_hash_empty(self: &SuebArena): bool {
        vector::is_empty(&self.sueb1_hash)
    }


    fun init (ctx: &mut TxContext) {
        transfer::share_object(WaitingRoom {
            id: object::new(ctx),
            waiting: vector::empty(),
        });
    }

    fun create_game(
        p1: ID, p2: ID,
        clock: &Clock,
        ctx: &mut TxContext
    ): ID {
        let id = object::new(ctx);
        let game_id = object::uid_to_inner(&id);
        transfer::share_object(SuebArena {
            id: id,
            sueb1: option::some(p1),
            sueb1_hash: vector::empty(),
            sueb1_move: option::none(),
            sueb2: option::some(p2),
            sueb2_hash: vector::empty(),
            sueb2_move: option::none(),
            game_state: DECLARE_MOVE,
            started_at: clock::timestamp_ms(clock)
        });
        game_id
    }

    public fun join_game(
        sueb: &mut SuebWarrior,
        waiting: &mut WaitingRoom,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        // Should not join a new game with unresovled games. stops not taking health hit.
        assert!(sueb_warriors::not_in_game(sueb), EUnresolvedGame);
        
        // check for waiting player. if non push my id to the vector.
        let suebId = object::id(sueb);
        if(vector::is_empty(&waiting.waiting)) {
            vector::push_back(&mut waiting.waiting, suebId);
            return
        };
        
        // pull waiting player into game.
        let p1 = vector::pop_back(&mut waiting.waiting);
        let game_id = create_game(p1, suebId, clock, ctx);
        sueb_warriors::add_current_game(sueb, game_id);
    } 
    
    public fun declare_moves(
        moves: vector<u8>,
        sueb: &mut SuebWarrior,
        game: &mut SuebArena,
    ) {
        assert!(game.game_state == DECLARE_MOVE, EGameIsNotWaitingForMove);
        assert!(check_address(sueb, game), EWrongAddress);

        sueb_warriors::add_current_game(sueb, object::id(game));

        if (sueb_warriors::get_sueb_id(sueb) == option::borrow(&game.sueb1)) {
            game.sueb1_hash = moves;
        } else {
            game.sueb2_hash = moves;
        };

        // this shouldnt happen when the secound player inputs his.
        if (all_moves_submitted(game)) {
            update_game_state(game, REVEAL_MOVE);
        }
    }

    public fun reveal_moves(
        cry: vector<u8>,
        sueb_move: u8,
        sueb: &mut SuebWarrior,
        game: &mut SuebArena,
        // _: &mut TxContext
    ) {
        assert!(game.game_state == REVEAL_MOVE, EGameIsNotWaitingToResolve);
        assert!(check_address(sueb, game), EWrongAddress);

        let test = hash_moves(cry, sueb_move);
        assert!(hashes_match(game, sueb, test), EMoveOrSaltWrong);

        set_moves(game, sueb, sueb_move);

        if (all_moves_revealed(game)) {
            update_game_state(game, RESOLVE_GAME);
        }
    }

    public fun resolve_game(
        sueb: &mut SuebWarrior,
        game: &mut SuebArena,
        _: &mut TxContext
    ) {
        assert!(game.game_state != RESOLVE_GAME, EGameIsNotWaitingToResolve);
        assert!(check_address(sueb, game), EWrongAddress);


    }

    public fun leave_game(
        sueb: &mut SuebWarrior,
        game: &mut SuebArena,
        _: &mut TxContext
    ) {}

    public fun leave_waiting(
        sueb: &mut SuebWarrior,
        waiting: &mut WaitingRoom,
        _: &mut TxContext
    ) {
        let (exists, i) = vector::index_of(&waiting.waiting, &object::id(sueb));
        assert!(exists, EWrongAddress);
        vector::remove(&mut waiting.waiting, i);
    }

    fun check_address(
        sueb: &mut SuebWarrior,
        game: &SuebArena
    ): bool {
        sueb_warriors::get_sueb_id(sueb) == option::borrow(&game.sueb1) || sueb_warriors::get_sueb_id(sueb) == option::borrow(&game.sueb2) 
    }

    public fun hash_moves(cry: vector<u8>, sueb_move: u8): vector<u8> {
        vector::push_back(&mut cry, sueb_move);
        hash::sha2_256(cry)
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}