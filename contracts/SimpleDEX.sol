// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleERC20TokenOZ.sol"; 
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/Ownable.sol";


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

contract SimpleDEX is Ownable{
    // ============== VARIABLES ==============
    TokenA public tokenA;
    TokenB public tokenB;

    uint256 public poolA;
    uint256 public poolB;

    uint256 public totalPool;

    // ============== MAPPING ==============
    mapping (address => uint256) public userPool;
    // ============== EVENTOS ==============

    event LiquidityAdded(address indexed user, uint256 amountA, uint256 amountB);
    event LiquidityRemoved();
    event SwappedAforB();
    event SwappedBforA();
    event SwapPriceCalc();

    // ============== CONSTRUCTOR ==============
    constructor(address _tokenA, address _tokenB){
        tokenA = TokenA(_tokenA);
        tokenB = TokenB(_tokenB);

    }
    // ============== MODIFICADORES ==============

    // ============== FUNCIONES EXTENDIDAS ==============

    /**
     * @dev Agrega liquidez al totalPool
     * @param amountA Cantidad de TokenA a depositar.
     * @param amountB Cantidad de TokenB a depositar.
     */
    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        
        require (amountA > 0 && amountB > 0, "Amounts mus be great than 0");
        
        uint256 liquidityMinted = 0;
        if (totalPool == 0){
            totalPool = amountA + amountB;
        } else {
            require(amountA * poolB == amountB * poolA, "Invalid pool ratio");
            liquidityMinted = (amountA * totalPool) / poolA;
            totalPool += liquidityMinted;
        }

        // Transferir tokens al contrato
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
        
        // Actualiza pools
        poolA += amountA;
        poolB += amountB;
        
        // Actualizar liquidez
        userPool[msg.sender] += liquidityMinted;
        
        // Notificar evento
        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    function swapAforB(uint256 amountAIn){

    }
    function swapBforA(uint256 amountBIn){

    }
    function removeLiquidity(uint256 amountA, uint256 amountB){

    }
    function getPrice(address _token){

    }
}