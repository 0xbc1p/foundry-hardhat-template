// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../src/Token.sol";

contract TokenTest is Test {
    Token token;
    address owner = address(111111111);
    address member1 = address(222);
    address member2 = address(333);
    address user = address(444);

    IUniswapV2Router02 realRouter =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    string RPC_URL = "https://rpc.ankr.com/eth";
    uint256 mainnetFork;

    function setUp() public {
        mainnetFork = vm.createFork(RPC_URL);
        vm.selectFork(mainnetFork);
        vm.deal(owner, 100 ether);
        vm.deal(member1, 10 ether);
        vm.deal(member2, 10 ether);
        vm.deal(user, 10 ether);
        vm.startPrank(owner);
        token = new Token();
        vm.stopPrank();
    }

    function test_Swap() public {
        vm.startPrank(owner);
        token.approve(address(realRouter), type(uint256).max);

        realRouter.addLiquidityETH{value: 1.5 ether}(
            address(token),
            token.balanceOf(owner),
            0,
            0,
            owner,
            block.timestamp
        );

        token.enableTrading();

        vm.stopPrank();
        vm.startPrank(user);

        address[] memory path = new address[](2);

        path[0] = realRouter.WETH();
        path[1] = address(token);

        address[] memory pathSell = new address[](2);

        pathSell[0] = address(token);
        pathSell[1] = realRouter.WETH();

        for (uint i = 0; i < 5; i++) {
            realRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: 0.005 ether
            }(0, path, user, block.timestamp);

            token.approve(address(realRouter), type(uint256).max);

            realRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                token.balanceOf(user),
                0,
                pathSell,
                user,
                block.timestamp
            );
        }
    }
}
