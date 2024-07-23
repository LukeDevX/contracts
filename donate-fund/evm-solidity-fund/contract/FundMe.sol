//允许任何用户向这个合约里捐款
//允许合约部署者把用户捐的款给提走
//可以看到每个用户捐了多少
//设定一个最小金额，小于这个金额(5eu)，则捐款不成功

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 合约外部定义错误，避免字符串写道区块链上，节省 gas 之差 //32,399 gas ——> 0.19U
error NotOwner();

contract FundMe {
    //fund
    //函数加了payable修饰符就是指可以往里面存款

    // constant 在定义的时候就初始化，其他任何地方都不能再赋值。
    // 一个变量部署 869737 gas ——> 843961 gas  节省【25,776 gas】 0.15U

    // immutable 只允许初始化（赋值）一次，并允许在构建函数中再做初始化。
    // 部署之差：26393 gas 【0.15 U】，查看 owner 2,135 gas 【0.01U】

    AggregatorV3Interface internal priceFeed;
    address public  i_owner;
    uint256 minimumUsD;
    bool isIdo;

    mapping(address => uint256) public idoMap;

    constructor() {
        priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        i_owner = msg.sender;
        isIdo = true;
        minimumUsD = 100;
    }

    modifier isOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        // require(msg.sender == i_owner, "Caller is not owner");
        _;
    }

    //如何限制捐款的金额大于等于固定的U的数值 比如说最小捐180U 225241 gas 154400 gas
	// payable 发送 eth
    function Fund() public payable {
        require(isIdo, "ido close");
        require(ethToUsd(msg.value) > minimumUsD, "must greater than 1e!");

        idoMap[msg.sender] += msg.value;
    } //1eth=10**18 wei =1**9 Gwei =1e18 后面没加单位时候默认单位是wei

    // 直接往合约中转账时触发
    receive() external payable {
        Fund();
    }
    // 转账时携带数据时触发
    fallback() external payable {
        Fund();
    }

    // 取出eth到部署者合约
    function withdraw() public isOwner {
        //transfer 2300 gas
        // payable(msg.sender).transfer(address(this).balance);

        //send 2300 gas
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"transaction failed");

        // call 不限制gas // 200000 gas
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "transaction failed");
    }

    function idoClose() public isOwner {
        isIdo = false;
    }

    function idoOpen() public isOwner {
        isIdo = true;
    }

    // 获得具体价格 eth/usd
    function getLatestPrice() internal view returns (uint256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/
            ,
            ,

        ) = /*uint timeStamp*/
            /*uint80 answeredInRound*/
            priceFeed.latestRoundData();

        return uint256(price);
    }

    //  eth转换为美元
    // 1 eth = 2984
    // 1000000000000000000 ，1e18，输出2984
    function ethToUsd(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethprice = getLatestPrice(); // 298481481961/1e8  12位；    ethAmout：1/1e18
        uint256 ethInUsd = (ethprice * ethAmount) / 1e26;

        return ethInUsd;
    }
}
