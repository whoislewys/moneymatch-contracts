// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./Escrow.sol";

contract EscrowFactory {
  event EscrowCreated(
    string indexed player1Id,
    address payable player1Address,
    string indexed player2Id,
    address payable player2Address,
    address escrowAddress
  );

  function createEscrow(
    address _arbiter,
    string memory _player1Id,
    address payable _player1Address,
    uint256 _player1BetAmount,
    string memory _player2Id,
    address payable _player2Address,
    uint256 _player2BetAmount
  ) public {
    Escrow escrow = new Escrow(
      _arbiter,
      _player1Id,
      _player1Address,
      _player1BetAmount,
      _player2Id,
      _player2Address,
      _player2BetAmount
    );

    address escrowAddress = address(escrow);

    emit EscrowCreated(_player1Id, _player1Address, _player2Id, _player2Address, escrowAddress);
  }
}
