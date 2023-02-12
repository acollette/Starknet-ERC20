%lang starknet

from starkware.cairo.common.uint256 import Uint256

// Dummy token is an ERC20 with a faucet
@contract_interface
namespace IExerciseSolutionToken {

    func mint(amount: Uint256, user: felt) -> (success: felt) {
    }

}