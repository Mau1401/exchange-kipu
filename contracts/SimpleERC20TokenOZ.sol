// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// PARA REMIX IMPORTAR DESDE GITHUB
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/Ownable.sol";

/**
 * @title SimpleERC20Token con OpenZeppelin
 * @dev Token ERC-20 educativo usando las librerías de OpenZeppelin
 * @notice Este contrato demuestra el uso de librerías estándar y buenas prácticas

 * Hereda de ERC20 (funcionalidad completa y segura)
 * Hereda de Ownable (control de acceso)
 */
abstract contract SimpleERC20TokenOZ is ERC20, Ownable {
    
    // ============================
    // EVENTOS
    
    /**
     * @dev Evento emitido cuando se crean nuevos tokens
     * @param to Dirección que recibe los tokens minteados
     * @param amount Cantidad de tokens creados
     */
    event TokensMinted(address indexed to, uint256 amount);
    
    /**
     * @dev Evento emitido cuando se queman tokens
     * @param from Dirección de la cual se quemaron los tokens
     * @param amount Cantidad de tokens quemados
     */
    event TokensBurned(address indexed from, uint256 amount);
    
    // ============================
    // CONSTRUCTOR
    
    /**
     * @dev Constructor que inicializa el token con OpenZeppelin
     * @param initialSupply Suministro inicial de tokens (en wei)
     * @param initialOwner Dirección del propietario inicial del contrato
     * 
     * EJEMPLO DE USO:
     * initialSupply: 1000000000000000000000000 (1M tokens)
     * initialOwner: tu dirección de MetaMask
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address initialOwner
    ) ERC20(name, symbol) {
        // establecemos el owner manualmente
        _transferOwnership(initialOwner);
        // _mint automáticamente:
        // 1. Valida que initialOwner != address(0)
        // 2. Actualiza totalSupply
        // 3. Actualiza balance del owner
        // 4. Emite Transfer(address(0), initialOwner, initialSupply)
        _mint(initialOwner, initialSupply);
    }
    
    // ============================
    // FUNCIONES EXTENDIDAS
    
    /**
     * @dev Función para crear nuevos tokens (solo el propietario)
     * @param to Dirección que recibirá los tokens
     * @param amount Cantidad de tokens a crear
     * 
     * CARACTERÍSTICAS DE SEGURIDAD:
     * - onlyOwner: Solo el propietario puede ejecutarla
     * - Valida to != address(0) (doble validación)
     * - _mint ya valida internamente address(0)
     * - Actualiza totalSupply automáticamente
     * - Emite Transfer event automáticamente
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "No se puede mint a direccion cero");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
    
    /**
     * @dev Función para quemar tokens propios
     * @param amount Cantidad de tokens a quemar
     * 
     * CARACTERÍSTICAS DE SEGURIDAD:
     * - Valida que msg.sender tenga suficientes tokens
     * - Reduce totalSupply automáticamente
     * - Emite Transfer(msg.sender, address(0), amount)
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
    
    /**
     * @dev Función para quemar tokens de otra dirección (requiere aprobación)
     * @param from Dirección de la cual quemar tokens
     * @param amount Cantidad de tokens a quemar
     * 
     * FUNCIONAMIENTO :
     * 1. Verifica allowance manualmente
     * 2. Reduce allowance con _approve
     * 3. _burn quema los tokens y reduce totalSupply
     * 4. Emite Transfer(from, address(0), amount)
     */
    function burnFrom(address from, uint256 amount) public {
        // manejamos allowance manualmente
        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= amount, "Burn amount exceeds allowance");
        
        // Reducir allowance antes del burn
        _approve(from, msg.sender, currentAllowance - amount);
        _burn(from, amount);
        emit TokensBurned(from, amount);
    }
    
    /**
     * @dev Override de función interna para agregar validaciones personalizadas
     * @param from Dirección origen (address(0) para mint)
     * @param to Dirección destino (address(0) para burn)
     * @param amount Cantidad a transferir
     * 
     * Esta función se llama ANTES de todas las transferencias, mints y burns
     * Es el punto central para agregar lógica personalizada
     * 
     * VALIDACIÓN AGREGADA:
     * Previene transferencias al contrato mismo (posible lock de tokens)
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        // Validación personalizada: no transferir al contrato mismo
        require(to != address(this), "No se puede transferir al contrato mismo");
        
        // Aquí se pueden agregar más validaciones:
        // - Blacklist de direcciones
        // - Límites de transferencia
        // - Fees automáticos
        // - Pausing mechanism
        
        // Llamar a la función padre para ejecutar la lógica original
        super._beforeTokenTransfer(from, to, amount);
    }
}

