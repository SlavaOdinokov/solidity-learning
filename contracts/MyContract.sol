// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Ownable {
    address owner;

    constructor(address ownerOverride) {
        owner = ownerOverride == address(0) ? msg.sender : ownerOverride;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not an owner!");
        _;
    }

    function withdraw(address payable _to) public virtual onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}

abstract contract Balances is Ownable {
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(address payable _to) public virtual override onlyOwner {
        _to.transfer(getBalance());
    }
}

contract MyContract is Ownable, Balances {
    constructor(address _owner) Ownable(_owner) {}

    function withdraw(address payable _to)
        public
        override(Ownable, Balances)
        onlyOwner
    {
        // Balances.withdraw(_to);
        super.withdraw(_to);
    }
}
