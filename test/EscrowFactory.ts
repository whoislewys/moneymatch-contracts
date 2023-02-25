import { expect } from "chai";
import { Contract } from "ethers";
import { parseEther } from "ethers/lib/utils";
import hardhat from "hardhat";

describe("EscrowFactory", async function () {
  let EscrowFactory: Contract;
  before(async function () {
    // for the fe
    // const EscrowFactory__Factory = await new ethers.ContractFactory(EscrowFactory__factory.abi, EscrowFactory__factory.bytecode, owner);
    const EscrowFactory__Factory = await hardhat.ethers.getContractFactory("EscrowFactory");
    EscrowFactory = await EscrowFactory__Factory.deploy();
  });

  it("should create a new Escrow contract", async () => {
    // Arrange
    const [owner, otherAccount, account3] = await hardhat.ethers.getSigners();
    // const arbiterAddress = "0x58438bdd4579f412279dc5bc4763dfe740a7a91f";

    const _player1Id = "TARC#8646";
    const _player1Address = owner.address;
    const _player1BetAmount = parseEther("0.69");

    const _player2Id = "MANG#0";
    const _player2Address = otherAccount.address;
    const _player2BetAmount = parseEther("0.69");

    // Act
    const createEscrowTx = await EscrowFactory.createEscrow(
      account3.address,
      _player1Id,
      _player1Address,
      _player1BetAmount,
      _player2Id,
      _player2Address,
      _player2BetAmount,
    );
    const createdTx = await createEscrowTx.wait(1);
    const escrowAddress = createdTx.events[0].args[4];
    const Escrow__Factory = await hardhat.ethers.getContractFactory("Escrow");
    const Escrow = Escrow__Factory.attach(escrowAddress);

    // Assert new Escrow contract has the correct bet amounts
    const player1BetAmount = await Escrow.player1BetAmount();
    expect(player1BetAmount).to.equal(_player1BetAmount);
    const player2BetAmount = await Escrow.player2BetAmount();
    expect(player2BetAmount).to.equal(_player2BetAmount);
  });
});
