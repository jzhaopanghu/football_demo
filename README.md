
## 实例 - 球星卡-Football

> 基于Aptos 公链

## 思路

配合Aptos下framework的coin和account模块实现球星卡的交易。

### 需求

**创建、交易球星卡和其他玩法**

**FootBallStar 字段**

| 字段                    | 释义                         |
| ---------------------- | ---------------------------- |
| name                   | 球星名称                      | 
| country                | 球星国家                      | 
| position               | 球星位置                      | 
| value                  | 球星价格                      | 



### 代码

#### 结构体

**FootBallStar 球星卡信息**

```move
struct FootBallStar has key,drop{
    name: string::String,
    country: string::String,
    position: u8,
    value: u64,

}
```

**JzhaoMoney 新币**

```move
struct JzhaoMoney {}
```


**JzhaoMoneyCapabilities**

```move
struct JzhaoMoneyCapabilities has key {
    burn_cap: coin::BurnCapability<JzhaoMoney>,
    freeze_cap: coin::FreezeCapability<JzhaoMoney>,
    mint_cap: coin::MintCapability<JzhaoMoney>,
}
```


#### 普通函数

**创建**

```move
public fun new_star(name: string::String,country: string::String,
            position: u8):FootBallStar{
        FootBallStar{
            name, country, position,  value:0
        }
    }
} 
```

**给用户添加球星卡**

```move
public fun mint(to:& signer,star:FootBallStar){
    assert!(!exists<FootBallStar>(signer::address_of(to)),STAR_ALREADY_EXISTS);
    move_to<FootBallStar>(to,star);
}
```

**查询用户下球星卡信息**

```move
public fun get(star_address:address):(string::String,u64) acquires FootBallStar{
    let star = borrow_global<FootBallStar>(star_address);
    (star.name,star.value)
}
```

**设置球星卡的价格**

```move
public fun set_value(star_address:address,value:u64) acquires FootBallStar{
    assert!(exists<FootBallStar>(star_address),STAR_NOT_EXISTS);
    let star = borrow_global_mut<FootBallStar>(star_address);
    star.value = value;
}
```

**给用户创建具体的球星卡并设置价格(这里偷了个懒，信息直接写死了)**

```move
public  fun create_star(user: &signer) acquires FootBallStar{
    let name = string::utf8(b"Cristiano Ronaldo");
    let country = string::utf8(b"The Portuguese Republic");
    let star = Self::new_star(name,country,7);
    move_to<FootBallStar>(user,star);
    let star_address = signer::address_of(user);
    set_value(star_address,300);
}
```

**初始化币信息并发放给用户**

```move
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

    move_to(user_a, JzhaoMoneyCapabilities {
        burn_cap,
        freeze_cap,
        mint_cap,
    });
}
```

**用户之间的球星卡交易并转账**

```move
public fun transfer(from:&signer,to:&signer) acquires FootBallStar{
    assert!(exists<FootBallStar>(signer::address_of(from)),STAR_NOT_EXISTS);
    let from_addr = signer::address_of(from);
    let ( _ ,value) = Self::get(from_addr);
    coin::transfer<JzhaoMoney>(to,from_addr,value);
    let star = move_from<FootBallStar>(from_addr);
    assert!(!exists<FootBallStar>(signer::address_of(to)),STAR_ALREADY_EXISTS);
    move_to<FootBallStar>(to,star);
}
```

#### 单元测试

**1.配合account模块根据address创建测试用户**

**2.给用户A创建一张C罗球星卡，并设置金额为300**

**3.创建币，且给用户A和用户B一人发放500个币**

**4.进行交易，将用户A下的球星卡C罗转让给用户B，用户B赋给用户A对应的币**
```move
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
```

