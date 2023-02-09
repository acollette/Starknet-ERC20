// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_add
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.math import assert_not_zero

from openzeppelin.token.erc20.library import ERC20
from openzeppelin.access.ownable.library import Ownable
from contracts.token.ERC20.IERC20 import IERC20

////////// Declaring storage vars //////////


////////// Declaring getters //////////


////////// Constructor //////////
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) {
    Ownable.initializer(owner);
    return ();
}

////////// Externals //////////
@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256
) -> (success: felt) {

    Ownable.assert_only_owner();

    let (caller) = get_caller_address();
    ERC20._mint(caller, amount);
    return(1,);
}

@external
func set_new_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    new_owner: felt
) -> (success: felt) {
    Ownable.transfer_ownership(new_owner);
    return(1,);    
}

