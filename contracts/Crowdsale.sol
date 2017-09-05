pragma solidity ^0.4.15;

// ---------ALERT---------
// Before deploy to Main Net uncomment all *ADDRESSES FOR PRODUCTION* comment 
// Before deploy to Main Net change rinkeby.etherscan.io to etherscan.io 
// Before deploy to Main Net check all ICO dates in all .sol files
// Before deploy to Main Net check all Comment in .sol and .js files
// Before deploy to Main Net check all code area with '* 100' & '/ 100' for .js files

import "./Ownable.sol";
import "./SafeMath.sol";
import "./SingleTokenCoin.sol";
import "./Addresses.sol";

contract Crowdsale is Ownable {

    using SafeMath for uint256;

    SingleTokenCoin public token = new SingleTokenCoin();

    Addresses addresses = new Addresses();

    uint256 ico_start;
    uint256 ico_finish;

    uint256 rate;

    uint256 decimals;

    address ownerContract;

    //Time-based Bonus Program
    uint256 firstBonusPhase;
    uint256 firstExtraBonus;

    uint256 secondBonusPhase;
    uint256 secondExtraBonus;

    uint256 thirdBonusPhase;
    uint256 thirdExtraBonus;

    //Volume-Based Bonus Program
    uint256 zeroExtraVolume;
    
    uint256 firstExtraVolume;
    uint256 firstVolumeBonus;

    uint256 secondExtraVolume;
    uint256 secondVolumeBonus;
        
    uint256 thirdExtraVolume;
    uint256 thirdVolumeBonus;

    uint256 fourExtraVolume;
    uint256 fourVolumeBonus;
    
    uint256 fiveVolumeBonus;

    uint256 totalETH;

    mapping(address => bytes32) privilegedWallets;
    mapping(address => uint256) manualAddresses;

    address[] manualAddressesCount;

    address[] privilegedWalletsCount;

    bytes32 g = "granted";

    bytes32 r = "revorked";

    event ShowInfo(uint256 _info);

    function Crowdsale() {

      rate = 100000000000000; //0.0001 ETH

      decimals = 1000000000000; // 0.0000001 ETH // 2 decimals

      //11.09.2017 07:00 UTC (1505113200)
      ico_start = 1504497270;

      //29.09.2017 23:59 UTC
      ico_finish = 1506729540;

      ownerContract = msg.sender;

      token.setTotalSupply();

      //Time-Based Bonus Phase
      firstBonusPhase = ico_start.add(24 hours);
      firstExtraBonus = 15;

      secondBonusPhase = ico_start.add(48 hours);
      secondExtraBonus = 10;

      thirdBonusPhase = ico_start.add(72 hours);
      thirdExtraBonus = 5;

      //Volume-Based Bonus Phase
      zeroExtraVolume = 30000000000000000000;
      
      firstExtraVolume = 50000000000000000000;
      firstVolumeBonus = 10;

      secondExtraVolume = 100000000000000000000;
      secondVolumeBonus = 15;

      thirdExtraVolume = 300000000000000000000;
      thirdVolumeBonus = 20;

      fourExtraVolume = 1000000000000000000000;
      fourVolumeBonus = 25;

      fiveVolumeBonus = 30;

      totalETH = 0;

      privilegedWalletsCount.push(msg.sender);
      privilegedWallets[msg.sender] = g;
    }

    function() external payable {
      mint();
    }

    modifier calculateRate() {
      uint256 tokens = token.getSoldToken();

      //rate 0,0001*1,03 ETH
      if (tokens >= 500000000 && tokens < 600000000) {
        rate = 103000000000000;
      }

      //rate 0,0001*1,03^2 ETH
      if (tokens >= 600000000 && tokens < 700000000) {
        rate = 106090000000000;
      }

      //rate 0,0001*1,03^3 ETH
      if (tokens >= 700000000 && tokens < 800000000) {
        rate = 109272700000000;
      }

      //rate 0,0001*1,03^4 ETH
      if (tokens >= 800000000 && tokens < 900000000) {
        rate = 112550881000000;
      }

      //rate 0,0001*1,03^5 ETH
      if (tokens >= 900000000 && tokens < 1000000000) {
        rate = 115927407430000;
      }

      //rate 0,0001*1,03^6 ETH
      if (tokens >= 1000000000 && tokens < 1100000000) {
        rate = 119405229653000;
      }

      //rate 0,0001*1,03^7 ETH
      if (tokens >= 1100000000 && tokens < 1200000000) {
        rate = 122987386542000;
      }

      //rate 0,0001*1,03^8 ETH
      if (tokens >= 1200000000 && tokens < 1300000000) {
        rate = 122667700813900;
      }

      //rate 0,0001*1,03^9 ETH
      if (tokens >= 1300000000 && tokens < 1400000000) {
        rate = 130477318383000;
      }

      //rate 0,0001*1,03^10 ETH
      if (tokens >= 1400000000) {
        rate = 134391637934000;
      }
      _;

    }

    modifier isRefund() {
      if (msg.value < decimals) {
        refund(msg.value);
        revert();
      }
      _;
    }

    function grantedWallets(address _address) returns(bool) {
      if (privilegedWallets[_address] == g) {
        return true;
      }
      return false;
    }

    modifier isICOFinished() {
      if (now > ico_finish) {
        finishMinting();
        refund(msg.value);
        revert();
      }
      _;
    }

    function getTokens() public constant returns(uint256) {
      token.getTotalTokenCount();
    }

    function setPrivlegedWallet(address _address) public onlyOwner returns(bool) {
      if (privilegedWalletsCount.length == 2) {
        revert();
      }

      if (privilegedWallets[_address] != g && privilegedWallets[_address] != r) {
        privilegedWalletsCount.push(_address);
      }

      privilegedWallets[_address] = g;

      return true;
    }

    function removePrivlegedWallet(address _address) public onlyOwner {
      if (privilegedWallets[_address] == g) {
        privilegedWallets[_address] = r;
        delete privilegedWalletsCount[0];
      } else {
        revert();
      }
    }

    //only for demonstrate Test Version
    function setICODate(uint256 _time) public onlyOwner {
      ico_start = _time;
      ShowInfo(_time);
    }

    function getICODate() public constant returns(uint256) {
      return ico_start;
    }

    function mint() isRefund isICOFinished calculateRate payable {

      uint256 remainder = msg.value.mod(decimals);

      uint256 eth = msg.value.sub(remainder);

      if (remainder != 0) {
        refund(remainder);
      }

      sendToOwners(eth);

      totalETH = totalETH + eth;

      uint currentRate = rate / 100; //2 decimals

      uint256 tokens = eth.div(currentRate);
      uint256 timeBonus = calculateBonusForHours(tokens);
      uint256 volumeBonus = calculateBonusForETH(tokens);

      uint256 allTokens = (tokens.add(timeBonus)).add(volumeBonus);

      token.mint(msg.sender, eth, tokens);
    }

    function sendToAddress(address _address, uint256 _tokens) {

      if (grantedWallets(msg.sender) == false) {
        revert();      
      }

      ShowInfo(_tokens);

      uint256 currentTokens = _tokens;

      uint256 timeBonus = calculateBonusForHours(currentTokens);
      uint256 volumeBonus = calculateBonusForETH(currentTokens);

      uint256 allTokens = (currentTokens.add(timeBonus)).add(volumeBonus);

      if(manualAddresses[_address] == 0) {
        manualAddressesCount.push(_address);
      }

      manualAddresses[_address] = manualAddresses[_address].add(allTokens);      

      token.mint(_address, 0, allTokens);
    }

    function getManualByAddress(address _address) constant returns(uint256) {
      return manualAddresses[_address];
    }

    function getManualInvestorsCount() constant returns(uint256) {
      return manualAddressesCount.length;
    }

    function getManualAddress(uint _index) constant returns(address) {
      return manualAddressesCount[_index];
    }

    function finishMinting() public onlyOwner {
      if (token.mintingFinished()) {
        revert();
      }
      token.finishMinting();
      sendSoldTokenBonus();
    }

    function refund(uint256 _amount) {
      msg.sender.transfer(_amount);
    }

    function calculateBonusForHours(uint256 _tokens) returns(uint256) {

      //Calculate for first bonus program
      if (now >= ico_start && now <= firstBonusPhase ) {
        return _tokens.mul(firstExtraBonus).div(100);
      }

      //Calculate for second bonus program
      if (now > firstBonusPhase && now <= secondBonusPhase ) {
        return _tokens.mul(secondExtraBonus).div(100);
      }

      //Calculate for third bonus program
      if (now > secondBonusPhase && now <= thirdBonusPhase ) {
        return _tokens.mul(thirdExtraBonus).div(100);
      }

      return 0;
    }

    function calculateBonusForETH(uint256 _tokens) returns(uint256) {
      uint256 oldInvestorsETH = token.getInvestorsETH(msg.sender);
      uint256 investorsETH = oldInvestorsETH.add(msg.value);

      //Calculate for first bonus program
      if (investorsETH >= zeroExtraVolume && investorsETH <= firstExtraVolume) {
        return _tokens.mul(firstVolumeBonus).div(100);
      }

      //Calculate for second bonus program
      if (investorsETH > firstExtraVolume && investorsETH <= secondExtraVolume) {
        return _tokens.mul(secondVolumeBonus).div(100);
      }

      //Calculate for third bonus program
      if (investorsETH > secondExtraVolume && investorsETH <= thirdExtraVolume) {
        return _tokens.mul(thirdVolumeBonus).div(100);
      }

      //Calculate for four bonus program
      if (investorsETH > thirdExtraVolume && investorsETH <= fourExtraVolume) {
        return _tokens.mul(fourVolumeBonus).div(100);
      }

      //Calculate for five bonus program
      if (investorsETH > fourExtraVolume) {
        return _tokens.mul(fiveVolumeBonus).div(100);
      }

      return 0;
    }

    function sendSoldTokenBonus() {
      uint256 soldTokens = token.getSoldToken();

      uint256 bonusTokens = soldTokens.mul(10).div(100);

      // ----------ADDRESSES FOR PRODUCTION-------------
      token.sendSoldTokenBonus(addresses.soldTokenAddressOne(), addresses.soldTokenAddressTwo(), bonusTokens);
    }

    function sendToOwners(uint256 _amount) {
      uint256 ninePercent = _amount.mul(9).div(100);
      uint256 sixPercent = _amount.mul(6).div(100);
      uint256 fivePercent = _amount.mul(5).div(100);
      uint256 twoPercent = _amount.mul(2).div(100);

// ----------ADDRESSES FOR PRODUCTION-------------

/*
      //Nine Percent
      addresses.addr1().transfer(ninePercent);
      addresses.addr2().transfer(ninePercent);
      addresses.addr3().transfer(ninePercent);
      addresses.addr5().transfer(ninePercent);
      addresses.addr6().transfer(ninePercent);
      addresses.addr7().transfer(ninePercent);
      addresses.addr8().transfer(ninePercent);
      addresses.addr9().transfer(ninePercent);
      addresses.addr10().transfer(ninePercent);

      //Six Percent
      addresses.addr4().transfer(sixPercent);*/
      
      //Five Percent
      addresses.successFee().transfer(fivePercent);
      
      //Two Percent
      addresses.bounty().transfer(twoPercent);
     /* addresses.addr11().transfer(twoPercent);
      addresses.addr12().transfer(twoPercent);
      addresses.addr13().transfer(twoPercent); */
      
    }

    function getInvestorsTokens(address _address) public constant returns(uint256) {
      return token.getInvestorsTokens(_address);
    }

    function getBalanceContract() public constant returns(uint256) {
      return this.balance;
    }

    function getBalanceInvestor() public constant returns(uint256) {
      return msg.sender.balance;
    }

    function getSoldToken() public constant returns(uint256) {
      return token.getSoldToken();
    }

    function getLeftToken() public constant returns(uint256) {
      return token.totalSupply();
    }

    function getTotalETH() public constant returns(uint256) {
      return totalETH;
    }

    function getCurrentPrice() public calculateRate constant returns(uint256) {
      
      uint256 firstDiscount = calculateBonusForETH(rate);

      uint256 secondDiscount = calculateBonusForHours(rate);

      uint256 investorDiscount = rate.sub(firstDiscount).sub(secondDiscount);

      return investorDiscount;
    }

    function getContractAddress() public constant returns(address) {
      return this;
    }

    function transfer(address _from, address _to, uint256 _amount) public returns(bool) {
      return token.transfer(_from, _to, _amount);
    }

}
