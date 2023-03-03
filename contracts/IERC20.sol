// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function mint(uint256 amount, address shop) external; // выпуск токенов

    function burn(address from, uint256 amount) external; // сжечь токены с адреса

    function decimals() external pure returns (uint256); // кол-во знаков после запятой

    function totalSupply() external view returns (uint256); // кол-во токенов в обороте

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external;

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256); // разрешение на перевод токенов третьему лицу

    function approve(address spender, uint256 amount) external; // разрещение на перевод токенов

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external; // перевод токенов с одного акка на другой

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approve(address indexed owner, address indexed to, uint256 amount);
}
