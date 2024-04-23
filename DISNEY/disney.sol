// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.22 <0.9.0;
import "./ERC20.sol";

contract Disney {

    // DECLARACIONES INICIALES
    // Instancia del contrato token
    ERC20Basic private token;
    // Direccion de Disney (owner)
    address payable public owner;

    // Constructor
    constructor () {
        token = new ERC20Basic(10000);
        owner = payable(msg.sender);
    }

    // Estructura de datos para almacenar a los clientes de Disney
    struct cliente {
        uint tokensComprados;
        string [] atraccionesDisfrutadas;
    }
    // Mapping para el registro de clientes
    mapping (address => cliente) public clientes;


    // GESTIÓN DE TOKENS
    // Función para establecer el precio de un Token
    function precioTokens(uint _numTokens) internal pure returns(uint) {
        // Conversión de tokens a Ethers
        return _numTokens * (1 ether);
    }

    // función para comprar tokens en disney y disfrutar de las atracciones
    function compraTokens(uint _numTokens) public payable {
        // Establecer el precio de los Tokens
        uint coste = precioTokens(_numTokens);
        // Se evalua el dinero que el cliente paga por los Tokens
        require(msg.value >= coste, "Compra menos Tokens o paga con mas ethers");
        // Diferencia de lo que el cliente paga
        uint returnValue = msg.value - coste;
        // Disney retorna la cantidad de ethers al cliente
        payable(msg.sender).transfer(returnValue);
        // Obtención del número de tokens disponibles
        uint balance = token.balanceOf(address(this));
        require(_numTokens <= balance, "Compra un numero menor de Tokens");
        // Se transfiere el número de tokens al cliente
        token.transfer(msg.sender, _numTokens);
        // Registro de tokens comprados
        clientes[msg.sender].tokensComprados += _numTokens;
    }

    // Visualizar el número de tokens de un Cliente
    function misTokens() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    // Función para generar mas tokens
    function generaTokens(uint _numTokens) public unicamenteDisney(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    // Modificador para controlar las funciones ejecutables por disney
    modifier unicamenteDisney(address _direccion) {
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    // GESTION DE DISNEY EN ATRACCIONES
    // Eventos
    event disfrutaAtraccion(string, uint, address);
    event nuevaAtraccion(string, uint);
    event bajaAtraccion(string);

    // Estructura de la atraccion
    struct atraccion {
        string nombre;
        uint precio;
        bool estado;
    }

    // Mapping para relacionar un numbre de la atraccion con una estructura de datos de la atraccion
    mapping (string => atraccion) public mappingAtracciones;
    // Array para almacenar el nombre de las atracciones
    string[] atracciones;
    // Mapping para relaccionar un cliente con su historial en Disney
    mapping (address => string[]) historialAtracciones;

    // Crar nuevas atracción para Disney
    function agregarAtraccion(string memory _nombreAtraccion, uint _precio) public unicamenteDisney(msg.sender) {
        // Creacion de una atracción en Disney
        mappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
        // Almacenar en un array el nombre de la atracción
        atracciones.push(_nombreAtraccion);
        // Emisión del evento para l anueva atracción
        emit nuevaAtraccion(_nombreAtraccion, _precio);
    }

    // Dar de baja a las atracciones en Disney
    function deshabilitarAtraccion(string memory _nombreAtraccion) public unicamenteDisney(msg.sender) {
        // El estado de la atracción pasa a FALSE => No está en uso
        mappingAtracciones[_nombreAtraccion].estado = false;
        // Emisión del evento para la baja de la atracción
        emit bajaAtraccion(_nombreAtraccion);
    }

    // Visualizar las atracciones
    function atraccionesDisponibles() public view returns(string[] memory) {
        return atracciones;
    }

    function subirseAtraccion(string memory _nombreAtraccion) public {
        // Precio de la atraccion (en tokens)
        uint tokensAtraccion = mappingAtracciones[_nombreAtraccion].precio;
        // Verifica estado de la atracción
        require(mappingAtracciones[_nombreAtraccion].estado == true, "Esta atraccion no esta disponible");
        // Comprobar que hay tokens suficientes
        require(misTokens() >= tokensAtraccion, "No tiene suficiente saldo para esta atraccion");

        /* El cliente paga la atraccion en Tokens, ha isdo necesario crear una función en ERC20.sol 
        debido a que en caso de usar el Transfer o TransferForm las direcciones que 
        se escogían para realizar la transacción eran equivocadas. Ya que el msg.sender que recibía 
        el método Transfer o TransferForm era la dirección del contrato */
        token.transferDisney(msg.sender, address(this), tokensAtraccion);
        historialAtracciones[msg.sender].push(_nombreAtraccion);
        // Emisión del evento de disfrutar la atracción
        emit disfrutaAtraccion(_nombreAtraccion, tokensAtraccion, msg.sender);
    }

    // Visualizar el historial de atracciones disfutadas por un cliente
    function historial() public view returns(string[] memory) {
        return historialAtracciones[msg.sender];
    }

    // Devolver los tokens al cliente
    function devolverTokens(uint _numTokens) public payable {
        // El número de tokens a devolver es positivo
        require(_numTokens > 0, "Necesitas devolver una cantidad positiva de tokens");
        // No se pueden devolver tokens que no se tienen
        require(misTokens() >= _numTokens, "No tienes los tokens que deseas devolver");
        // El cliente devuelve los tokens
        token.transferDisney(msg.sender, address(this), _numTokens);
        // Devolución de los ethers al cliente
        payable(msg.sender).transfer(precioTokens(_numTokens));
    }

    // GESTION DE DISNEY EN COMIDAS
    // Eventos
    event disfrutaComida(string, uint, address);
    event nuevaComida(string, uint);
    event quitarComida(string);

    // Estructura de la atraccion
    struct comida {
        string nombre;
        uint precio;
        bool disponible;
    }

    // Mapping para relacionar un nombre de la comida con una estructura de datos de la comida
    mapping (string => comida) public mappingComidas;
    // Array para almacenar el nombre de las atracciones
    string[] comidas;
    // Mapping para relaccionar un cliente con su historial en comidas
    mapping (address => string[]) historialComidas;

    // Crear nuevas comidas para Disney
    function agregarComida(string memory _nombreComida, uint _precioComida) public unicamenteDisney(msg.sender) {
        mappingComidas[_nombreComida] = comida(_nombreComida, _precioComida, true);
        comidas.push(_nombreComida);
        emit nuevaComida(_nombreComida, _precioComida);
    }

    // Dar de baja a las comidas en Disney
    function eliminarComida(string memory _nombreComida) public unicamenteDisney(msg.sender) {
        mappingComidas[_nombreComida].disponible = false;
        emit quitarComida(_nombreComida);
    }

    // Visualizar las comidas
    function consultarComidas() public view returns(string[] memory) {
        return comidas;
    }

    function comerComida(string memory _nombreComida) public {
        require(mappingComidas[_nombreComida].disponible == true, "Esta comida no esta disponible");

        uint precioComida = mappingComidas[_nombreComida].precio;
        require(precioComida <= misTokens(), "No tienes suficientes tokens para pagar");

        token.transferDisney(msg.sender, address(this), precioComida);
        historialComidas[msg.sender].push(_nombreComida);
        emit disfrutaComida(_nombreComida, precioComida, msg.sender);
    } 

    // Visualizar el historial de comidas disfutadas por un cliente
    function consultarHistorialComidas() public view returns(string[] memory) {
        return historialComidas[msg.sender];
    }
}