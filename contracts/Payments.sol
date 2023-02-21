// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract PaymentContract {
    struct Payment {
        uint256 amount;
        uint256 timestamp;
        address from;
        string message;
    }

    struct Balance {
        uint256 totalPayments;
        mapping(uint256 => Payment) payments;
    }

    mapping(address => Balance) balances;

    function currentBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPayment(address _addr, uint256 _index)
        public
        view
        returns (Payment memory)
    {
        return balances[_addr].payments[_index];
    }

    function pay(string memory _message) public payable {
        uint256 paymentNum = balances[msg.sender].totalPayments;
        balances[msg.sender].totalPayments++;

        Payment memory newPayment = Payment(
            msg.value,
            block.timestamp,
            msg.sender,
            _message
        );

        balances[msg.sender].payments[paymentNum] = newPayment;
    }
}
