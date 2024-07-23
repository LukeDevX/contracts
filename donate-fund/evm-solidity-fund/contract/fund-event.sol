// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/ERC20Permit.sol";

error NotOwner();
error IdoClose();

// eth 部署  588053 gas

contract Ido {
    address public immutable i_owner;
    bool public isIdo;
    ERC20 constant usdt = ERC20(0x50946e308aA06359455cfC348371761ECc2838C1); // USDT contract address

	// indexed 会保存在evm日志的topics中，方便日后检索
    event IdoLog(address indexed from, uint256 _amount);

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
    // 154350 gas * 2 = 1刀
    // 25679 gas * 2 = 0.17刀
    function ido(uint256 _amount) public returns (bool){
        if (!isIdo) {
            revert IdoClose();
        }
        emit IdoLog(msg.sender, _amount); // 记录发送日志
        return usdt.transferFrom(msg.sender, address(this), _amount); //授权转账
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
    }

    function idoClose() public isOwner {
        isIdo = false;
    }

    function idoOpen() public isOwner {
        isIdo = true;
    }

    //  返回当前合约余额
    function getUSDTBalance() external view returns (uint256) {
        return usdt.balanceOf(address(this)); // 当前合约余额
    }
}
