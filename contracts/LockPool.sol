// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./boring-solidity/contracts/BoringOwnable.sol";
import "./boring-solidity/libraries/BoringMath.sol";
import "./boring-solidity/libraries/BoringERC20.sol";

contract LockPool is BoringOwnable {
    using BoringMath for uint256;
    using BoringERC20 for IERC20;

    IERC20 public lpToken;
    uint256 public withdrawPeriod = 72 hours;
    address public rewardPool;

    event WithdrawPeriodChanged(uint256 indexed period);

    struct WithDrawEntity {
        uint256 amount;
        uint256 time;
    }

    mapping (address => WithDrawEntity) private withdrawEntities;

    modifier onlyRewardPool() {
        require(msg.sender == rewardPool, "Not reward pool");
        _;
    }

    function setRewardPool(address _pool, address _lpToken) external onlyOwner {
        require(_pool != address(0) && _lpToken != address(0), "reward pool and token address shouldn't be empty");
        rewardPool = _pool;
        lpToken = IERC20(_lpToken);
    }

    function setWithdrawPeriod(uint256 _withdrawPeriod) external onlyOwner {
        withdrawPeriod = _withdrawPeriod;
        emit WithdrawPeriodChanged(_withdrawPeriod);
    }

    function lock(address account, uint256 amount) external onlyRewardPool {
        withdrawEntities[account].amount = withdrawEntities[account].amount.add(amount);
        withdrawEntities[account].time = block.timestamp;
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(address account, uint256 amount) external onlyRewardPool {
        _withdraw(account, amount);
    }

    function withdrawBySender(uint256 amount) public {
        _withdraw(msg.sender, amount);
    }

    function _withdraw(address account, uint256 amount) private {
        require(withdrawEntities[account].amount > 0 && withdrawEntities[account].time > 0, "not applied!");
        require(block.timestamp >= withdrawTime(account), "It's not time to withdraw");
        if (amount > withdrawEntities[account].amount) {
            amount = withdrawEntities[account].amount;
        }
        withdrawEntities[account].amount = withdrawEntities[account].amount.sub(amount);
        if (withdrawEntities[account].amount == 0) {
            withdrawEntities[account].time = 0;
        }

        lpToken.safeTransfer(account, amount);
    }

    function lockedBalance(address account) external view returns (uint256) {
        return withdrawEntities[account].amount;
    }

    function withdrawTime(address account) public view returns (uint256) {
        return withdrawEntities[account].time == 0 ? 0 : withdrawEntities[account].time + withdrawPeriod;
    }

}
