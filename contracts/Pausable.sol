// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
import "./boring-solidity/contracts/BoringOwnable.sol";

abstract contract Pausable is BoringOwnable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account, uint256 pid);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account, uint256 pid);

    bool[] private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused(uint256 _pid) public view virtual returns (bool) {
        return _paused[_pid];
    }

    function addPause(bool _pause) internal {
        _paused.push(_pause);
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused(uint256 _pid) {
        require(!paused(_pid), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused(uint256 _pid) {
        require(paused(_pid), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause(uint256 _pid) public virtual whenNotPaused(_pid) onlyOwner {
        _paused[_pid] = true;
        emit Paused(msg.sender, _pid);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause(uint256 _pid) public virtual whenPaused(_pid) onlyOwner {
        _paused[_pid] = false;
        emit Unpaused(msg.sender, _pid);
    }
}
