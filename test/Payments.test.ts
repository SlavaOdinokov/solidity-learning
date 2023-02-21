import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { PaymentContract } from "../typechain-types";

describe("PaymentContract", function () {
  let acc1: SignerWithAddress;
  let acc2: SignerWithAddress;
  let payments: PaymentContract;

  beforeEach(async function () {
    // получаем аккаунты
    [acc1, acc2] = await ethers.getSigners();
    // разворачиваем контракт в сети
    const factory = await ethers.getContractFactory("PaymentContract", acc1);
    payments = await factory.deploy();
    await payments.deployed();
  });

  it("should be deployed", async function () {
    // проверить валидность адреса
    expect(payments.address).to.be.properAddress;
  });

  it("should have 0 ether by default", async function () {
    const balance = await payments.currentBalance();
    expect(balance).to.eq(0);
  });

  it("should be possible to send funds", async function () {
    const sum = 1000;
    const message = "hello from hardhat";

    const tx = await payments.connect(acc2).pay(message, { value: sum });
    await tx.wait();
    const payInfo = await payments.getPayment(acc2.address, 0);

    expect(() => tx).to.changeEtherBalances([acc2, payments], [-sum, sum]);
    expect(payInfo.message).to.eq(message);
    expect(payInfo.amount).to.eq(sum);
    expect(payInfo.from).to.eq(acc2.address);
  });
});
