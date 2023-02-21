import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { DemoContract } from "../typechain-types";

describe("DemoContract", function () {
  let owner: SignerWithAddress;
  let other_addr: SignerWithAddress;
  let contract: DemoContract;

  async function sendMoney(sender: SignerWithAddress) {
    const amount = 1000;
    const txData = { to: contract.address, value: amount };
    const tx = await sender.sendTransaction(txData);
    await tx.wait();
    return { tx, amount };
  }

  beforeEach(async function () {
    // получаем аккаунты
    [owner, other_addr] = await ethers.getSigners();
    // разворачиваем контракт в сети
    const factory = await ethers.getContractFactory("DemoContract", owner);
    contract = await factory.deploy();
    await contract.deployed();
  });

  it("should allow to send money", async function () {
    const { tx, amount } = await sendMoney(other_addr);
    const { timestamp } = await ethers.provider.getBlock(tx.blockNumber);

    expect(() => tx).to.changeEtherBalance(contract, amount);
    expect(tx)
      .to.emit(contract, "Paid")
      .withArgs(other_addr.address, amount, timestamp);
  });

  it("should allow owner to withdraw funds", async function () {
    const { amount } = await sendMoney(other_addr);
    const tx = await contract.withdraw(owner.address);

    expect(tx).to.changeEtherBalances([contract, owner], [-amount, amount]);
  });

  it("should not allow other account to withdraw funds", async function () {
    await sendMoney(other_addr);

    await expect(
      contract.connect(other_addr).withdraw(other_addr.address)
    ).to.be.revertedWith("You are not an owner!");
  });
});
