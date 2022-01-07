const MiniChefV2 = artifacts.require("MiniChefV2");
const LockPool = artifacts.require("LockPool");
const ComplexRewarderTime = artifacts.require("ComplexRewarderTime");

module.exports = async function (deployer, network, accounts) {
  if (network == 'heco') {
    await deployer.deploy(MiniChefV2,
      "0xE36FFD17B2661EB57144cEaEf942D95295E637F0" // Filda address
      );

    await deployer.deploy(LockPool);

    await deployer.deploy(ComplexRewarderTime,
        '0x', //_rewardToken
        0, // _rewardPerSecond
        MiniChefV2.address);
  }
};
