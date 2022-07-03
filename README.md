# SolidityStake v1
## SolidityStake is a simple solidity scaffolding library for providing User Staking Data when Staking ERC20 or ETH to a Smart Contract

### Features Include

- Staking and Unstaking
- Setting a Minimum Staking Amount
- Setting a Staking Fee
- Owner Unstake all Users
- Owner Contract Renunciation
- Custom Error Messages
- Total Staker Count

- Getting User Staking Amount
- Getting User Lifetime Staking Amount
- Getting User Joindate
- Getting User Staking Percentage
- Builtin User Yield Variables

You can also easily loop through each staker (see `UnstakeAll()` function)

<b>sETH.sol (For Staking Native ETH/AVAX/BNB/MATIC etc)<br>
sTOKEN.sol (For Staking Tokens)</b>

NOTE: Requires OpenZeppelin Contracts<br>
`npm i @openzeppelin/contracts`

## Implementation Example
```solidity
contract SolStakeEth is ReentrancyGuard, Ownable {
  ...
  uint256 public fees_collected;
  ...
  function Stake() external nonReentrant payable {
    ...
    uint256 fee = (eth * 1000) / 10000;
    fees_collected = fee;
    LendToAAVEorCURVEorETC(fee);
    ...
  }
}

contract myContract is SolStakeETH {
  ...
    function FeesCollected() public view returns (uint256){
      return fees_collected;
    }
  ...
}

```

### When calling the contract via ethers.js

```javascript

await myContract.Stake({ value: ethers.utils.parseEther("1000") });
let total_fees = ethers.utils.formatEther(await myContract.FeesCollected());
let bal = ethers.utils.formatEther(await myContract.GetStakingAmount(staker.address));
console.log(bal); // 900
console.log(total_fees); // 100

```
