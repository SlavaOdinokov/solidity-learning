// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract AucEngineContract {
    address public owner;
    uint256 constant DURATION = 2 days;
    uint256 constant FEE = 10;

    struct Auction {
        address payable seller;
        uint256 startingPrice;
        uint256 finalPrice;
        uint256 startAt;
        uint256 endsAt;
        uint256 discount;
        string item;
        bool stopped;
    }

    Auction[] public auctions;

    event AuctionCreated(
        uint256 index,
        string item,
        uint256 startingPrice,
        uint256 duration
    );

    event AuctionEnded(uint256 index, uint256 finalPrice, address buyer);

    modifier checkAuction(uint256 index) {
        Auction memory auction = auctions[index];
        require(!auction.stopped, "Auction stopped!");
        require(block.timestamp < auction.endsAt, "Auction ended!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createAuction(
        uint256 _startingPrice,
        uint256 _duration,
        uint256 _discount,
        string calldata _item
    ) external {
        uint256 duration = _duration != 0 ? _duration : DURATION;

        require(
            _startingPrice >= duration * _discount,
            "Incorrect starting price"
        );

        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            startingPrice: _startingPrice,
            finalPrice: _startingPrice,
            startAt: block.timestamp,
            endsAt: block.timestamp + duration,
            discount: _discount,
            item: _item,
            stopped: false
        });

        auctions.push(newAuction);

        emit AuctionCreated(
            auctions.length - 1,
            _item,
            _startingPrice,
            duration
        );
    }

    function getPriceForIndex(uint256 index)
        public
        view
        checkAuction(index)
        returns (uint256)
    {
        Auction memory foundAuction = auctions[index];
        uint256 elapsed = block.timestamp - foundAuction.startAt;
        uint256 discount = foundAuction.discount * elapsed;

        return foundAuction.startingPrice - discount;
    }

    function buy(uint256 index) public payable checkAuction(index) {
        Auction storage foundAuction = auctions[index];

        uint256 currentPrice = getPriceForIndex(index);
        require(msg.value >= currentPrice, "Not enough funds!");
        foundAuction.stopped = true;
        foundAuction.finalPrice = currentPrice;

        uint256 refund = msg.value - currentPrice;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        uint256 fee = (currentPrice * FEE) / 100;
        foundAuction.seller.transfer(currentPrice - fee);
        // payable(address(this)).transfer(fee);

        emit AuctionEnded(index, currentPrice, msg.sender);
    }
}
