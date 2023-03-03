// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    address owner;
    uint256 totalTokens;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    string _name;
    string _symbol;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        address shop
    ) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply, shop);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not an owner!");
        _;
    }

    modifier enoughTokens(address _from, uint256 _amount) {
        require(
            balanceOf(_from) >= _amount,
            "There are not enough tokens on the balance!"
        );
        _;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function mint(uint256 amount, address shop) public onlyOwner {
        _beforeTokenTransfer(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    function burn(address from, uint256 amount)
        public
        onlyOwner
        enoughTokens(from, amount)
    {
        _beforeTokenTransfer(from, address(0), amount);
        balances[from] -= amount;
        totalTokens -= amount;
    }

    function decimals() external pure returns (uint256) {
        return 18; // 1 token == 1 wei
    }

    function totalSupply() external view returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount)
        external
        enoughTokens(msg.sender, amount)
    {
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function allowance(address _owner, address spender)
        public
        view
        returns (uint256)
    {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public {
        _approve(msg.sender, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public enoughTokens(sender, amount) {
        _beforeTokenTransfer(sender, recipient, amount);
        require(allowances[sender][recipient] >= amount, "Is not allowed!");
        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) internal virtual {
        allowances[sender][spender] = amount;
        emit Approve(sender, spender, amount);
    }
}

contract MCSToken is ERC20 {
    constructor(address shop) ERC20("MCSToken", "MCS", 100, shop) {}
}

contract MShop {
    IERC20 public token;
    address payable public ownerShop;

    event Bought(address indexed _buyer, uint256 _amount);
    event Sold(address indexed _seller, uint256 _amount);

    modifier onlyOwner() {
        require(msg.sender == ownerShop, "You are not an owner!");
        _;
    }

    constructor() {
        token = new MCSToken(address(this));
        ownerShop = payable(msg.sender);
    }

    function sell(uint256 _amountToSell) external {
        require(
            _amountToSell > 0 && token.balanceOf(msg.sender) >= _amountToSell,
            "Incorrect amount!"
        );

        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountToSell, "Is not allowed!");

        token.transferFrom(msg.sender, address(this), _amountToSell);
        payable(msg.sender).transfer(_amountToSell);
        emit Sold(msg.sender, _amountToSell);
    }

    function getTokensBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    receive() external payable {
        uint256 tokensToBuy = msg.value; // 1 wei = 1 token
        require(tokensToBuy > 0, "Not enough funds!");
        require(getTokensBalance() >= tokensToBuy, "Not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);
        emit Bought(msg.sender, tokensToBuy);
    }
}
