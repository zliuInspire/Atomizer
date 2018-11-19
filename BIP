pragma solidity ^0.4.22;

// This is base contract of BIP, defining common data structures and utilities
contract BIP {
    // Transaction intent. The layer specifies the topological order of the 
    // intent in a dependency graph. A northbound Tx is from VEE to Atomizer.
    struct TxIntent {
        bool finalized;
        address from_addr;
        address to_addr;
        uint amt;
        uint layer;
        bool northbound;
    }
    
    // The data structure of an inter-chain operation.
    // The graph_layer specifies the current layer of transaction intents that 
    // are eligble to be opened. 
    struct Operation {
        bool initialized;
        TxIntent[] intents;
        uint graph_layer;
        uint graph_size;
    }
    
    // The data structure a MultiPartyExchange intent, where all involved 
    // user accounts and balance changes are specified.
    struct BalanceUpdate{
        address addr;
        uint value;
        bool increase;
    }
    struct MultiPartyExchange {
        BalanceUpdate[] exchanges;
    }
    
    // SwapExchange between two users crossing two blockchains
    // 1. User A has two accounts A_1 and A_2 on blokchain C_1 and C_2
    // 2. User B has two accounts B_1 and B_2 on blokchain C_1 and C_2
    // 3. The SwapExchange is making A_1's balance 
    struct SwapExchange {
        address addr;
    }
    
    function getUuid(string _str) public pure returns(uint) {
        return uint(keccak256(abi.encodePacked(_str)));
    }
}
