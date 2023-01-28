// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero

from openzeppelin.token.erc20.library import ERC20

////////// Declaring storage vars //////////

// Declaring a mapping called user_allowed. For each 'account' key, which is a felt, we store a value which is a felt also.
@storage_var
func user_allowed(account: felt) -> (allowed: felt) {
}

@storage_var
func user_level(account: felt) -> (level: felt) {
}

@storage_var
func level_amount(level: felt) -> (amount: Uint256) {
}

////////// Declaring getters //////////
//
// Getters
//

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return ERC20.name();
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    return ERC20.symbol();
}

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (totalSupply: Uint256) {
    let (totalSupply) = ERC20.total_supply();
    return (totalSupply=totalSupply);
}

@view
func decimals{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (decimals: felt) {
    return ERC20.decimals();
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (balance: Uint256) {
    return ERC20.balance_of(account);
}

@view
func allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, spender: felt
) -> (remaining: Uint256) {
    return ERC20.allowance(owner, spender);
}

@view
func allowlist_level{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (level: felt) {
    let (level) = user_level.read(account);
    return (level,);
}

//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    symbol: felt,
    name: felt,
) {
    ERC20.initializer(name, symbol, 18);
    let (caller) = get_caller_address();
    ERC20._mint(caller, Uint256(95000000000000000000000, 0));
    return ();
}


//
// Externals
//

@external
func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.transfer(recipient, amount);
}

@external
func transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    sender: felt, recipient: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.transfer_from(sender, recipient, amount);
}

@external
func approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.approve(spender, amount);
}

@external
func increaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, added_value: Uint256
) -> (success: felt) {
    return ERC20.increase_allowance(spender, added_value);
}

@external
func decreaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, subtracted_value: Uint256
) -> (success: felt) {
    return ERC20.decrease_allowance(spender, subtracted_value);
}

@external
func get_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    amount: Uint256
) {
    let (caller) = get_caller_address();
    let (level) = user_level.read(caller);

    let amount: Uint256 = Uint256(level * 1000000000000000000, 0);
    let zero: Uint256 = Uint256(0,0);

    if (level == 0) {
        return (zero,);
    } else {
        ERC20._mint(caller, amount);
    }

    return (amount,);
}

@external
func request_allowlist_level{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    level: felt
) -> (newLevel: felt) {
    let (caller) = get_caller_address();
    user_level.write(caller, level);
    let (newLevel) = user_level.read(caller);
    return(newLevel,);   
}