// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenERC20 is ERC20 {
    constructor(
        uint256 initialSupply,
        string memory _name,
        string memory _ticker
    ) ERC20(_name, _ticker) {
        _mint(msg.sender, initialSupply);
    }
}
