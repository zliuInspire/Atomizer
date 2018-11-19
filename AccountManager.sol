pragma solidity ^0.4.22;

// This contract implements a convenient account manager that preloads 
// a set of accounts.
contract AccountManager {
    struct Account {
        address addr;
        bool isUsed;
        uint bal;
    }
    
    Account[] public InternalAccounts;
    
    function loadAccount() payable public {
        require(!_accountExist(msg.sender));
        InternalAccounts.push(Account(msg.sender, false, msg.value));
    }
    
    function _accountExist(address _addr) public view returns(bool) {
        for (uint i = 0; i < InternalAccounts.length; i++) {
            if (InternalAccounts[i].addr == _addr) {
                return true;
            }
        }
        return false;
    }
            
    function totalAccountSize() public view returns(uint) {
        return InternalAccounts.length;
    }
    
        
    function totalAvailableAccountSize() public view returns(uint) {
        uint size = 0;
        for (uint i = 0; i < InternalAccounts.length; i++) {
            if (InternalAccounts[i].isUsed == false) {
                size++;
            }
        }
        return size;
    }
    
    function getAnAvailableAccount() public payable returns(address) {
        require(totalAvailableAccountSize() > 0);
        for (uint i = 0; i < InternalAccounts.length; i++) {
            if (InternalAccounts[i].isUsed == false) {
                InternalAccounts[i].isUsed = true;
                return InternalAccounts[i].addr;
            }
        }
    }
    
    function updateBalance(address _addr, uint _amt, bool _inc) public payable {
        assert(_accountExist(_addr));
        for (uint i = 0; i < InternalAccounts.length; i++) {
            if (InternalAccounts[i].addr == _addr) {
                if (_inc) {
                    InternalAccounts[i].bal =
                        InternalAccounts[i].bal + _amt;
                } else {
                    assert(InternalAccounts[i].bal > _amt);
                    InternalAccounts[i].bal =
                        InternalAccounts[i].bal - _amt;
                }
            }
        }
    }
    
    function recoverAccounts() public payable {
        for (uint i = 0; i < InternalAccounts.length; i++) {
            InternalAccounts[i].isUsed = false;
        }
    }
}
