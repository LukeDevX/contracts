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

// eth ����  578758 gas * 2 = $ 4.04

contract Ido {
    address public immutable i_owner;
    bool public isIdo;
    bool public isClaim;
    mapping(address => uint256) public userMap; 
    ERC20 constant usdt = ERC20(0xceBf1fc593E5afE01cFB1162CA99591A7dCc5F70); // USDT contract address
    ERC20 constant ent = ERC20(0xBc7F0C51761Ae6e7109FCc8bA06C118126Cde8c9); // USDT contract address

	// indexed �ᱣ����evm��־��topics�У������պ����
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



    // ��Ӿ�� ido
    // 	85077 gas * 2 =  0.59
    function ido(uint256 _amount) public returns (bool){
        if (!isIdo) {
            revert IdoClose();
        }
        // emit IdoLog(msg.sender, _amount); // ��¼������־

        // 1u = 1 / 0.0005 ent = 2000ent
        // �洢�û���ַ����ȡent������
        userMap[msg.sender] = _amount * 2000;

        return usdt.transferFrom(msg.sender, address(this), _amount); //��Ȩת��   
    }

    // 61798 gas * 2 =  0.43
    function claimToken() external  returns (bool){
        if (!isClaim) {
            revert ClaimClose();
        }
        uint256  _amount = userMap[msg.sender];

        if(_amount > 0){
        // �޸���ȡ״̬
            userMap[msg.sender] = 0;
            return ent.transfer(msg.sender, _amount);
        }
        revert NotClaim();
    }

    //ʵ�ַ��͹���
    //  _to��Ҫ���� USDT �ĵ�ַ
    //  _amount��Ҫ���͵� USDT ���

	//pure�������Ȳ��ܶ�ȡҲ����д������
	//view������ֻ�ܶ�ȡ״̬����

    // public: �������Ա���Լ�ڲ����ⲿ���á�
    // external: ����ֻ�ܱ���Լ�ⲿ���á��ڲ�������Ҫʹ�� this �ؼ��֡�
    // internal: ����ֻ���ں�Լ�ڲ�����̳к�Լ�е��á�
    // private: ����ֻ���ں�Լ�ڲ����ã��̳к�Լ��Ҳ���ܵ��á�

    function withdraw(address _to, uint256 _amount) external isOwner {
        
        if(usdt.balanceOf(address(this)) < _amount){
            revert InsufficientBalance();
        }

        if(!usdt.transfer(_to, _amount)){
            revert FailedSendToken();
        }
    }

       // ȡ��ʣ��token����ָ����ַ 
    // eth��
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

    //  ���ص�ǰ��Լ���
    function getUSDTBalance() external view returns (uint256) {
        return usdt.balanceOf(address(this)); // ��ǰ��Լ���
    }

    function getENTTBalance() external view returns (uint256) {
        return ent.balanceOf(address(this)); // ��ǰ��Լ���
    }
}
