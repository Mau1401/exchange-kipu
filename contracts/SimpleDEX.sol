// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleERC20TokenOZ.sol"; 


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

contract SimpleDEX {
    // ============== VARIABLES ============
    TokenA public tokenA;
    TokenB public tokenB;

    // ============== MAPPING ==============

    // ============== EVENTOS ==============

    // ============== CONSTRUCTOR ==========
    constructor(address _tokenA, address _tokenB){
        tokenA = TokenA(_tokenA);
        tokenB = TokenB(_tokenB);

    }
    // ============== MODIFICADORES ========

    // ============================
    // FUNCIONES EXTENDIDAS
    addLiquidity(uint256 amountA, uint256 amountB){

    }
    swapAforB(uint256 amountAIn){

    }
    swapBforA(uint256 amountBIn){

    }
    removeLiquidity(uint256 amountA, uint256 amountB){

    }
    getPrice(address _token){

    }
}