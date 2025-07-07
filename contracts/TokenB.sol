// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./SimpleERC20TokenOZ.sol"; 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenB is ERC20 {
    constructor(uint256 initialSupply) ERC20("TokenB", "TKNB") {
        _mint(msg.sender, initialSupply);
    }
}
/**
contract TokenB is SimpleERC20TokenOZ{
    constructor(address initialOwner) 
        SimpleERC20TokenOZ(
            "TokenB",
            "TKNB",
            1000000 * 10**18, // 1 millon de token
            initialOwner
        )
    {}
}
**/