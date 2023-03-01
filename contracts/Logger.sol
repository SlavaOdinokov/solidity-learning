// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./ILogger.sol";

contract Logger is ILogger {
    mapping(address => uint256[]) payments;

    function log(address _from, uint256 _amount) public {
        require(_from != address(0), "address cannot be null");
        payments[_from].push(_amount);
    }

    function getEntry(address _from, uint256 _index)
        public
        view
        returns (uint256)
    {
        return payments[_from][_index];
    }
}
