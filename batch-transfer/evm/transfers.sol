/**
 *Submitted for verification at BscScan.com on 2024-07-17
*/

// File: contracts/3/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// File: contracts/3/BatchTransfer.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;


interface IERC20 {
    function transfer(address recipient, uint256 amount) external;

    function balanceOf(address owner) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;
}

contract BatchTransfer is Ownable {
    uint256 public fee = 20000000;

    modifier collectFee() {
        require(msg.value >= fee, "Insufficient fee provided");
        _;
    }

    // 设置手续费方法
    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    // Batch transfer Ether
    function batchTransferEther(
        address payable[] calldata recipients,
        uint256[] calldata amounts
    ) external payable collectFee {
        uint256 length = recipients.length;
        require(
            length == amounts.length,
            "Recipients and amounts arrays must have the same length"
        );

        uint256 totalTokens = 0;
        for (uint256 i = 0; i < length; i++) {
            totalTokens += amounts[i];
            recipients[i].transfer(amounts[i]);
        }
        require(totalTokens >= msg.value - fee, "msg.value - fee != amounts");

    }

    // Batch transfer ERC20 tokens
    function batchTransferToken(
        IERC20 token,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external payable collectFee {
        uint256 length = recipients.length;
        require(
            length == amounts.length,
            "Recipients and amounts arrays must have the same length"
        );

        for (uint256 i = 0; i < length; i++) {
            token.transferFrom(msg.sender, recipients[i], amounts[i]);
        }

    }

    // 提取合约中存储的原生代币
    function withdrawNativeToken() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No native tokens to withdraw");
        payable(msg.sender).transfer(balance);
    }

    // 提取合约中存储的ERC20代币
    function withdrawERC20Token(IERC20 token) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No ERC20 tokens to withdraw");
        token.transfer(msg.sender, balance);
    }
}