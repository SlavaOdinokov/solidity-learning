// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./ILogger.sol";
import "./LibDemo.sol";

contract DemoContract {
    using LibStr for string;
    using LibArray for uint256[];

    address owner;
    ILogger logger;

    constructor(address _logger) {
        owner = msg.sender;
        logger = ILogger(_logger);
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

    function getPayInfo(address _from, uint256 _index)
        public
        view
        returns (uint256)
    {
        return logger.getEntry(_from, _index);
    }

    function compareStrings(string memory str1, string memory str2)
        public
        pure
        returns (bool)
    {
        // return LibStr.isEquals(str1, str2);
        return str1.isEquals(str2);
    }

    function findNumInArray(uint256[] memory arr, uint256 num)
        public
        pure
        returns (bool)
    {
        // return LibArray.isExistsInArray(arr, num);
        return arr.isExistsInArray(num);
    }

    receive() external payable {
        pay();
        logger.log(msg.sender, msg.value);
    }
}
