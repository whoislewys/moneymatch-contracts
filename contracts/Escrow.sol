// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract Escrow is EIP712 {
  /// @notice A struct to relate a player's in-game identity and an ethereum address
  struct Player {
    /// @notice The uuid representing a player in a given game. For ex. playing melee with Slippi, this should be a player's connect code.
    string id;
    /// @notice The eth address of the player
    address payable publicAddress;
  }

  /// @notice Represents an un-minted NFT, which has not yet been recorded into the blockchain. A signed voucher can be redeemed for a real NFT using the redeem function.
  struct GameResults {
    /// @notice The in-game uuid of the winning player
    string winnerId;
    /// @notice the EIP-712 signature of all other fields in the NFTVoucher struct. For a voucher to be valid, it must be signed by an account with the MINTER_ROLE.
    bytes signature;
  }

  string private constant SIGNING_DOMAIN = "MoneyMatch";
  string private constant SIGNATURE_VERSION = "1";

  address arbiter;
  Player public player1;
  uint256 public player1BetAmount;
  uint256 public player1BetBalance;
  Player public player2;
  uint256 public player2BetAmount;
  uint256 public player2BetBalance;
  address payable public winner;
  uint256 public winnings;
  bool public gameStarted;
  bool public gameEnded;

  event GameStarted(address payable player1Address, string player1Id, address payable player2Address, string player2Id);
  event Deposited(address indexed depositer);
  event GameEnded(address payable winner);

  /// All players confirm their bet amounts ahead of time (i.e. in browser).
  /// They are incentivized to do so because one of them has to pay gas to deploy this contract from a factory, and the bet amounts can be viewed by all parties, and if the game never starts all parties can refund. So changing the bet amounts from the agreed amounts just makes them potentially lose gas twice - once from a malicious deploy and once for a refund.
  constructor(
    address _arbiter,
    string memory _player1Id,
    address payable _player1Address,
    uint256 _player1BetAmount,
    string memory _player2Id,
    address payable _player2Address,
    uint256 _player2BetAmount
  ) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
    arbiter = _arbiter;
    player1 = Player(_player1Id, _player1Address);
    player1BetAmount = _player1BetAmount;
    player2 = Player(_player2Id, _player2Address);
    player2BetAmount = _player2BetAmount;

    // solc 0.8 adds are safe yay
    winnings = player1BetAmount + player2BetAmount;

    gameStarted = false;
    gameEnded = false;
  }

  function deposit(address depositorAddress) public payable {
    if (depositorAddress == player1.publicAddress) {
      require(msg.value == player1BetAmount, "Incorrect bet amount");
      player1BetBalance += msg.value;
    } else if (depositorAddress == player2.publicAddress) {
      require(msg.value == player2BetAmount, "Incorrect bet amount");
      player2BetBalance += msg.value;
    }

    emit Deposited(depositorAddress);
  }

  function startGame() public {
    require(!gameStarted, "Game already started");
    gameStarted = true;
    emit GameStarted(player1.publicAddress, player1.id, player2.publicAddress, player2.id);
  }

  // Maybe instead of winner being passed as an arg, event stream gets written to ipfs while game is played, this reaches out to ipfs to get the result. if any discrepancy is noticed between event streams for key events, only refunds are allowed
  function endGame(GameResults calldata gameResults) public {
    // make sure signature is valid and get the address of the signer
    bytes32 hashedGameResults = _hashTypedDataV4(
      keccak256(abi.encode(keccak256("GameResults(string winnerId)"), gameResults.winnerId))
    );
    address gameResultsSigner = ECDSA.recover(hashedGameResults, gameResults.signature);
    require(gameResultsSigner == arbiter, "Only the arbiter can end the game");
    require(gameStarted == true, "Game has to be started before ending");
    require(gameEnded == false, "Game already over");

    if (keccak256(abi.encodePacked(gameResults.winnerId)) == keccak256(abi.encodePacked(player1.id))) {
      winner = player1.publicAddress;
    } else if (keccak256(abi.encodePacked(gameResults.winnerId)) == keccak256(abi.encodePacked(player2.id))) {
      winner = player2.publicAddress;
    }

    emit GameEnded(winner);
    gameEnded = true;
  }

  function claimWinnings() public {
    require(msg.sender == winner, "Only the winner can claim the winnings!");
    // TODO: make sure this transfer works lol
    // probly read this lol: https://solidity-by-example.org/sending-ether/
    // https://stackoverflow.com/questions/68588594/how-do-i-send-ether-and-data-from-a-smart-contract-to-an-eoa
    winner.transfer(player1BetBalance + player2BetBalance);
  }

  // TODO: implement claimable refunds
  // function refund() public {
  // }
}
