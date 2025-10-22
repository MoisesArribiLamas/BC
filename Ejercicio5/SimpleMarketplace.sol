// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract SimpleMarketplace {
    address public propietario;
    uint public contadorItem;

    struct Item {
        uint id;
        string name;
        uint priceWei;
        address seller;
        bool sold;
    }

    mapping(uint => Item) public items;
    mapping(address => uint) public producto;

    event ItemCreated(uint indexed id, string name, uint priceWei, address indexed seller);
    event ItemBought(uint indexed id, address indexed buyer, uint priceWei);
    event ProceedsWithdrawn(address indexed seller, uint amountWei);

    constructor() {
        propietario = msg.sender;
    }

    function crearItem(string memory _name, uint _priceWei) public {
        require(_priceWei > 0, "Precio debe ser > 0");
        contadorItem++;
        items[contadorItem] = Item(contadorItem, _name, _priceWei, msg.sender, false);
        emit ItemCreated(contadorItem, _name, _priceWei, msg.sender);
    }

    function comprarItem(uint _id) public payable {
        Item storage it = items[_id];
        require(it.id == _id, "Item no existe");
        require(!it.sold, "Item ya vendido");
        require(msg.value >= it.priceWei, "Ether insuficiente");

        it.sold = true;
        producto[it.seller] += it.priceWei;

        // devolver exceso si pagaron de más
        if (msg.value > it.priceWei) {
            (bool s, ) = msg.sender.call{value: msg.value - it.priceWei}("");
            require(s, "Reembolso fallido");
        }

        emit ItemBought(_id, msg.sender, it.priceWei);
    }

    function gananciaProducto() public {
        uint amount = producto[msg.sender];
        require(amount > 0, "No hay fondos a retirar");
        producto[msg.sender] = 0;
        (bool s, ) = msg.sender.call{value: amount}("");
        require(s, "Retiro fallido");
        emit ProceedsWithdrawn(msg.sender, amount);
    }

    function conseguirItem(uint _id) public view returns (Item memory) {
        return items[_id];
    }

    receive() external payable {}
}
