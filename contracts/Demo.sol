// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract DemoContract {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(address _to) {
        require(msg.sender == owner, "You are not an owner!");
        require(_to != address(0), "Incorrect address!");
        _;
    }

    event Paid(address indexed _from, uint256 _amount, uint256 _timestamp);

    function pay() public payable {
        emit Paid(msg.sender, msg.value, block.timestamp);
    }

    function withdraw(address payable _to) external onlyOwner(_to) {
        _to.transfer(address(this).balance);
    }

    receive() external payable {
        pay();
    }
}
