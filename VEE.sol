pragma solidity ^0.4.22;

import "./AccountManager.sol";
import "./Atomizer.sol";
import "./BIP.sol";
import "./Gateway.sol";

contract VEE is AccountManager, BIP {
    // Internal bookkeeping of Ops managed by the VEE.
    mapping (uint => Operation) public managedOps;

    // Initialize Atomizer and Gateway given their addresses. 
    Atomizer public atomizer_;
    Gateway public gateway_;
    function initialize(address _atomizer, address _gateway) public payable {
        atomizer_ = Atomizer(_atomizer);
        gateway_ = Gateway(_gateway);
    }
    
    // Session setup for a MultiPartyExchange. 
    // TODO: specify the exchange intent as an argument instead of using the 
    //       mocked intent below.
    function multiPartyExchangeSetup(
        string _sessionName, uint _partyNum) public payable {
        mockTxIntent(_sessionName, _partyNum);
    }
    
    function eligibleTrans(string _sessionName) public payable {
        uint sessionId = getUuid(_sessionName);
        Operation storage Op = managedOps[sessionId];
        assert(Op.initialized == true);
        TxIntent[] storage intents = Op.intents;
        while (Op.graph_layer <= Op.graph_size) {
            for (uint i = 0; i < intents.length; i++) {
                TxIntent storage intent = intents[i];
                // Execute an eligible Tx, which is emulated by balance
                // update on gateway_ and atomizer_.
                if (intent.layer == Op.graph_layer) {
                    if (intent.northbound) {
                        gateway_.onExecute(
                            intent.from_addr, intent.to_addr, intent.amt);
                    } else {
                        atomizer_.onExecute(
                            intent.from_addr, intent.to_addr, intent.amt);
                    }
                    intent.finalized = true;
                }
            }
            // Increment the layer after previous layer is finished.
            Op.graph_layer = Op.graph_layer + 1;
        }
    }
     
    function mockTxIntent(string _sessionName, uint _partyNum) internal {
        uint sessionId = getUuid(_sessionName);
        Operation storage Op = managedOps[sessionId];
        require(Op.initialized == false);
        Op.initialized = true;
        Op.graph_layer = 1;
        TxIntent[] storage intents = Op.intents;
        
        // require(_partyNum >= 2);
        require(totalAvailableAccountSize() >= 2 * _partyNum);
        // Assume a constant for balance update between an account pair.
        uint kBalanceUpdate = 10;
        
        // For each party, VEE uses its gateway account on the party's blockchain
        // to send to or receive funds from the party. For simplicity, we
        // assume that the first half of the parties are sending funds whereas
        // the second half of the parties are receing funds. Thus the second
        // half of transactions depend on the first layer of transactions.
        for (uint i = 0; i < _partyNum; i++) {
            address party_addr = getAnAvailableAccount();
            address gateway_addr = getAnAvailableAccount();
            assert(party_addr != gateway_addr);
            // A party sending fund to gateway.
            if (i < _partyNum / 2) {
                intents.push(
                    TxIntent(
                        /*finalized*/false, 
                        party_addr, 
                        gateway_addr, 
                        kBalanceUpdate, 
                        /*layer*/1, /*northbound*/false));
            } else {
                intents.push(
                    TxIntent(
                        /*finalized*/false, 
                        gateway_addr, 
                        party_addr, 
                        kBalanceUpdate,
                        /*layer*/2, /*northbound*/true));
            }
        }
        Op.graph_size = intents.length;
    }
}
