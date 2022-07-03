/*
  _________      .__    _________ __          __           
 /   _____/ ____ |  |  /   _____//  |______  |  | __ ____  
 \_____  \ /  _ \|  |  \_____  \\   __\__  \ |  |/ // __ \ 
 /        (  <_> )  |__/        \|  |  / __ \|    <\  ___/ 
/_______  /\____/|____/_______  /|__| (____  /__|_ \\___  >
        \/                    \/           \/     \/    \/ ETHv1

SolStake is a simple scaffolding library for providing User Staking Data when Staking ERC20 or ETH to a Smart Contract

Yielding & Farming must be implemented seperatly

Repo & Implementation Example can be found here: https://github.com/Kwame0/SolStake

*/
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SolStakeEth is ReentrancyGuard, Ownable {

    uint256 public UNSTAKEABLE_FEE = 9200; // How much can they Unstake? 92% AKA 8% Staking FEE
    uint256 public MINIMUM_CONTRIBUTION_AMOUNT = 0.05 ether; // Minimum Amount to Stake
    bool public CONTRACT_RENOUNCED = false; // for ownerOnly Functions

    string private constant NEVER_CONTRIBUTED_ERROR = "This address has never contributed BNB to the protocol";
    string private constant NO_ETH_CONTRIBUTIONS_ERROR = "No BNB Contributions";
    string private constant MINIMUM_CONTRIBUTION_ERROR = "Contributions must be over the minimum contribution amount";
    

    struct Staker {
      address addr; // The Address of the Staker
      uint256 lifetime_contribution; // The Total Lifetime Contribution of the Staker
      uint256 contribution; // The Current Contribution of the Staker
      uint256 yield; // The Current Yield / Reward amount of the Staker
      uint256 unstakeable; // How much can the staker withdraw.
      uint256 joined; // When did the Staker start staking
      bool exists;
    }

    mapping(address => Staker) public stakers;
    address[] public stakerList;

    constructor() ReentrancyGuard() {

    }

    receive() external payable {}
    fallback() external payable {}


    function AddStakerYield(address addr, uint256 a) private {
      stakers[addr].yield = stakers[addr].yield + a;
    }

    function RemoveStakerYield(address addr, uint256 a) private {
      stakers[addr].yield = stakers[addr].yield - a;
    }

    function RenounceContract() external onlyOwner {
      CONTRACT_RENOUNCED = true;
    }

    function ChangeMinimumStakingAmount(uint256 a) external onlyOwner {
        MINIMUM_CONTRIBUTION_AMOUNT = a;
    }

    function ChangeUnstakeableFee(uint256 a) external onlyOwner {
        UNSTAKEABLE_FEE = a;
    }

    function UnstakeAll() external onlyOwner {
        if(CONTRACT_RENOUNCED == true){revert("Unable to perform this action");}
        for (uint i = 0; i < stakerList.length; i++) {
            address user = stakerList[i];
            ForceRemoveStake(user);
        }
    }

    function Stake() external nonReentrant payable {
      require(msg.value >= MINIMUM_CONTRIBUTION_AMOUNT, MINIMUM_CONTRIBUTION_ERROR);
      uint256 bnb = msg.value;
      uint256 unstakeable = (bnb * UNSTAKEABLE_FEE) / 10000;

      if(StakerExists(msg.sender)){
        stakers[msg.sender].lifetime_contribution = stakers[msg.sender].lifetime_contribution + bnb;
        stakers[msg.sender].contribution = stakers[msg.sender].contribution + unstakeable;
        stakers[msg.sender].unstakeable = stakers[msg.sender].unstakeable + unstakeable;
      }else{
        // Create new user
        Staker memory user;
        user.addr = msg.sender;
        user.contribution = unstakeable;
        user.lifetime_contribution = bnb;
        user.yield = 0;
        user.exists = true;
        user.unstakeable = unstakeable;
        user.joined = block.timestamp;
        // Add user to Stakers
        stakers[msg.sender] = user;
        stakerList.push(msg.sender);
      }

      // Staking has completed (or failed and won't reach this point)
      uint256 c = (10000 - UNSTAKEABLE_FEE);
      uint256 fee = (bnb * c) / 10000;
      // Staking fee is stored as fee, use as you wish
    }

    function RemoveStake() external {
      address user = msg.sender;
      if(!StakerExists(user)){ revert(NEVER_CONTRIBUTED_ERROR); }
      uint256 uns = stakers[user].unstakeable;
      if(uns == 0){ revert("This user has nothing to withdraw from the protocol"); }
      // Proceed to Unstake user funds from 3rd Party Yielding Farms etc

      // Remove Stake
      stakers[user].unstakeable = 0;
      stakers[user].contribution = 0;
      payable(user).transfer(uns);
    }

    function ForceRemoveStake(address user) private {
      // withdraw avAVAX for WAVAX and Unwrap WAVAX for AVAX
      if(!StakerExists(user)){ revert(NEVER_CONTRIBUTED_ERROR); }
      uint256 uns = stakers[user].unstakeable;
      if(uns == 0){ revert("This user has nothing to withdraw from the protocol"); }
      // Proceed to Unstake user funds from 3rd Party Yielding Farms etc

      // Remove Stake
      stakers[user].unstakeable = 0;
      stakers[user].contribution = 0;
      payable(user).transfer(uns);
    }

    /* 

      CONTRIBUTER GETTERS

    */

    function StakerExists(address a) public view returns(bool){
      return stakers[a].exists;
    }

    function StakerCount() public view returns(uint256){
      return stakerList.length;
    }

    function GetStakeJoinDate(address a) public view returns(uint256){
      if(!StakerExists(a)){revert(NEVER_CONTRIBUTED_ERROR);}
      return stakers[a].joined;
    }

    function GetStakerYield(address a) public view returns(uint256){
      if(!StakerExists(a)){revert(NEVER_CONTRIBUTED_ERROR);}
      return stakers[a].yield;
    }
  
    function GetStakingAmount(address a) public view returns (uint256){
      if(!StakerExists(a)){revert(NEVER_CONTRIBUTED_ERROR);}
      return stakers[a].contribution;
    }

    function GetStakerPercentageByAddress(address a) public view returns(uint256){
      if(!StakerExists(a)){revert(NEVER_CONTRIBUTED_ERROR);}
      uint256 c_total = 0;
      for (uint i = 0; i < stakerList.length; i++) {
         c_total = c_total + stakers[stakerList[i]].contribution;
      }
      if(c_total == 0){revert(NO_ETH_CONTRIBUTIONS_ERROR);}
      return (stakers[a].contribution * 10000) / c_total;
    }

    function GetStakerUnstakeableAmount(address addr) public view returns(uint256) {
      if(StakerExists(addr)){ return stakers[addr].unstakeable; }else{ return 0; }
    }

    function GetLifetimeContributionAmount(address a) public view returns (uint256){
      if(!StakerExists(a)){revert("This address has never contributed DAI to the protocol");}
      return stakers[a].lifetime_contribution;
    }

    function CheckContractRenounced() external view returns(bool){
      return CONTRACT_RENOUNCED;
    }



}
