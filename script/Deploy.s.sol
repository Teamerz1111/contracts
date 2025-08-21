// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ChainSageCore.sol";
import "../src/RiskDetector.sol";
import "../src/WatchlistManager.sol";

/**
 * @title Deploy Script
 * @dev Script to deploy ChainSage contracts
 * @author ChainSage Team
 */
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        ChainSageCore core = new ChainSageCore();
        console.log("ChainSage Core deployed at:", address(core));

        RiskDetector riskDetector = new RiskDetector();
        console.log("Risk Detector deployed at:", address(riskDetector));

        WatchlistManager watchlistManager = new WatchlistManager();
        console.log(
            "Watchlist Manager deployed at:",
            address(watchlistManager)
        );

        core.grantRole(keccak256("RISK_ANALYST_ROLE"), address(riskDetector));
        core.grantRole(keccak256("USER_ROLE"), address(watchlistManager));

        vm.stopBroadcast();

        console.log("Deployment completed successfully!");
        console.log("Deployer:", deployer);
    }
}
