// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract OMS {

    // Dirección de la OMS -> Owner/Dueño del contrato
    address public oms;

    // Constructor del contrato
    constructor () {
        oms = msg.sender;
    }

    // Mapping para relaccionar los centros de salud (address) con la validez del sistema de gestión
    mapping (address => bool) public validacionCentrosSalud;

    // Relacionar una dirección de un centro de salud con su contrato 
    mapping (address => address) public centroSaludContrato;

    // Ejemplo: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 -> true = Tiene permisos para crear su Smart Contract
    // Ejemplo: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 -> false = No tiene permisos para crear su Smart Contract

    // Array de direcciones que almacene las direcciones de los contratos de los centros de salud valirados
    address[] public direccionesContratosSalud;

    // Array de las direcciones que soliciten acceso
    address[] solicitudes;

    // Eventos
    event solicitudAcceso(address);
    event nuevoCentroValidado(address);
    event nuevoContrato(address, address);

    // Modificador que permita unicamente la ejecución de funciones por la OMS
    modifier onlyOMS(address _direccion) {
        require(_direccion == oms, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    // función para solicitar acceso al sistema médico
    function solicitarAcceso() public {
        solicitudes.push(msg.sender);
        emit solicitudAcceso(msg.sender);
    }

    // Función que svisualiza las direcciones que han solicitado este acceso
    function visualizarSolicitudes() public view onlyOMS(msg.sender) returns(address[] memory) {
        return solicitudes;
    }

    // Función para validar nuevos centros de salud que puedan autogestionarse -> onlyOMS
    function centrosSalud(address _centroSalud) public onlyOMS(msg.sender) {
        // Asignación del estado de validez al centro de salud
        validacionCentrosSalud[_centroSalud] = true;
        // Emisión del evento
        emit nuevoCentroValidado(_centroSalud);
    }

    // Función que permita crear un contrato inteligente de un centro de salud
    function factoryCentroSalud() public {
        // Filtrado para que únicamente los centros de salud validados sean capaces de ejecutar esta función
        require(validacionCentrosSalud[msg.sender] == true, "No tienes permisos para realizar esta funcion");
        // Generar un Smart Contract -> Generar su dirección
        address contratoCentroSalud = address(new CentroSalud(msg.sender));
        // Almacenar la direccion del contrato en el array
        direccionesContratosSalud.push(contratoCentroSalud);
        // Relacción entre el centro de salud y su contrato
        centroSaludContrato[msg.sender] = contratoCentroSalud;
        // Emisión del evento
        emit nuevoContrato(contratoCentroSalud, msg.sender);
    }

}

// Contrato autogestionable por un centro de salud
contract CentroSalud {

    // Direcciones iniciales
    address public direccionCentroSalud;
    address public direccionContrato;

    constructor(address _direccion) {
        direccionCentroSalud = _direccion;
        direccionContrato = address(this);
    }

    // Mapping para relacionar el hash de la persona con los resultados (diagnóstico, CODIGO IPFS)
    mapping (bytes32 => Resultado) resultadosMedicos;

    // Estructura de los resultados
    struct Resultado {
        bool diagnostico;
        string codigoIPFS;
    }

    // Eventos
    event nuevoResultado(string, bool);

    // Modificador que permita unicamente la ejecución de funciones por el centro
    modifier onlyCentroSalud(address _direccion) {
        require(_direccion == direccionCentroSalud, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    // Función para emitir un resultado de una prueba
    // Parámetros -> id: 123456X | true | QmNZTbxobVxzsCv4uwvSrh5a8bw6zJKFmNYvKbeRdDrnjT
    function resultadosPrueba(string memory _idPersona, bool _resultadoPrueba, string memory _codigoIPFS) public onlyCentroSalud(msg.sender) {
        // Hash de la identificación de la perosna
        bytes32 hashIdPersona = keccak256(abi.encodePacked(_idPersona));
        // Relación del hash de la persona con la estructura de resultados
        resultadosMedicos[hashIdPersona] = Resultado(_resultadoPrueba, _codigoIPFS);
        // Emisión de un envento
        emit nuevoResultado(_codigoIPFS, _resultadoPrueba);
    }

    // Función qu eprmita la visualización de los resultados
    function visualizarResultados(string memory _idPersona) public view returns(string memory, string memory) {
        // Hash de la identidad de la persona
        bytes32 hashIdPersona = keccak256(abi.encodePacked(_idPersona));
        // Retorno de un booleano como un string
        string memory resultadoPrueba;

        if (resultadosMedicos[hashIdPersona].diagnostico == true) {
            resultadoPrueba = "Positivo";
        } else {
            resultadoPrueba = "Negativo";
        }
        // Retorno de los parámetros necesarios
        return (resultadoPrueba,  resultadosMedicos[hashIdPersona].codigoIPFS);
    }

}