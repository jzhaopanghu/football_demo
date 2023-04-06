module sender::football{

    use std::signer;
    use std::coin;
    use std::string;
    use std::debug;
    use std::account;
    use sender::jzhao_money;
    use sender::jzhao_money::JzhaoMoney;
    


    const STAR_ALREADY_EXISTS:u64 = 100;
    const STAR_NOT_EXISTS:u64 = 101;


     // info
    struct FootBallStar has key,drop{
        name: string::String,
        country: string::String,
        position: u8,
        value: u64,

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
    

    public fun get_info(star_address:address):(string::String,u64,string::String,u8) acquires FootBallStar{
        let star = borrow_global<FootBallStar>(star_address);
        (star.name,star.value,star.country,star.position)
    }

  
    public entry fun del_info(star_address:address) acquires FootBallStar{
        move_from<FootBallStar>(star_address);
    }

    public fun set_value(star_address:address,value:u64) acquires FootBallStar{
        assert!(exists<FootBallStar>(star_address),STAR_NOT_EXISTS);
        let star = borrow_global_mut<FootBallStar>(star_address);
        star.value = value;
    }

    public entry fun transfer(to:&signer,from_addr:address) acquires FootBallStar{
        assert!(exists<FootBallStar>(from_addr),STAR_NOT_EXISTS);
        let ( _name ,value, _country, _position) = Self::get_info(from_addr);
        coin::transfer<JzhaoMoney>(to,from_addr,value);
        let star = move_from<FootBallStar>(from_addr);
        assert!(!exists<FootBallStar>(signer::address_of(to)),STAR_ALREADY_EXISTS);
        move_to<FootBallStar>(to,star);
    }

    public entry fun create_star(user: &signer,name: string::String,country: string::String,
            position: u8, val:u64) acquires FootBallStar{
        let star = Self::new_star(name,country,position);
        move_to<FootBallStar>(user,star);
        let star_address = signer::address_of(user);
        set_value(star_address,val);
    }

     public entry fun create_star_test(user: &signer) acquires FootBallStar{
        let name = string::utf8(b"Cristiano Ronaldo");
        let country = string::utf8(b"The Portuguese Republic");
        let position:u8 = 7;
        let star = Self::new_star(name,country,position);
        move_to<FootBallStar>(user,star);
        let star_address = signer::address_of(user);
        set_value(star_address,300);
    }
    
    public fun account_money_initialize(user_a: &signer,user_b: &signer,amount:u64){
        let a_addr = signer::address_of(user_a);
        let b_addr = signer::address_of(user_b);
        //jzhao_money::init_module(user_a);
        jzhao_money::register(user_a);
        jzhao_money::register(user_b);
        jzhao_money::mint(user_a,a_addr,amount);
        jzhao_money::mint(user_a,b_addr,amount);
    }

    

    #[test(user_a = @0x1, user_b = @0x2)]
    public fun transfer_star(user_a: signer,user_b: signer) acquires FootBallStar{
        let a_addr = signer::address_of(&user_a);
        account::create_account_for_test(a_addr);
        let b_addr = signer::address_of(&user_b);
        account::create_account_for_test(b_addr);

        let name = string::utf8(b"Cristiano Ronaldo");
        let country = string::utf8(b"The Portuguese Republic");

        create_star(&user_a,name,country,7,300);
        let a_football_star = borrow_global<FootBallStar>(a_addr);
        debug::print(&a_football_star.value);

        account_money_initialize(&user_a,&user_b,500);
        debug::print(&coin::balance<JzhaoMoney>(a_addr));
        debug::print(&coin::balance<JzhaoMoney>(b_addr));
        
        transfer(&user_b,a_addr);
        let b_football_star = borrow_global<FootBallStar>(b_addr);
        debug::print(&b_football_star.value);
        debug::print(&coin::balance<JzhaoMoney>(a_addr));
        debug::print(&coin::balance<JzhaoMoney>(b_addr));
    }


   

}