// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenA.sol"; 
import "./TokenB.sol"; 

contract SimpleDEX {
    // ============== VARIABLES ==============
    TokenA public tokenA;
    TokenB public tokenB;
    address public owner;

    uint256 public poolA;
    uint256 public poolB;

    // ============== EVENTOS ==============
    event LiquidityAdded(uint256 amountA, uint256 amountB);
    event LiquidityRemoved(uint256 amountA, uint256 amountB);
    event SwappedAforB(address indexed user, uint256 amountAIn, uint256 amountBOut);
    event SwappedBforA(address indexed user, uint256 amountAIn, uint256 amountBOut);
    event SwapPriceCalc(address _token, uint256 price);

    // ============== CONSTRUCTOR ==============
    constructor(address _tokenA, address _tokenB){
        tokenA = TokenA(_tokenA);
        tokenB = TokenB(_tokenB);
        owner = msg.sender;

    }
    // ============== MODIFICADORES ==============
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    // ============== FUNCIONES EXTENDIDAS ==============
    /**
     * @dev Agrega liquidez 
     * @param amountA Cantidad de TokenA a depositar.
     * @param amountB Cantidad de TokenB a depositar.
     */
    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        
        require (amountA > 0 && amountB > 0, "Amounts mus be great than 0");
        
        // Actualiza pools
        poolA += amountA;
        poolB += amountB;

        // Transferir tokens usando las funciones directas de los contratos
        require(
            tokenA.transferFrom(msg.sender, address(this), amountA),
            "TokenA transfer failed"
        );
        require(
            tokenB.transferFrom(msg.sender, address(this), amountB),
            "TokenB transfer failed"
        );

        // Notificar evento
        emit LiquidityAdded(amountA, amountB);
    }


    /**
     * @dev Intercambia TokenA por TokenB
     * @param amountAIn Cantidad de TokenA a intercambiar
     */
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Amount to swap must be greater than 0");
        require(poolA > 0 && poolB > 0, "Insufficient liquidity in pools");

        // Calcular  los precios de intercambio a partir de la formula del producto constante
        uint256 amountBOut = (poolB * amountAIn) / (poolA + amountAIn);
        
        // Actualiza pools
        poolA += amountAIn;
        poolB -= amountBOut;

        // Transferir tokens
        require(tokenA.transferFrom(msg.sender, address(this), amountAIn),"TokenA transfer failed");
        require(tokenB.transfer(msg.sender, amountBOut), "TokenB transfer failed");

        // Notifica evento
        emit SwappedAforB(msg.sender, amountAIn, amountBOut);
    }

    /**
     * @dev Intercambia TokenB por TokenA
     * @param amountBIn Cantidad de TokenB a intercambiar
     */
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Amount to swap must be greater than 0");
        require(poolA > 0 && poolB > 0, "Insufficient liquidity in pools");

        // Calcular  los precios de intercambio a partir de la formula del producto constante
        uint256 amountAOut = (poolA * amountBIn) / (poolB + amountBIn);
        
        // Actualiza pools
        poolB += amountBIn;
        poolA -= amountAOut;

        // Transferir tokens
        require(tokenB.transferFrom(msg.sender, address(this), amountBIn),"TokenB transfer failed");
        require(tokenA.transfer(msg.sender, amountAOut),"TokenA transfer failed");

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

        //Actualizar pools
        poolA -= amountA;
        poolB -= amountB;

        // Transferir tokens al contrato
        require(tokenA.transfer(msg.sender, amountA), "TokenA transfer failed");
        require(tokenB.transfer(msg.sender, amountB), "TokenB transfer failed");    

        //Notificar eventos
        emit LiquidityRemoved(amountA, amountB);
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