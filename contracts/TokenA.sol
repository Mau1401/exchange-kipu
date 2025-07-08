// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import "./SimpleERC20TokenOZ.sol"; 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    constructor(uint256 initialSupply) ERC20("TokenA", "TKNA") {
        _mint(msg.sender, initialSupply);
    }
}

/**
contract TokenA is SimpleERC20TokenOZ{
    constructor(address initialOwner) 
        SimpleERC20TokenOZ(
            "TokenA",
            "TKNA",
            1000000 * 10**18, // 1 millon de token
            initialOwner
        )
    {}
}
**/
