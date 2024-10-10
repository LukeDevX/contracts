// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ENT is ERC20, ERC20Burnable, Ownable {
  using SafeMath for uint256;


  uint256 private _totalSupply; 
  uint256 private MAXSUP;
  uint256 constant MAXIMUMSUPPLY=100000000000 *10**18;  

  // 代币全称和符号
  constructor(address initialOwner) ERC20("ENT coin", "ENT")  Ownable(initialOwner){ 
 
  }

  function mint(address to, uint256 amount) public onlyOwner {
    // require(controllers[msg.sender], "Only controllers can mint"); 
    require((MAXSUP+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
    _totalSupply = _totalSupply.add(amount);
    MAXSUP=MAXSUP.add(amount);
    // _balances[to] = _balances[to].add(amount);
    _mint(to, amount);
  }

 
  
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  function maxSupply() public  pure returns (uint256) {
    return MAXIMUMSUPPLY;
  }

}