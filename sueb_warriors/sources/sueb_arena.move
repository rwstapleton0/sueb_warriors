// should put my sueb address into open player slot.
// this might need to

// should check if the other slot is take if so start the game timer
// the game timer is the thing i want to test really.

// if timer goes past a point without both player sumbiting moves 
// the kick function should be open kicking the player(s) that hasnt 

// might swap join game so if no players with good elo build new game and wait
// although that would create unnesseary object, if players leave early? so no?

// will look into a different way to handle this, need to make this dry.
/*
    sueb1: Option<ID>,
    sueb1_hash: vector<u8>,
    sueb1_move: Option<u8>,
*/

// struct SuebStore has store { to copy this?? i dont think so i only really need to borrow it.

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
    const READY_TO_REVEAL: u8 = 7;
    const REVEAL_MOVE: u8 = 8;
    const RESOLVE_GAME: u8 = 9;
    const GAME_FINISHED: u8 = 10;

    const EGameIsFull: u64 = 11;
    const EGameIsInProgress: u64 = 12;
    const EGameIsNotWaitingForMove: u64 = 13;
    const EGameIsNotReadyToReveal: u64 = 14;
    const EGameIsNotWaitingToResolve: u64 = 15;
    const EWrongAddress: u64 = 16;
    const EUnresolvedGame: u64 = 17;
    const EMoveOrSaltWrong: u64 = 18;
    const ECantSetStatIfReveal: u64 = 19;

    // should use some system to check elo, elo = some equation (sueb lvl + items owns)
    struct WaitingRoom has key, store {
        id: UID,
        waiting: vector<ID>
    }

    public fun is_suebs_waiting(self: &WaitingRoom): bool {
        !vector::is_empty(&self.waiting)
    }

    struct SuebStore has store { // using copy here??? I can refernce to do check but dont want it brekaing stuff...
        sueb_id: Option<ID>,
        hash: vector<u8>,
        smove: Option<u8>,
        energy: u64,
        power: u64,
        rush: u64,
    }

    struct SuebArena has key, store {
        id: UID,
        sueb1: SuebStore,
        sueb2: SuebStore,
        game_state: u8,
        started_at: u64,
        winner: Option<ID>,
        diff: u64
    }

    public fun set_game_state(self: &mut SuebArena, state: u8) {
        self.game_state = state;
    }

    // maybe mutable and non?
    public fun borrow_mut_sueb_store(self: &mut SuebArena, sueb: &SuebWarrior): &mut SuebStore {
        if (option::borrow(&self.sueb1.sueb_id) == &object::id(sueb)) {
            &mut self.sueb1
        } else {
            &mut self.sueb2
        }
    }
    // maybe mutable and non?
    public fun borrow_sueb_store(self: &SuebArena, sueb: &SuebWarrior): &SuebStore {
        if (option::borrow(&self.sueb1.sueb_id) == &object::id(sueb)) {
            &self.sueb1
        } else {
            &self.sueb2
        }
    }

    public fun borrow_mut_stores(self: &mut SuebArena): (&mut SuebStore, &mut SuebStore) {
        (&mut self.sueb1, &mut self.sueb2)
    }

    fun set_winner(self: &mut SuebArena, winner: ID, diff: u64) {
        option::fill(&mut self.winner, winner);
        self.diff = diff;
    }

    fun set_moves(self: &mut SuebArena, sueb: &SuebWarrior, checked: u8) {
        let store = borrow_mut_sueb_store(self, sueb);
        option::fill(&mut store.smove, checked);
    }

    fun set_stats(self: &mut SuebArena, sueb: &SuebWarrior) {
        assert!(!check_game_state(self, REVEAL_MOVE) ||
            !check_game_state(self, RESOLVE_GAME),
            ECantSetStatIfReveal);
        let store = borrow_mut_sueb_store(self, sueb);
        let (energy, power, rush) = sueb_warriors::get_stats(sueb);
        store.energy = energy;
        store.power = power;
        store.rush = rush;
    }

    public fun check_game_state(self: &SuebArena, state: u8): bool {
        self.game_state == state
    }

    fun check_addresses(self: &SuebArena, sueb: &SuebWarrior): bool {
        option::borrow(&self.sueb1.sueb_id) == &object::id(sueb) || 
        option::borrow(&self.sueb2.sueb_id) == &object::id(sueb)
    }

    fun hashes_match(self: &SuebArena, sueb: &SuebWarrior, test: vector<u8>): bool {
        test == borrow_sueb_store(self, sueb).hash
    }

    public fun hashes_submitted(self: &SuebArena): bool {
        !vector::is_empty(&self.sueb1.hash) && 
        !vector::is_empty(&self.sueb2.hash)
    }

    fun moves_revealed(self: &SuebArena): bool {
        option::is_some(&self.sueb1.smove) && 
        option::is_some(&self.sueb2.smove)
    }

    fun init (ctx: &mut TxContext) {
        transfer::share_object(WaitingRoom {
            id: object::new(ctx),
            waiting: vector::empty(),
        });
    }

    fun create_store(sueb_id: ID): SuebStore {
        SuebStore {
            sueb_id: option::some(sueb_id),
            hash: vector::empty(),
            smove: option::none(),
            energy: 0,
            power: 0,
            rush: 0
        }
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
            sueb1: create_store(p1),
            sueb2: create_store(p2),
            game_state: DECLARE_MOVE,
            started_at: clock::timestamp_ms(clock),
            winner: option::none(),
            diff: 0
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
        hash: vector<u8>,
        sueb: &mut SuebWarrior,
        game: &mut SuebArena,
    ) {
        assert!(game.game_state == DECLARE_MOVE, EGameIsNotWaitingForMove);
        assert!(check_addresses(game, sueb), EWrongAddress);

        sueb_warriors::add_current_game(sueb, object::id(game));

        let store = borrow_mut_sueb_store(game, sueb);
        vector::append(&mut store.hash, hash);

        if (hashes_submitted(game)) {
            set_game_state(game, READY_TO_REVEAL); // might have to change this to waiting to reveal?
        }// then update to reveal when either person hit reveal_moves?
    }

    public fun reveal_moves(
        cry: vector<u8>,
        sueb_move: u8,
        sueb: &mut SuebWarrior,
        game: &mut SuebArena,
        // _: &mut TxContext
    ) {
        assert!(
            check_game_state(game, READY_TO_REVEAL) || 
            check_game_state(game, REVEAL_MOVE),
            EGameIsNotReadyToReveal);
        assert!(check_addresses(game, sueb), EWrongAddress);

        set_stats(game, sueb);
        
        set_game_state(game, REVEAL_MOVE); // this should stop players from updating stats.

        let test = hash_moves(cry, sueb_move);
        assert!(hashes_match(game, sueb, test), EMoveOrSaltWrong); // should test how this interacts with state changes.

        set_moves(game, sueb, sueb_move);

        if (moves_revealed(game)) {
            set_game_state(game, RESOLVE_GAME);
        }
    }

    public fun resolve_game(
        sueb: &mut SuebWarrior,
        game: &mut SuebArena,
        _: &mut TxContext
    ) {
        assert!(check_game_state(game, RESOLVE_GAME), EGameIsNotWaitingToResolve);
        assert!(check_addresses(game, sueb), EWrongAddress);

        let (store1, store2) = borrow_mut_stores(game);

        let (battle_a, val_a) = compare_stores(store1, store2);
        let (battle_b, val_b) = compare_stores(store2, store1);

        // need to handle equal vals too?
        // these really throw a spanner in the works??
        if (battle_a == battle_b) {
            // if 1 player wins both, 10% off suebs health? this will be worst as you level.
            set_winner(game, battle_a, 5); // willchange 5 soon
        } else {
            let (winner, diff) = compare_stats(battle_a, battle_b, val_a, val_b);
            set_winner(game, winner, diff);
        };

        set_game_state(game, GAME_FINISHED);

        leave_game(game, sueb);
    }

    fun compare_stores(
        store_a: &mut SuebStore,
        store_b: &mut SuebStore
    ): (ID, u64) {
        let smove: u8 = option::extract(&mut store_a.smove); // way to do this without mut?
        // Maybe a better way to do this, will take to scratch
        // need to extract to copy the ID, then fill as we still need to know whos in the game?
        let sueb_a_id = option::extract(&mut store_a.sueb_id);
        let sueb_b_id = option::extract(&mut store_b.sueb_id);

        let (oid, ostat);
        if (smove == ENERGY) {
            (oid, ostat) = compare_stats(
                sueb_a_id,
                sueb_b_id,
                store_a.energy,
                store_b.rush)
        } else if (smove == POWER) {
            (oid, ostat) = compare_stats(
                sueb_a_id,
                sueb_b_id,
                store_a.power,
                store_b.energy)
        } else { // RUSH
            (oid, ostat) = compare_stats(
                sueb_a_id,
                sueb_b_id,
                store_a.rush,
                store_b.power)
        };
        option::fill(&mut store_a.sueb_id, sueb_a_id);
        option::fill(&mut store_b.sueb_id, sueb_b_id);
        (oid, ostat)
    }

    // can i get a hair drier? unsure if this can be drier?
    fun compare_stats(sueb1_id: ID, sueb2_id: ID, sueb1_val: u64, sueb2_val: u64): (ID, u64) {
        if (sueb1_val == sueb2_val) {
            (sueb1_id, 0)
        } else if (sueb1_val > sueb2_val) {
            (sueb1_id, sueb1_val - sueb2_val)
        } else {
            (sueb2_id, sueb2_val - sueb1_val)
        }
    }

    public fun leave_game(
        game: &mut SuebArena,
        sueb: &mut SuebWarrior,
        // _: &mut TxContext
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


    public fun hash_moves(cry: vector<u8>, sueb_move: u8): vector<u8> {
        vector::push_back(&mut cry, sueb_move);
        hash::sha2_256(cry)
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}