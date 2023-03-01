import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { DemoContract, Logger } from "../typechain-types";

describe("DemoContract", function () {
  let owner: SignerWithAddress;
  let other_addr: SignerWithAddress;
  let demo: DemoContract;
  let logger: Logger;

  async function sendMoney(sender: SignerWithAddress) {
    const amount = 1000;
    const txData = { to: demo.address, value: amount };
    const tx = await sender.sendTransaction(txData);
    await tx.wait();
    return { tx, amount };
  }

  beforeEach(async function () {
    // получаем аккаунты
    [owner, other_addr] = await ethers.getSigners();

    // разворачиваем контракты в сети
    const Logger = await ethers.getContractFactory("Logger", owner);
    logger = await Logger.deploy();
    await logger.deployed();

    const Demo = await ethers.getContractFactory("DemoContract", owner);
    demo = await Demo.deploy(logger.address);
    await demo.deployed();
  });

  it("should allow to send money", async function () {
    const { tx, amount } = await sendMoney(other_addr);
    const { timestamp } = await ethers.provider.getBlock(tx.blockNumber);

    expect(() => tx).to.changeEtherBalance(demo, amount);
    expect(tx)
      .to.emit(demo, "Paid")
      .withArgs(other_addr.address, amount, timestamp);
  });

  it("should allow owner to withdraw funds", async function () {
    const { amount } = await sendMoney(other_addr);
    const tx = await demo.withdraw(owner.address);

    expect(tx).to.changeEtherBalances([demo, owner], [-amount, amount]);
  });

  it("should not allow other account to withdraw funds", async function () {
    await sendMoney(other_addr);

    await expect(
      demo.connect(other_addr).withdraw(other_addr.address)
    ).to.be.revertedWith("You are not an owner!");
  });

  describe("Logger", function () {
    it("allows to pay and get payment info", async function () {
      const amount = 1000;
      const txData = { value: amount, to: demo.address };
      const tx = await owner.sendTransaction(txData);
      await tx.wait();

      const amountInfo = await demo.getPayInfo(owner.address, 0);

      expect(tx).to.changeEtherBalance(demo, amount);
      expect(amountInfo).to.eq(amount);
    });
  });

  describe("LibDemo", function () {
    it("compare strings", async function () {
      const equal = await demo.compareStrings("cat", "cat");
      const notEqual = await demo.compareStrings("cat", "dog");

      expect(equal).to.eq(true);
      expect(notEqual).to.eq(false);
    });

    it("find uint in array", async function () {
      const arr = [1, 2, 3, 44, 67];
      const found = await demo.findNumInArray(arr, 3);
      const notFound = await demo.findNumInArray(arr, 99);

      expect(found).to.eq(true);
      expect(notFound).to.eq(false);
    });
  });
});
