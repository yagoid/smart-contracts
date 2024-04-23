// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;
import "./SafeMath.sol";


// Juan Gabriel --> 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// Joan Amengual --> 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// Maria Santos --> 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db


interface IERC20 {
    
    // Devuelve la cantidad de tokens en existencia
    function totalSupply() external view returns(uint);

    // Devuelve la cantidad de tokens para una dirección indicada por parámetro
    function balanceOf(address _account) external view returns(uint);

    // Devuelve el número de tokens que el spender podrá gastar en nombre del propietario (owner)
    function allowance(address _owner, address _spender) external view returns(uint);

    // Devuelve un valor booleano resultado de la operación indicada
    function transfer(address _recipient, uint _amount) external returns(bool);

    // Devuelve un valor booleano con el resultado de la operación de gasto
    function approve(address _spender, uint _amount) external returns(bool);

    // Devuelve un valor booleano con el resultado de la opeación de paso de una cantidad de tokens usando el método allowance()
    function transferFrom(address _sender, address _recipient, uint _amount) external returns(bool);


    // Evento que se debe emitir cuando una cantidad de tokens pase de un origen a un destino
    event Transfer(address indexed _from, address indexed _to, uint _value);

    // Evento que se debe emitir cuando se establece una asignación con el método allowance()
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

// Impementación de las funciones del token ERC20
contract ERC20Basic is IERC20 {

    string public constant NAME = "ERC20BlockchainAZ";
    string public constant SYMBOL = "ERC";
    uint8 public constant DECIMALS = 2;

    // event Transfer(address indexed _from, address indexed _to, uint _tokens);
    // event Approval(address indexed _owner, address indexed _spender, uint _tokens);


    using SafeMath for uint;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint totalSupply_;

    constructor (uint _initialSupply) {
        totalSupply_ = _initialSupply;
        balances[msg.sender] = totalSupply_;
    }


    function totalSupply() public override view returns(uint) {
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address _tokenOwner) public override view returns(uint) {
        return balances[_tokenOwner];
    }

    function allowance(address _owner, address _delegate) public override view returns(uint) {
        return allowed[_owner][_delegate];
    }

    function transfer(address _recipient, uint _numTokens) public override returns(bool) {
        require(_numTokens <= balances[msg.sender]);

        // Se resta el número de monedas al sender
        balances[msg.sender] = balances[msg.sender].sub(_numTokens);
        // Se le suma el número de monedas al receptor
        balances[_recipient] = balances[_recipient].add(_numTokens);

        emit Transfer(msg.sender, _recipient, _numTokens);

        return true;
    }

    function approve(address _delegate, uint _numTokens) public override returns(bool) {
        allowed[msg.sender][_delegate] = _numTokens;
        emit Approval(msg.sender, _delegate, _numTokens);
        return true;
    }

    function transferFrom(address _owner, address _buyer, uint _numTokens) public override returns(bool) {
        require(_numTokens <= balances[_owner]);
        require(_numTokens <= allowed[_owner][msg.sender]);

        balances[_owner] = balances[_owner].sub(_numTokens);
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_numTokens);
        balances[_buyer] = balances[_buyer].add(_numTokens);

        emit Transfer(_owner, _buyer, _numTokens);

        return true;
    }
}