module sender::jzhao_money{

    use aptos_framework::managed_coin;

    struct JzhaoMoney {}

    fun init_module(user: &signer) {
        managed_coin::initialize<JzhaoMoney>(
            user,
            b"Jzhao money",
            b"JMD",
            2,
            true,
        );
    }

    public fun register(account: &signer) {
        managed_coin::register<JzhaoMoney>(account);
    }


    public fun mint(account: &signer,
        dst_addr: address,
        amount: u64
        ) {
        managed_coin::mint<JzhaoMoney>(account,dst_addr,amount);
    }

  

}