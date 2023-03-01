import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BlockTag } from "@ethersproject/abstract-provider";
import { AucEngineContract } from "../typechain-types";

describe("AucEngineContract", function () {
  let owner: SignerWithAddress;
  let seller: SignerWithAddress;
  let buyer: SignerWithAddress;
  let contract: AucEngineContract;

  const auctionData = {
    startingPrice: ethers.utils.parseEther("0.0001"),
    duration: 60,
    discount: 3,
    item: "fake item",
  };

  async function getTimestamp(blockTag: BlockTag): Promise<number> {
    const blockInfo = await ethers.provider.getBlock(blockTag);
    return blockInfo.timestamp;
  }

  function delay(ms: number) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  beforeEach(async function () {
    // получаем аккаунты
    [owner, seller, buyer] = await ethers.getSigners();
    // разворачиваем контракт в сети
    const factory = await ethers.getContractFactory("AucEngineContract", owner);
    contract = await factory.deploy();
    await contract.deployed();
  });

  it("sets owner", async function () {
    const currentOwner = await contract.owner();
    expect(currentOwner).to.eq(owner.address);
  });

  describe("createAuction", function () {
    it("creates auction correctly", async function () {
      const tx = await contract.createAuction(
        auctionData.startingPrice,
        auctionData.duration,
        auctionData.discount,
        auctionData.item
      );

      const newAuction = await contract.auctions(0);
      const timestamp = await getTimestamp(tx.blockNumber);

      expect(newAuction.item).to.eq(auctionData.item);
      expect(newAuction.endsAt).to.eq(timestamp + auctionData.duration);
    });
  });

  describe("buy", function () {
    it("allows to buy", async function () {
      await contract
        .connect(seller)
        .createAuction(
          auctionData.startingPrice,
          auctionData.duration,
          auctionData.discount,
          auctionData.item
        );

      this.timeout(5000);
      await delay(1000);

      const buyTx = await contract
        .connect(buyer)
        .buy(0, { value: auctionData.startingPrice });

      const { finalPrice } = await contract.auctions(0);
      const sum =
        Number(finalPrice) - Math.floor((Number(finalPrice) * 10) / 100);

      await expect(() => buyTx).to.changeEtherBalance(seller, sum);
      await expect(buyTx)
        .to.emit(contract, "AuctionEnded")
        .withArgs(0, finalPrice, buyer.address);
      await expect(
        contract.connect(buyer).buy(0, { value: auctionData.startingPrice })
      ).to.be.revertedWith("Auction stopped!");
    });
  });
});
