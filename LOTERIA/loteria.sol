// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.22 <0.9.0;
import "./ERC20.sol";

contract Loteria {

    // Instancia del contrato Token
    ERC20Basic private token;

    // Direcciones
    address public owner;
    address public contrato;

    // Número de tokens a crear
    uint public tokenCreados = 10000;

    // Eventos
    event comprandoTokens(uint, address);

    constructor () {
        token = new ERC20Basic(tokenCreados);
        owner = msg.sender;
        contrato = address(this);
    }

    // Establecer el precio de los tokens en ethers
    function precioTokens(uint _numTokens) internal pure returns (uint) {
        return _numTokens*(1 ether);
    }

    // Generar mas tokens por la lotería
    function generaTokens(uint _numTokens) public onlyOwner(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    // Modificador para controlar las funciones ejecutables por el owner del contrato
    modifier onlyOwner(address _direccion) {
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    // Comprar Tokens para comprar boletos para la lotería
    function compraTokens(uint _numTokens) public payable {
        // Calcular el coste de los tokens
        uint coste = precioTokens(_numTokens);
        require(coste <= msg.value, "Compra menos Tokens o paga con mas Ethers");
        // Diferencia a pagar: 30 ethers -> 20 Tokens = 30-20 = 10
        uint returnValue = msg.value - coste;
        payable(msg.sender).transfer(returnValue);
        // Obtener el balance del contrato
        uint balance = tokensDisponibles();
        // Filtro para evaluar los tokens a comprar con los tokens disponibles
        require(_numTokens <= balance, "Compra un numero de tokens adecuado");
        // Transferencia de Tokens al comprador
        token.transfer(msg.sender, _numTokens);
        // Emitir el evento de compra de tokens
        emit comprandoTokens(_numTokens, msg.sender);
    }

    // Balance de tokens en el contrato de lotería
    function tokensDisponibles() public view returns(uint) {
        return token.balanceOf(contrato);
    }

    // Obtener el balance de tokens acumulados en el Bote
    function bote() public view returns(uint) {
        return token.balanceOf(owner);
    }

    // Balance de Tokens de una persona
    function misTokens() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }

    // Declaraciones de la lotería
    // Precio del boleto en Tokens
    uint public precioBoleto = 5;
    // Relación entre la persona que compra los boletos y los números de los boletos
    mapping (address => uint[]) idPersonaBoletos;
    // Relación necesaria para identificar al ganador
    mapping (uint => address) adnBoleto;
    // Número aleatorio
    uint randNonce = 0;
    // Boletos generados
    uint[] boletosComprados;
    // Eventos
    event boletoComprado(uint, address);  // Evento cuando se compra un boleto
    event boletoGanador(uint, address);  // Evento del ganador
    event tokensDevueltos(uint, address);

    // Función para comprar boletos
    function comprarBoleto(uint _numBoletos) public  {
        // Precio total de los boletos a comprar
        uint costeTotal = _numBoletos*precioBoleto;
        require(costeTotal <= misTokens(), "No tienes suficientes tokens");
        // Transferencia de tokens al owner -> bote/premio
        /* El cliente paga la atraccion en Tokens, ha isdo necesario crear una función en ERC20.sol 
        debido a que en caso de usar el Transfer o TransferForm las direcciones que 
        se escogían para realizar la transacción eran equivocadas. Ya que el msg.sender que recibía 
        el método Transfer o TransferForm era la dirección del contrato. Y debe ser la dirección de la 
        persona física
        */
        token.transferLoteria(msg.sender, owner, costeTotal);

        for (uint i = 0; i < _numBoletos; i++) {
            // Se realiza un hash de un número aleatorio generado mediante 3 valores y se toman sus últumos 4 dígitos (entre 0 y 9999)
            uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 10000;
            randNonce++;
            // Almacenamos los datos de los boletos
            idPersonaBoletos[msg.sender].push(random);
            // Número del bolero comprado
            boletosComprados.push(random);
            // Asignación del ADN del boleto para tener un ganador
            adnBoleto[random] = msg.sender;
            // Emisión del evento 
            emit boletoComprado(random, msg.sender);
        }
    }

    // Visualizar el número de boletos de una persona
    function misBoletos() public view returns(uint[] memory) {
        return idPersonaBoletos[msg.sender];
    }

    // Función para generar un ganador e ingrsarle los Tokens
    function generaGanador() public onlyOwner(msg.sender) {
        // Debe haber boletos comprados
        require(boletosComprados.length > 0, "No hay boletos comprados");
        // Declaración de la longitud del array
        uint longitud = boletosComprados.length;
        // Aleatoriamente elijo un número entre 0 y la Longitud
        // 1- Elección de una posición aleatoria del array
        uint posicionArray = uint(keccak256(abi.encodePacked(block.timestamp))) % longitud;
        // 2- Selección del número aleatorio mediante la posición del array aleatoria
        uint eleccion = boletosComprados[posicionArray];
        // Recuperar la dirección del ganador
        address direccionGanador = adnBoleto[eleccion];
        // Emisión del evento del ganador
        emit boletoGanador(eleccion, direccionGanador);
        // Enviarle los tokens del premio al ganador
        token.transferLoteria(owner, direccionGanador, bote()); 
    }

    // Devolución de los tokens
    function devolverTokens(uint _numTokens) public payable {
        // El número de tokens a devolver debe ser mayor a 0
        require(_numTokens > 0, "No hay tokens para devolver");
        // El usuario/cliente debe tener los tokens que desea devolver
        require(_numTokens <= misTokens(), "No tienes los tokens que deseas devolver");
        // DEVOLUCIÓN:
        // 1- El cliente devuelva los tokens
        // 2- La lotería paga los tokens devueltos
        token.transferLoteria(msg.sender, address(this), _numTokens);
        payable(msg.sender).transfer(precioTokens(_numTokens));
        emit tokensDevueltos(_numTokens, msg.sender);
    }

}