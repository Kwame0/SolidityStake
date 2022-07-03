# SolStake v1
## SolStake is a simple solidity scaffolding library for providing User Staking Data when Staking ERC20 or ETH to a Smart Contract

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
  uint256 public eth_staked;
  ...
  function Stake() external nonReentrant payable {
    ...
    uint256 fee = (eth * 1000) / 10000;
    eth_staked = fee;
    LendToAAVEorCURVEorETC(fee);
    ...
  }
}

contract myContract is SolStakeETH {
  ...
    function EthStaked() public view returns (uint256){
      return eth_staked;
    }
  ...
}

```

### When calling the contract via ethers.js

```javascript

await myContract.Stake({ value: ethers.utils.parseEther("1000") });
let bal = ethers.utils.formatEther(await myContract.EthStaked());
console.log(bal); // 100

```
