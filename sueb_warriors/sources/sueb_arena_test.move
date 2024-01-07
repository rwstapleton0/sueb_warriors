
#[test_only]
#[allow(unused_assignment, unused_use, unused_const, unused_variable, unused_mut_parameter, unused_function)]

module sueb_warriors::sueb_arena_test {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID};
    use sui::transfer;
    use sui::clock::{Self, Clock};
    
    use sueb_warriors::sueb_warriors::{Self, SuebWarrior};
    use sueb_warriors::sueb_arena::{Self, WaitingRoom, SuebArena};
    use sueb_warriors::sueb_warriors_test::{Self};
    
    use std::vector;
    use std::string::{utf8, String};
    
    use sui::test_scenario::{Self as ts, Scenario};
    use sui::kiosk_test_utils as kiosk_ts;
    const ADMIN: address = @0xAD;
    
    const ENERGY: u8 = 0;
    const POWER: u8 = 1;
    const RUSH: u8 = 2;

    #[test]
    public fun test_module_init() {
        let ts = ts::begin(@0x0);
        let (alice, bob, carl) = kiosk_ts::folks();
        let (alice_sueb, bob_sueb, alice_sueb_id, bob_sueb_id,  clock) = test_init(&mut ts);
        
        let waiting: WaitingRoom;
        let arena: SuebArena;

        {
            ts::next_tx(&mut ts, ADMIN);
            waiting = ts::take_shared<WaitingRoom>(&ts);
        };
        {
            ts::next_tx(&mut ts, alice);
            let ctx = ts::ctx(&mut ts);
            sueb_arena::join_game(&mut alice_sueb, &mut waiting, &clock, ctx);
            assert!(sueb_arena::is_suebs_waiting(&waiting), 0);
        };
        {
            ts::next_tx(&mut ts, bob);
            let ctx = ts::ctx(&mut ts);
            sueb_arena::join_game(&mut bob_sueb, &mut waiting, &clock, ctx);
            assert!(!sueb_arena::is_suebs_waiting(&waiting), 0);
            assert!(!sueb_warriors::not_in_game(&bob_sueb), 0)
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            arena = ts::take_shared<SuebArena>(&ts);
        };
        {
            ts::next_tx(&mut ts, bob);
            let hash = sueb_arena::hash_moves(b"Bob Be Bussin", ENERGY);
            sueb_arena::declare_moves(hash, &mut bob_sueb, &mut arena);

            
            assert!(is_move_declared(&arena, &bob_sueb_id), 0);
        };
        {
            ts::next_tx(&mut ts, alice);
            let hash = sueb_arena::hash_moves(b"Alice All Agro", POWER);
            sueb_arena::declare_moves(hash, &mut alice_sueb, &mut arena);

            
            assert!(sueb_arena::is_move_declared(&arena, &alice_sueb_id), 0)
        };
        {
            ts::next_tx(&mut ts, alice);
            sueb_arena::reveal_moves(b"Alice All Agro", POWER, &mut alice_sueb, &mut arena);

        };

        cleanup(&mut ts, alice_sueb, bob_sueb, arena, waiting, clock, carl);
        ts::end(ts);
    }
    
    #[test_only]
    public fun test_init(ts: &mut Scenario): (SuebWarrior, SuebWarrior, ID, ID, Clock) {
        ts::next_tx(ts, ADMIN);
        let ctx = ts::ctx(ts);

        sueb_arena::test_init(ctx);
        
        let alice_sueb: SuebWarrior = sueb_warriors::create_test(3, 7, 8, ctx);
        let bob_sueb: SuebWarrior = sueb_warriors::create_test(6, 3, 9, ctx);

        let bob_sueb_id = object::id(&bob_sueb);
        let alice_sueb_id = object::id(&alice_sueb);
        
        let clock: Clock = clock::create_for_testing(ctx);
        
        return (alice_sueb, bob_sueb, alice_sueb_id, bob_sueb_id,  clock)
    }

    #[test_only]
    public fun cleanup(
        _: &mut Scenario,
        alice_sueb: SuebWarrior, 
        bob_sueb: SuebWarrior, 
        arena: SuebArena,
        waiting: WaitingRoom,
        clock: Clock,
        carl: address,
    ) {
        transfer::public_transfer(alice_sueb, carl);
        transfer::public_transfer(bob_sueb, carl);

        ts::return_shared(arena);
        ts::return_shared(waiting);
        clock::destroy_for_testing(clock);
    }
    

    // // only for testing? so ok to pass in the id
    // public fun is_move_declared(self: &SuebArena, sueb_id: &ID): bool {
    //     if (sueb_id == option::borrow(&self.sueb1)) {
    //         !vector::is_empty(&self.sueb1_hash)
    //     } else {
    //         !vector::is_empty(&self.sueb1_hash)
    //     }
    // }

    // only for testing? so ok to pass in the id
    public fun is_move_declared(self: &SuebArena, sueb_id: &ID): bool {
        if (sueb_id == option::borrow(&self.sueb1)) {
            !vector::is_empty(&self.sueb1_hash)
        } else {
            !vector::is_empty(&self.sueb1_hash)
        }
    }
}