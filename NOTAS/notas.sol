// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

// -----------------------------------
//  ALUMNO   |    ID    |      NOTA
// -----------------------------------
//  Marcos |    77755N    |      5
//  Joan   |    12345X    |      9
//  Maria  |    02468T    |      2
//  Marta  |    13579U    |      3
//  Alba   |    98765Z    |      5

contract Notas {

    // Dirección del profesor
    address public profesor;

    // Constructor
    constructor () {
        profesor = msg.sender;
    }

    // Mapping para relacionar el hash de la identidad del alumno con su nota del examen
    mapping(bytes32 => uint) notas;

    // Array de los alumnos que pidan revisiones de examen
    string[] revisiones;

    // Eventos
    event alumnoEvaluado(bytes32);
    event eventoRevision(string);

    // Comprobar que el que ejecuta la función es el profesor
    modifier unicamenteProfesor(address _direccion) {
        require(_direccion == profesor, "No tienes permisos para ejecutar esta funcion.");
        _;
    }

    // Función para evaluar a alumnos
    function evaluar(string memory _idAlumno, uint _nota) public unicamenteProfesor(msg.sender) {

        // Hash de la identificación del alumno
        bytes32 hashIdAlumno = keccak256(abi.encodePacked(_idAlumno));
        // Relación entre el hash de la identificación del alumno
        notas[hashIdAlumno] = _nota;
        // Emisión del evento
        emit alumnoEvaluado(hashIdAlumno);
    }

    // Visualizar notas
    function solicitarNota(string memory _idAlumno) public view returns(uint) {

        // Hash de la identificación del alumno
        bytes32 hashIdAlumno = keccak256(abi.encodePacked(_idAlumno));
        // Nota asociada al hash del id del alumno
        uint notaAlumno = notas[hashIdAlumno];
        // Retornar nota
        return(notaAlumno);
    }

    // Pedir revisión de la nota
    function solocitarRevision(string memory _idAlumno) public {
        // Almacenamiento de la identidad del alumno en un array
        revisiones.push(_idAlumno);
        emit eventoRevision(_idAlumno);
    }

    // Ver todas las revisiones
    function verRevisiones() public view unicamenteProfesor(msg.sender) returns(string[] memory) {
        // Devolver las identidades de los alumnos que han solicitado revisión
        return revisiones;
    }
}