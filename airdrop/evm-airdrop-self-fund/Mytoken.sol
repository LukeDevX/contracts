// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";


// 判断是否需要 销毁方法？
// 这里还能写其他什么方法。。。。

// eth部署 ：1925383 * 2 = 13.36 刀
// bsc部署 	1909064 gas
contract MyToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    constructor(address initialOwner)
        ERC20("MyToken", "ENT")
        Ownable(initialOwner)
        ERC20Permit("MyToken")
    {}

    // eth 54903 * 2 = 0.38刀
    // bsc 	71217 gas
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // eth 转账 35360 * 2 =  0.25刀
}
