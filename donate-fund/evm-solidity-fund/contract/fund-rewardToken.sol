// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/ERC20Permit.sol";

error NotOwner();
error IdoClose();
error NotClaim();
error ClaimClose();
error InsufficientBalance();
error FailedSendToken();

// eth 部署  578758 gas * 2 = $ 4.04

contract Ido {
    address public immutable i_owner;
    bool public isIdo;
    bool public isClaim;
    mapping(address => uint256) public userMap; 
    ERC20 constant usdt = ERC20(0xceBf1fc593E5afE01cFB1162CA99591A7dCc5F70); // USDT contract address
    ERC20 constant ent = ERC20(0xBc7F0C51761Ae6e7109FCc8bA06C118126Cde8c9); // USDT contract address

	// indexed 会保存在evm日志的topics中，方便日后检索
    // event IdoLog(address indexed from, uint256 _amount);

    constructor() {
        i_owner = msg.sender;
        isIdo = true;
        isClaim = false;
    }


    modifier isOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }



    // 添加捐款 ido
    // 	85077 gas * 2 =  0.59
    function ido(uint256 _amount) public returns (bool){
        if (!isIdo) {
            revert IdoClose();
        }
        // emit IdoLog(msg.sender, _amount); // 记录发送日志

        // 1u = 1 / 0.0005 ent = 2000ent
        // 存储用户地址和领取ent代币数
        userMap[msg.sender] = _amount * 2000;

        return usdt.transferFrom(msg.sender, address(this), _amount); //授权转账   
    }

    // 61798 gas * 2 =  0.43
    function claimToken() external  returns (bool){
        if (!isClaim) {
            revert ClaimClose();
        }
        uint256  _amount = userMap[msg.sender];

        if(_amount > 0){
        // 修改领取状态
            userMap[msg.sender] = 0;
            return ent.transfer(msg.sender, _amount);
        }
        revert NotClaim();
    }

    //实现发送功能
    //  _to：要发送 USDT 的地址
    //  _amount：要发送的 USDT 金额

	//pure：函数既不能读取也不能写入链上
	//view：函数只能读取状态变量

    // public: 函数可以被合约内部和外部调用。
    // external: 函数只能被合约外部调用。内部调用需要使用 this 关键字。
    // internal: 函数只能在合约内部及其继承合约中调用。
    // private: 函数只能在合约内部调用，继承合约中也不能调用。

    function withdraw(address _to, uint256 _amount) external isOwner {
        
        if(usdt.balanceOf(address(this)) < _amount){
            revert InsufficientBalance();
        }

        if(!usdt.transfer(_to, _amount)){
            revert FailedSendToken();
        }
    }

       // 取出剩余token，到指定地址 
    // eth：
    function withdrawENT(address _to, uint256 _amount) external isOwner {
         if(ent.balanceOf(address(this)) < _amount){
            revert InsufficientBalance();
        }
         if(!ent.transfer(_to, _amount)){
            revert FailedSendToken();
        }
    }

    function idoClose() public isOwner {
        isIdo = false;
    }

    function idoOpen() public isOwner {
        isIdo = true;
    }

    function claimClose() public isOwner {
        isClaim = false;
    }
    // 	26724 gas * 2 = 0.19
    function claimOpen() public isOwner {
        isClaim = true;
    }

    //  返回当前合约余额
    function getUSDTBalance() external view returns (uint256) {
        return usdt.balanceOf(address(this)); // 当前合约余额
    }

    function getENTTBalance() external view returns (uint256) {
        return ent.balanceOf(address(this)); // 当前合约余额
    }
}
