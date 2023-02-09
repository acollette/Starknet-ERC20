// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_add
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.math import assert_not_zero

from openzeppelin.token.erc20.library import ERC20
from contracts.token.ERC20.IERC20 import IERC20

from contracts.token.ERC20.IDTKERC20 import IDTKERC20

////////// Declaring storage vars //////////

@storage_var
func dummy_token_address_storage() -> (dummy_token_address_storage: felt) {
}

@storage_var
func user_claimed_tokens(account: felt) -> (amount: Uint256) {
}

////////// Declaring getters //////////

@view
func dummy_token_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    account: felt
) {
    let (address) = dummy_token_address_storage.read();
    return (address,);
}

@view
func tokens_in_custody{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (amount: Uint256) {
    let (amount) = user_claimed_tokens.read(account);
    return (amount,);
}

////////// Constructor //////////

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _dummy_token_address: felt
) {
    dummy_token_address_storage.write(_dummy_token_address);
    return ();
}


////////// Externals //////////


@external
func get_tokens_from_contract{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    amount: Uint256
) {
    let (caller) = get_caller_address();
    let (this) = get_contract_address();
    let (dtk_address) = dummy_token_address_storage.read();
    let (pre_dtk_balance) = IDTKERC20.balanceOf(dtk_address, this);

    IDTKERC20.faucet(dtk_address);

    let (after_dtk_balance) = IDTKERC20.balanceOf(dtk_address, this);
    let (amount) = uint256_sub(after_dtk_balance, pre_dtk_balance);

    let (pre_user_balance) = user_claimed_tokens.read(caller);

    let (new_user_balance, carry) = uint256_add(pre_user_balance, amount);

    user_claimed_tokens.write(caller, new_user_balance);

    return (amount,);
}

@external
func withdraw_all_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    amount: Uint256
) {
    let (caller) = get_caller_address();
    let (amount) = user_claimed_tokens.read(caller);
    let (dtk_address) = dummy_token_address_storage.read();

    let new_amount: Uint256 = Uint256(0,0);

    user_claimed_tokens.write(caller, new_amount);
    IDTKERC20.transfer(dtk_address, caller, amount);

    return (amount,);
}

@external
func deposit_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256
) -> (new_user_balance: Uint256) {

    let (caller) = get_caller_address();
    let (dtk_address) = dummy_token_address_storage.read();
    let (this) = get_contract_address();

    let (pre_user_balance) = user_claimed_tokens.read(caller);
    let (new_user_balance, carry) = uint256_add(pre_user_balance, amount);

    user_claimed_tokens.write(caller, new_user_balance);

    IDTKERC20.transferFrom(dtk_address, caller, this, amount);

    return (new_user_balance,);
}

