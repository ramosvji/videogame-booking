const Migrations = artifacts.require("VideogameContract");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
