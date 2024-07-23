// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
// import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 用户状态
struct userState{
    uint256 amount; // 领取数量
    bool isClaim; // 是否可领取，ture 可领，false 不可领取
}

//  添加一个白名单地址
// 修改一个白名单地址
// 删除所有白名单地址/删除某个白名单

// 给合约中转token
// 白名单，请求合约，更具白名单 发送token
// 合约中转出剩余token 给某个地址 pass

error NotOwner();
error SelectNull();

// eth 部署：	1052755 gas * 2 = 7.30
// bsc 部署：	1043308 gas
contract AirdropSelfFund{

    address public immutable i_owner;
    ERC20 token;
    mapping(address => userState) public userMap; // 白名单数组
    address[] public keys; // 删除时使用
    mapping(address => bool) private inserted; // keys去重验证
    
    // 记录转出日志
    event SendRecord(address indexed _to, uint256 _amount);
    // 记录领取日志

    constructor() {
        i_owner = msg.sender;
    }

    modifier isOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }
    
    // 白名单用户请求领取token
    // eth：  65374 gas * 2 = 0.45刀
    function claimToken() external  returns (bool){
        uint256  _amount = userMap[msg.sender].amount;

        if(userMap[msg.sender].isClaim){
        // 修改领取状态
            userMap[msg.sender].isClaim = false;
            return token.transfer( msg.sender, _amount);
        }
        revert SelectNull();
    }

    // 设置发送token地址
    // bsc 	44104 gas
    function setToken(address _token) external isOwner{
        token = ERC20(_token);
    }

    //  设置或修改一个白名单地址
    // eth： mapping // 133929gas *2 = 1刀
    function setUserMap (address _address, uint256 _amount, bool _isClaim) external isOwner{
        if(!inserted[_address]){
            keys.push(_address);
            inserted[_address] = true;
        }
        userState memory state = userState(_amount, _isClaim);
        userMap[_address] = state;
    }

    // 删除所有白名单地址 
    // eth： 44891 gas * 2 = 0.31刀
   function resetMapping() external isOwner {
        for (uint i = 0; i < keys.length; i++) {
            delete userMap[keys[i]]; //删除后地址设为0
            delete inserted[keys[i]]; // bool 为false
        }
        delete keys;

    }

    // 取出剩余token，到指定地址 
    // eth：
    function withdraw(address _to, uint256 _amount) external isOwner {
        require(
            token.balanceOf(address(this)) >= _amount,
            "Insufficient balance in contract"
        );

        require(token.transfer(_to, _amount), "Failed to send token");

        emit SendRecord(_to, _amount); // 记录转出日志
    }

    //  查询用户可领取数量及领取状态_mapping（public 自动创建）
    // function getUserState(address _address) external view returns (userState memory) {
    //     return userMap[_address]; // 当前合约余额
    // }

     // 查询用户地址
    function getUserKey() public view returns (address[] memory) {
        return keys;
    }
    
    function getUserLength() public view returns (uint256) {
        return keys.length;
    }


    // 查询合约token余额
    function getTokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this)); // 当前合约余额
    }
}



//——————————数组操作

    // address[1000] public usersArr;
    // bool[100] public userState;
    // uint256[100] public userAmountArr;

    // function writeUser (address _address, uint256 _amount, bool _isClaim) external isOwner returns (bool) {
    //     usersArr[length] = _address;
    //     userAmountArr[length] = _amount;
    //     userState[length] = _isClaim;
    //     length++;
    //     return true;
    // }

    // // 修改一个白名单地址信息
    //  function updateUser (address _address, uint256 _amount, bool _isClaim) external isOwner returns (bool) {

    //     uint256  _i;

    //     for(_i = 0; _i < length; _i++){
    //         if(usersArr[_i] == _address){
    //            userState[_i] = _isClaim; // 修改可领取状态
    //            userAmountArr[_i] = _amount;
    //            return true;
    //         }
    //     }
    //     revert SelectNull();
    // }

    
    // // 删除所有白名单地址
    // function deleteUserArr () external isOwner returns (bool) {
    //     // delete usersArr;
    //     // usersArr.length = 0;
    //     length = 0;
    //     return true;
    // }


    // // 白名单用户授权？不用授权直接转账
    // // 白名单用户请求发送token
    // function sendToken() external  returns (bool){
    //     // uint256  _amount = userMap[msg.sender].amount;
    //     // // 修改领取状态
    //     // userMap[msg.sender].isClaim = false;
    //     uint256  _i;
    //     uint256  _amount = 0;

    //     for(_i = 0; _i < length; _i++){
    //         if(usersArr[_i] == msg.sender){
    //             if(userState[_i]){
    //                  userState[_i] = false; // 修改可领取状态
    //                 _amount = userAmountArr[_i];
    //                 return token.transfer( msg.sender, _amount);
    //             }
    //         }
    //     }
    //     revert SelectNull();
    // }
    // 发送者可以调用该方法，给自己授权
    //  function sendapple() external  returns (bool){
    //     uint256  _i;
    //     uint256  _amount = 0;

    //     for(_i = 0; _i < length; _i++){
    //         if(usersArr[_i] == msg.sender){
    //             if(userState[_i]){
    //                  // 授权该账户
    //                 return token.approve(msg.sender, _amount);
    //             }
    //         }
    //     }
    //     revert SelectNull();

    //  } 



    // 查询某个用户的状态信息
    // function getUser(address _address) public view returns ( bool, uint256) {
    //     uint256  _i;
    //     bool  _isClaim = false;
    //     uint256  _amount = 0;

    //     for(_i = 0; _i < length; _i++){
            
    //         if(usersArr[_i] == _address){
    //             _isClaim = userState[_i];
    //            _amount = userAmountArr[_i];
    //         }
    //     }
    //      return (_isClaim, _amount);
    // }


// 待验证————————get方法返回数组
// 查询用户地址
    // function getUsersArr() public view returns (address[] memory) {
    //     return usersArr;
    // }
    // // 查询用户领取状态
    // function getUserState() public view returns (bool[] memory) {
    //     return userState;
    // }
    // // 查询用户领取金额
    // function getUserAmountArr() public view returns (uint256[] memory) {
    //     return userAmountArr;
    // }

    // // 返回所有用户领取状态
    // function getUsersArr() public view returns (uint256, address[] memory, bool[] memory, uint256[] memory) {
    //     return (length, usersArr, userState, userAmountArr);
    // }