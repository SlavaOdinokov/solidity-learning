// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILogger {
    function log(address _from, uint256 _amount) external;

    function getEntry(address _from, uint256 _index)
        external
        view
        returns (uint256);
}
