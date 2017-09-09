var Crowdsale = artifacts.require("./Crowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(Crowdsale, {from: web3.eth.accounts[0], gaslimit: 9000000});
};
