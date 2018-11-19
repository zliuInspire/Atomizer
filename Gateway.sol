pragma solidity ^0.4.22;

import "./AccountManager.sol";

// This contract specifies the gateway account maintained by a VEE.
// A gateway lives on one blockchain network, and handles all VEE's transactions
// on that blockchain. 
contract Gateway is AccountManager {
    // Transaction emulation.
    function onExecute(address _from, address _to, uint _amt) public {
        updateBalance(_from, _amt, /*inc*/false);
        updateBalance(_to, _amt, /*inc*/true);
    }
}
