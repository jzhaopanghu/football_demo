module sender::football{

    use std::signer;
    use std::coin;
    use std::string;
    use std::debug;
    use std::account;





    const STAR_ALREADY_EXISTS:u64 = 100;
    const STAR_NOT_EXISTS:u64 = 101;


     // info
    struct FootBallStar has key,drop{
        name: string::String,
        country: string::String,
        position: u8,
        value: u64,

    }

    struct JzhaoMoney {}


    struct JzhaoMoneyCapabilities has key {
        burn_cap: coin::BurnCapability<JzhaoMoney>,
        freeze_cap: coin::FreezeCapability<JzhaoMoney>,
        mint_cap: coin::MintCapability<JzhaoMoney>,
    }

    public fun new_star(name: string::String,country: string::String,
            position: u8):FootBallStar{
        FootBallStar{
            name, country, position,  value:0
        }
    }


    public fun mint(to:& signer,star:FootBallStar){
        assert!(!exists<FootBallStar>(signer::address_of(to)),STAR_ALREADY_EXISTS);
        move_to<FootBallStar>(to,star);
    }
    

    public fun get(star_address:address):(string::String,u64) acquires FootBallStar{
        let star = borrow_global<FootBallStar>(star_address);
        (star.name,star.value)
    }

    public fun set_value(star_address:address,value:u64) acquires FootBallStar{
        assert!(exists<FootBallStar>(star_address),STAR_NOT_EXISTS);
        let star = borrow_global_mut<FootBallStar>(star_address);
        star.value = value;
    }

    public fun transfer(from:&signer,to:&signer) acquires FootBallStar{
        assert!(exists<FootBallStar>(signer::address_of(from)),STAR_NOT_EXISTS);
        let from_addr = signer::address_of(from);
        let ( _ ,value) = Self::get(from_addr);
        coin::transfer<JzhaoMoney>(to,from_addr,value);
        let star = move_from<FootBallStar>(from_addr);
        assert!(!exists<FootBallStar>(signer::address_of(to)),STAR_ALREADY_EXISTS);
        move_to<FootBallStar>(to,star);
    }

    public  fun create_star(user: &signer) acquires FootBallStar{
        let name = string::utf8(b"Cristiano Ronaldo");
        let country = string::utf8(b"The Portuguese Republic");
        let star = Self::new_star(name,country,7);
        move_to<FootBallStar>(user,star);
        let star_address = signer::address_of(user);
        set_value(star_address,300);
    }
    
    
    public fun account_initialize(user_a: &signer,user_b: &signer){
        let a_addr = signer::address_of(user_a);
        let b_addr = signer::address_of(user_b);
        let name = string::utf8(b"Jzhao money");
        let symbol = string::utf8(b"JMD");
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<JzhaoMoney>(
            user_a,
            name,
            symbol,
            2,
            true
        );
        coin::register<JzhaoMoney>(user_a);
        coin::register<JzhaoMoney>(user_b);

        let coins_a_minted = coin::mint<JzhaoMoney>(500, &mint_cap);
        coin::deposit(a_addr, coins_a_minted);
        let coins_b_minted = coin::mint<JzhaoMoney>(500, &mint_cap);
        coin::deposit(b_addr, coins_b_minted);


        //let coin = coin::withdraw<JzhaoMoney>(&user_a, 10);
        //coin::burn(coin, &burn_cap);
        
        move_to(user_a, JzhaoMoneyCapabilities {
            burn_cap,
            freeze_cap,
            mint_cap,
        });
    }

    

    #[test(user_a = @0x1, user_b = @0x2)]
    public fun transfer_star(user_a: signer,user_b: signer) acquires FootBallStar{
        let a_addr = signer::address_of(&user_a);
        account::create_account_for_test(a_addr);
        let b_addr = signer::address_of(&user_b);
        account::create_account_for_test(b_addr);
        create_star(&user_a);
        let a_football_star = borrow_global<FootBallStar>(a_addr);
        debug::print(&a_football_star.value);

        account_initialize(&user_a,&user_b);
        debug::print(&coin::balance<JzhaoMoney>(a_addr));
        debug::print(&coin::balance<JzhaoMoney>(b_addr));
        
        transfer(&user_a,&user_b);
        let b_football_star = borrow_global<FootBallStar>(b_addr);
        debug::print(&b_football_star.value);
        debug::print(&coin::balance<JzhaoMoney>(a_addr));
        debug::print(&coin::balance<JzhaoMoney>(b_addr));
    }


   

}