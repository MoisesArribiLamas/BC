// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/*
    Ejercicio 3 — Práctica Blockchain
    ---------------------------------
    Objetivo: Contrato con variables de estado, constructor y funciones públicas y privadas.
*/

contract CuentaBancaria {
    // VARIABLES DE ESTADO (datos almacenados en blockchain)
    string private titular;     // nombre del titular (privado)
    uint256 private saldo;      // saldo de la cuenta (privado)
    address public propietario; // dirección del propietario del contrato (pública)

    // CONSTRUCTOR (inicializa las variables de estado)
    constructor(string memory _titular, uint256 _saldoInicial) {
        titular = _titular;
        saldo = _saldoInicial;
        propietario = msg.sender; // el que despliega el contrato
    }

    // FUNCIÓN PRIVADA
    // Suma una cantidad al saldo interno
    function incrementarSaldo(uint256 cantidad) private {
        saldo += cantidad;
    }

    // FUNCIÓN PÚBLICA
    // Depositar dinero en la cuenta
    function depositar(uint256 cantidad) public {
        incrementarSaldo(cantidad);
    }

    // FUNCIÓN PÚBLICA
    // Retirar dinero (si el saldo es suficiente)
    function retirar(uint256 cantidad) public {
        require(msg.sender == propietario, "Solo el propietario puede retirar");
        require(cantidad <= saldo, "Saldo insuficiente");
        saldo -= cantidad;
    }

    // FUNCIÓN PÚBLICA (solo lectura)
    // Consultar el saldo de la cuenta
    function consultarSaldo() public view returns (uint256) {
        return saldo;
    }

    // FUNCIÓN PÚBLICA (solo lectura)
    // Consultar el titular de la cuenta
    function consultarTitular() public view returns (string memory) {
        return titular;
    }
}
