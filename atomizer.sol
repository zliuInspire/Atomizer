pragma solidity ^0.4.22;

import "./AccountManager.sol";

contract Atomizer is AccountManager{
    // Transaction emulation.
    function onExecute(address _from, address _to, uint _amt) public {
        updateBalance(_from, _amt, /*inc*/false);
        updateBalance(_to, _amt, /*inc*/true);
    }
}
