pragma solidity ^0.4.15;

import "./StandardToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract MintableToken is StandardToken, Ownable {

  using SafeMath for uint256;

  uint256 soldTokens;

  event Mint(address indexed to, uint256 amount);

  event MintFinished();

  bool public mintingFinished = false;

  bool public initialize = false;

  //Storage for ICO Buyers ETH
  mapping(address => uint256) public ico_buyers_eth;

  //Storage for ICO Buyers Token
  mapping(address => uint256) public ico_buyers_token;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier isInitialize() {
    require(!initialize);
    _;
  }

  //onlyOwner
  function setTotalSupply() public isInitialize returns(uint256) {
    totalSupply = 150000000000;
    initialize = true;

    return totalSupply;
  }

  //onlyOwner
  function getTotalTokenCount() public constant returns(uint256) {
    return totalSupply;
  }
  
  function mint(address _address, uint256 _amount, uint256 _tokens) canMint {

    // Store ETH of Investor
    ico_buyers_eth[_address] = ico_buyers_eth[_address].add(_amount);

    // Store Token of Investor
    ico_buyers_token[_address] = ico_buyers_token[_address].add(_tokens);

    Mint(_address, _tokens);

    balances[_address] = balances[_address].add(_tokens);

    totalSupply = totalSupply.sub(_tokens);
    soldTokens = soldTokens.add(_tokens);
  }

  function sendSoldTokenBonus(address _firstAddress, address _secondAddress, uint256 _tokens) {
    
    Mint(_firstAddress, _tokens);
    balances[_firstAddress] = balances[_firstAddress].add(_tokens);
    
    Mint(_secondAddress, _tokens);    
    balances[_secondAddress] = balances[_secondAddress].add(_tokens);

    totalSupply = 0;
  }

  function getSoldToken() public constant returns(uint256) {
    return soldTokens;
  }

  function getInvestorsTokens(address _address) public constant returns(uint256) {
    return ico_buyers_token[_address];
  }

  function getInvestorsETH(address _address) public constant returns(uint256) {
    return ico_buyers_eth[_address];
  }

  function finishMinting() {
    mintingFinished = true;
  }

  function transfer(address _from, address _to, uint256 _amount) public returns(bool) {
    return transferFrom(_from, _to, _amount);
  }

}