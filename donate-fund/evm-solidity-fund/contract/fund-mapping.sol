// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/ERC20Permit.sol";

error NotOwner();
error IdoClose();

// eth 部署 	899454 gas
// mapping 记录捐赠信息

contract Ido {
    mapping(address => uint256) public idoMap;
    address[] public keys; // 删除时使用
    mapping(address => bool) private inserted; // keys去重验证


    address public immutable i_owner;
    bool public isIdo;
    ERC20 constant usdt = ERC20(0xd9145CCE52D386f254917e481eB44e9943F39138); // USDT contract address

	// indexed 会保存在evm日志的topics中，方便日后检索
    event SendRecord(address indexed _to, uint256 _amount);

    constructor() {
        i_owner = msg.sender;
        isIdo = true;
    }

    modifier isOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    // function Fund() public payable {
    //     if (!isIdo) {
    //         revert IdoClose();
    //     }
    //     idoMap[msg.sender] += msg.value;
    // }

    // // 合约直接接收功能
    // receive() external payable {
    // // Handle incoming Ether or tokens
    //     Fund();

    // }

    // fallback() external payable {
    //     Fund();
    // }
    // 添加捐款 ido
    //  eth：154350 gas * 2 = 1刀
    function ido(uint256 _amount) public returns (bool) {
        if (!isIdo) {
            revert IdoClose();
        }

        if(!inserted[msg.sender]){
            keys.push(msg.sender);
            inserted[msg.sender] = true;
        }

        idoMap[msg.sender] += _amount;

        return usdt.transferFrom(msg.sender, address(this), _amount); //授权转账
        // return usdt.transfer(address(this), _amount); // 直接转账 合约发起转账
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
        require(
            usdt.balanceOf(address(this)) >= _amount,
            "Insufficient balance in contract"
        );

        require(usdt.transfer(_to, _amount), "Failed to send USDT");

        emit SendRecord(_to, _amount); // 记录发送日志
    }

    function idoClose() public isOwner {
        isIdo = false;
    }

    function idoOpen() public isOwner {
        isIdo = true;
    }

    // 获取idomap。mapping 只能是内部函数或库函数的参数和返回值
    // function getIdomap() external view returns (mapping) {
    //     return idoMap; // 当前合约余额
    // }
	
    // 查询所有ido用户地址
    function getUserKey() public view returns (address[] memory) {
        return keys;
    }

    // 查询某个用户的ido金额
    function getUserIdo(address _address) public view returns (uint256) {
        return idoMap[_address];
    }
	
    //  返回当前合约余额
    function getUSDTBalance() external view returns (uint256) {
        return usdt.balanceOf(address(this)); // 当前合约余额
    }
}
