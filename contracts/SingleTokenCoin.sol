pragma solidity ^0.4.15;

import "./MintableToken.sol";

contract SingleTokenCoin is MintableToken {
    
    string public constant name = "GMC";
    
    string public constant symbol = "GMC";
    
    uint32 public constant decimals = 2;
    
}