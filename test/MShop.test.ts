import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { MShop } from "../typechain-types";
import { Contract } from "ethers";
// import tokenJSON from "../artifacts/contracts/ERC20.sol/MCSToken.json";
// eslint-disable-next-line @typescript-eslint/no-var-requires
const tokenJSON = require("../artifacts/contracts/ERC20.sol/MCSToken.json");

describe("MShop", function () {
  let owner: SignerWithAddress;
  let buyer: SignerWithAddress;
  let shop: MShop;
  let erc20: Contract;

  beforeEach(async function () {
    // получаем аккаунты
    [owner, buyer] = await ethers.getSigners();

    // разворачиваем контракты в сети
    const MShop = await ethers.getContractFactory("MShop", owner);
    shop = await MShop.deploy();
    await shop.deployed();

    erc20 = new ethers.Contract(await shop.token(), tokenJSON.abi, owner);
  });

  it("should have an owner and a token address", async function () {
    expect(await shop.ownerShop()).to.eq(owner.address);
    expect(await shop.token()).to.properAddress;
  });

  it("allows to buy", async function () {
    const amountToken = 5;
    const txData = { value: amountToken, to: shop.address };
    const tx = await buyer.sendTransaction(txData);
    await tx.wait();

    expect(await erc20.balanceOf(buyer.address)).to.eq(amountToken);
    await expect(() => tx).to.changeEtherBalance(shop, amountToken);
    await expect(tx)
      .to.emit(shop, "Bought")
      .withArgs(buyer.address, amountToken);
  });

  it("allows to sell", async function () {
    const amountToken = 5;
    const amountSell = 3;
    const txData = { value: amountToken, to: shop.address };
    const tx = await buyer.sendTransaction(txData);
    await tx.wait();

    const approval = await erc20
      .connect(buyer)
      .approve(shop.address, amountSell);
    await approval.wait();

    const sellTx = await shop.connect(buyer).sell(amountSell);

    expect(await erc20.balanceOf(buyer.address)).to.eq(
      amountToken - amountSell
    );
    await expect(() => sellTx).to.changeEtherBalance(shop, -amountSell);
    await expect(sellTx)
      .to.emit(shop, "Sold")
      .withArgs(buyer.address, amountSell);
  });
});
