// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


// https://www.youtube.com/watch?v=NkARLoc8Hc0 （发币）
contract ENT is ERC20, ERC20Burnable, Ownable {
  using SafeMath for uint256;

  // mapping(address => uint256) private _balances; // 统计给谁mint的数量
  // mapping(address => bool) controllers; // 铸币权限

  uint256 private _totalSupply; //现在供应总量
  uint256 private MAXSUP; // 累计供应量，与totalSupply相同，用于确定是否mint完整的supply(可能其他流动性挖矿会增加totalSupply)
  uint256 constant MAXIMUMSUPPLY=100000000000 *10**18;  // 最大供应量

  // 代币全称和符号
  constructor(address initialOwner) ERC20("ENT coin", "ENT")  Ownable(initialOwner){ 
      _mint(msg.sender, 100000000000  * 10 ** 18);// 创建时给发送者铸造

  }

  function mint(address to, uint256 amount) public onlyOwner {
    // require(controllers[msg.sender], "Only controllers can mint"); 
    require((MAXSUP+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
    _totalSupply = _totalSupply.add(amount);
    MAXSUP=MAXSUP.add(amount);
    // _balances[to] = _balances[to].add(amount);
    _mint(to, amount);
  }

  // function burnFrom(address account, uint256 amount) public override { // 管理者销毁币
  //     if (controllers[msg.sender]) {
  //         _burn(account, amount);
  //     }
  //     else {
  //         super.burnFrom(account, amount);
  //     }
  // }

  // function addController(address controller) external onlyOwner {
  //   controllers[controller] = true;
  // }

  // function removeController(address controller) external onlyOwner {
  //   controllers[controller] = false;
  // }
  
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  function maxSupply() public  pure returns (uint256) {
    return MAXIMUMSUPPLY;
  }

}