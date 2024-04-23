// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

// -----------------------------------
//  CANDIDATO   |   EDAD   |      ID
// -----------------------------------
//  Toni        |    20    |    12345X
//  Alberto     |    23    |    54321T
//  Joan        |    21    |    98765P
//  Javier      |    19    |    56789W

contract Votacion {

    // Direccion del propietario del contrato
    address public owner;

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Relacción entre el nombre del candidato y el hash de sus datos personales
    mapping(string => bytes32) idCandidato;

    // Relaccion entre el nombre del candidato y el número de votos
    mapping(string => uint) votosCandidato;

    // Lista para almacenar todos los nombre de los candidatos
    string[] candidatos;

    // Lista de los hashes de la identidad de los votantes
    bytes32[] votantes;


    // Dar de alta a los candidatos
    function registrarCandidato(string memory _nombre, uint _edad, string memory _id) public {
        // Se añade el nombre del nuevo candidato
        candidatos.push(_nombre);

        // Se fabrica un hash con los datos del candidato
        bytes32 hashDatosCandidato = keccak256(abi.encodePacked(_nombre, _edad, _id)); 

        // Se relaciona el nombre con sus datos
        idCandidato[_nombre] = hashDatosCandidato;

        // Se pone los votos del nuevo candidato a 0
        votosCandidato[_nombre] = 0;
    }


    // Ver todos los candidatos
    function consultarCandidatos() public view returns(string[] memory) {
        return candidatos;
    }


    function votar(string memory _nombre) public {
        // Se realiza el hash de la dirección del votante
        bytes32 hashVotante = keccak256(abi.encodePacked(msg.sender));

        // Si el hash del votante ya ha votado, no puede volver a votar
        for (uint i = 0; i < votantes.length; i++) {

            require(hashVotante != votantes[i], "No se puede votar mas de una vez");
        }
        // Se añade el votante a la lista de que ya ha votad
        votantes.push(hashVotante);
        
        // Se añade un voto al candidato votado
        votosCandidato[_nombre]++;
    }


    // Devolver el número de votos del candidato
    function consultarVotos(string memory _nombre) public view returns(uint) {
        return votosCandidato[_nombre];
    }


    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function verResultados() public view returns(string memory) {
        // Se guardan todos los resultados de todos los candidatos
        string memory resultados;
        
        // Recorreomos todos los candidatos para saber sus votos
        for (uint i = 0; i < candidatos.length; i++) {

            // Se concatena el texto para mostrar al usuario
            resultados = string(abi.encodePacked(resultados, "(", candidatos[i], ": ", uint2str(consultarVotos(candidatos[i])), " votos) | "));
            // resultados = string(abi.encodePacked(resultados, "(", candidatos[i], ": 2 votos) | "));


        }
        return resultados;
    }

    function ganador() public view returns(string memory) {
        // Se guarda el ganador de la votación
        string memory gandorVotacion = candidatos[0];
        
        // Recorreomos todos los candidatos para saber el ganador
        for (uint i = 1; i < candidatos.length; i++) {

            if (consultarVotos(gandorVotacion) < consultarVotos(candidatos[i])) {
                gandorVotacion = candidatos[i];
            } else {
                if (consultarVotos(gandorVotacion) == consultarVotos(candidatos[i])) {
                    gandorVotacion = string(abi.encodePacked("Empate: ", gandorVotacion, " y ", candidatos[i], " con ", uint2str(consultarVotos(candidatos[i])), " votos"));
                }
            }
        }
        return gandorVotacion;
    }
}