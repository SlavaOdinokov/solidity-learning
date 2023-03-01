// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library LibStr {
    function isEquals(string memory str1, string memory str2)
        internal
        pure
        returns (bool)
    {
        return keccak256(abi.encode(str1)) == keccak256(abi.encode(str2));
    }
}

library LibArray {
    function isExistsInArray(uint256[] memory arr, uint256 el)
        internal
        pure
        returns (bool)
    {
        bool res;
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == el) {
                res = true;
                return res;
            }
            res = false;
        }
        return res;
    }
}
