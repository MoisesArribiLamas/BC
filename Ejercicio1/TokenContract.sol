// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract TokenContract {
    address public owner;
    struct Receivers {
        string name;
        uint256 tokens;
    }

    mapping(address => Receivers) public users;

    // Precio: 1 token = 5 Ether
    uint256 public constant TOKEN_PRICE_WEI = 5 ether;

    // Evento para compras y transferencias
    event TokensPurchased(address indexed buyer, uint256 amountTokens, uint256 valuePaidWei);
    event TokensGiven(address indexed from, address indexed to, uint256 amountTokens);

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo owner puede ejecutar");
        _;
    }

    constructor() {
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    function double(uint _value) public pure returns (uint) {
        return _value * 2;
    }

    function register(string memory _name) public {
        users[msg.sender].name = _name;
    }

    function giveToken(address _receiver, uint256 _amount) onlyOwner public {
        require(users[owner].tokens >= _amount, "Owner no tiene tokens suficientes");
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
        emit TokensGiven(owner, _receiver, _amount);
    }

    // Nueva función: comprar tokens pagando Ether
    // _amount = número de tokens que se quieren comprar
    // Debe enviarse value = _amount * TOKEN_PRICE_WEI
    function buyTokens(uint256 _amount) public payable {
        require(_amount > 0, "Cantidad debe ser > 0");

        uint256 requiredWei = _amount * TOKEN_PRICE_WEI;
        require(msg.value >= requiredWei, "Ether enviado insuficiente para comprar tokens");

        // comprobar que el owner tiene tokens suficientes
        require(users[owner].tokens >= _amount, "El owner no tiene tokens suficientes para vender");

        // transferir tokens desde owner al comprador
        users[owner].tokens -= _amount;
        users[msg.sender].tokens += _amount;

        // Si el comprador pagó de más, devolvemos el excedente
        if (msg.value > requiredWei) {
            uint256 excess = msg.value - requiredWei;
            //usar call para devolver Ether
            (bool sent, ) = msg.sender.call{value: excess}("");
            require(sent, "Reembolso fallido");
        }

        emit TokensPurchased(msg.sender, _amount, requiredWei);
    }

    // Función que cuando se pulsa el boton "contractBalance"
    // muestra cuánto Ether hay en el contrato
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Función para que el owner retire el Ether acumulado en el contrato
    function withdraw(uint256 _amountWei) public onlyOwner {
        require(address(this).balance >= _amountWei, "Contrato no tiene suficiente Ether");
        (bool sent, ) = owner.call{value: _amountWei}("");
        require(sent, "Retiro fallido");
    }

    // Fallback/receive para recibir Ether (por si alguien envía directamente)
    receive() external payable {}
    fallback() external payable {}
}
