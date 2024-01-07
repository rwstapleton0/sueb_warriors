
#[test_only]
#[allow(unused_assignment, unused_use, unused_const, unused_variable, unused_mut_parameter)]
module sueb_warriors::sueb_warriors_test {
    use sui::tx_context::{Self, TxContext};
    use sueb_warriors::sueb_warriors::{Self, SuebWarrior};

    use sui::test_scenario as ts;
    use sui::kiosk_test_utils as kiosk_ts;
    const ADMIN: address = @0xAD;

    // #[test_only]
    // public fun init_sueb_warriors(ctx: &mut TxContext) {
    //     let (alice, bob, _) = kiosk_ts::folks();
    //     let ts = ts::begin(@0x0);
    //     {
    //         ts::next_tx(&mut ts, ADMIN);
    //         let (alice_kiosk, alice_kiosk_cap) = kiosk_ts::get_kiosk(ctx);
    //         let (bob_kiosk, bob_kiosk_cap) = kiosk_ts::get_kiosk(ctx);
    //     };
    //     ts::end(ts);
    // }
}