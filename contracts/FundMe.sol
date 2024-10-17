//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 1. 创建一个收款函数   
// 2. 记录投资人并且查看 
// 3. 在锁定期内，达到目标值，生产商可以提款
// 4. 在锁定期内, 没有达到目标值，投资人在锁定期后可以退款

contract FundMe {
    mapping(address => uint256) public fundersToAmount;

    uint256 constant MINIMUM_VALUE = 1 * 10 ** 18; //USD

    AggregatorV3Interface internal dataFeed;

    uint256 constant target = 5 * 10 ** 18;

    address public owner;
    
    uint256 deploymentTimestamp;

    uint256 lockTime;

    address public erc20Addr;

    bool public getFundSuccess = false;

    constructor(uint256 _lockTime) {
        //
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
    }


    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "Send more ETH");
        require(block.timestamp < deploymentTimestamp + lockTime,"window is closed");
        require(block.timestamp > deploymentTimestamp,"window is not begin");
        fundersToAmount[msg.sender] =msg.value;
        
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount) internal view returns(uint256){
        uint256 ethPrice = uint(getChainlinkDataFeedLatestAnswer());
        return ethAmount * ethPrice / (10 ** 8);
         
    }


    function transferOwnership(address newOwner) public onlyOwner {                                                                                                                                      
        owner = newOwner;
    }


    function getFund() external windowClosed onlyOwner{
        require(convertEthToUsd(address(this).balance) >= target,"target is not reached");
        
        //payable(msg.sender).transfer(address(this).balance);
        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "tansfer tx failed");
        //  require(success,"tx false");
        // addr.call("")
        getFundSuccess = true;
    }   


    function refund() external windowClosed {
        require(convertEthToUsd(address(this).balance) < target, "target is reached");  
        require(fundersToAmount[msg.sender] != 0,"there is no fund for you");
        bool success;
        (success, ) = payable(msg.sender).call{value: fundersToAmount[msg.sender]}("");
        require(success, "tansfer tx failed");
        fundersToAmount[msg.sender] = 0;
    }

    function test() public view returns (uint[] memory) {
        uint[] memory dynamicArray = new uint[](2);
        dynamicArray[0] = fundersToAmount[msg.sender];
        dynamicArray[1] = convertEthToUsd(address(this).balance);
        return dynamicArray;
    }

    modifier windowClosed() {
        require(block.timestamp >= deploymentTimestamp + lockTime,"window is not closed");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"this function can only be called by owner");
        _;
    }
    
    function setFunderToAmount(address funder, uint256 amountToUpdate) external {
        require(msg.sender == erc20Addr,"you do not have permission to call this function ");
        fundersToAmount[funder] = amountToUpdate;
    }

    function setErc20Addr(address _erc20Addr) public {
        erc20Addr = _erc20Addr;
    }

}