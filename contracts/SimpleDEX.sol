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
    event LiquidityRemoved(address indexed user, uint256 amountA, uint256 amountB);
    event SwappedAforB(address indexed user, uint256 amountAIn, uint256 amountBOut);
    event SwappedBforA(address indexed user, uint256 amountAIn, uint256 amountBOut);
    event SwapPriceCalc(address _token, uint256 price);

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

        // Actualiza pools
        poolA += amountA;
        poolB += amountB;
        
        // Actualizar liquidez
        userPool[msg.sender] += liquidityMinted;

        // Transferir tokens al contrato
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
    
        // Notificar evento
        emit LiquidityAdded(msg.sender, amountA, amountB);
    }


    /**
     * @dev Intercambia TokenA por TokenB
     * @param amountAIn Cantidad de TokenA a intercambiar
     * @return amountBOut Cantidad de TokenB recibida
     */
    function swapAforB(uint256 amountAIn) external returns (uint256 amountBOut){
        require(amountAIn > 0, "Amount to swap must be greater than 0");
        require(poolA > 0 && poolB > 0, "Insufficient liquidity in pools");

        // Calcular  los precios de intercambio a partir de la formula del producto constante
        amountBOut = (poolB * amountAIn) / (poolA + amountAIn);
        
        // Actualiza pools
        poolA += amountAIn;
        poolB -= amountBOut;

        // Transferir tokens
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        // Notifica evento
        emit SwappedAforB(msg.sender, amountAIn, amountBOut);
    }

    /**
     * @dev Intercambia TokenB por TokenA
     * @param amountBIn Cantidad de TokenB a intercambiar
     * @return amountAOut Cantidad de TokenA recibida
     */
    function swapBforA(uint256 amountBIn) external returns (uint256 amountAOut){
        require(amountBIn > 0, "Amount to swap must be greater than 0");
        require(poolA > 0 && poolB > 0, "Insufficient liquidity in pools");

        // Calcular  los precios de intercambio a partir de la formula del producto constante
        amountAOut = (poolA * amountBIn) / (poolB + amountBIn);
        
        // Actualiza pools
        poolB += amountBIn;
        poolA -= amountAOut;

        // Transferir tokens
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        // Notifica evento
        emit SwappedBforA(msg.sender, amountBIn, amountAOut);
    }

    /**
     * @dev Retirar liquidez del pool
     * @param amountA Cantidad de TokenA a retirar
     * @param amountB Cantidad de TokenB a retirar
     */
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner{
        require(amountA > 0 && amountB > 0, "Amount must be greater than 0");
        require(amountA <= poolA && amountB <= poolB, "Insufficient liquidity in pools");

        //Calcular liquidez a quemar
        uint256 liquidityToBurn = (amountA * totalPool) / poolA;
            
        require(liquidityToBurn <= userPool[msg.sender], "Insufficient liquidity by user");
    
        //Actualizar pools
        userPool[msg.sender] -= liquidityToBurn;
        totalPool -= liquidityToBurn;
        poolA -= amountA;
        poolB -= amountB;

        // Transferir tokens al contrato
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);    

        //Notificar eventos
        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /**
     * @dev Relacion de precios de un token con respecto al otro
     * @param _token Direccion del token a consultar
     * @return price Precio del token en temrinos del otro
     */
    function getPrice(address _token) external returns (uint256 price) {
        require(_token == address(tokenA) || _token == address(tokenB), "Token not supported");

        if (_token == address(tokenA)){
            price = (poolB * 1e18) / poolA; // Precio de A en términos de B
        } else {
            price = (poolA * 1e18) / poolB; // Precio de B en términos de A
        }
        
        emit SwapPriceCalc(_token, price);
    }
}