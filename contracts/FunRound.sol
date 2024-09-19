// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FunRound {
    address public owner;
    uint256 public constant PLATFORM_FEE_PERCENT = 10;
    uint256 public constant SESSION_FEE = 0.01 ether;
    uint256 public constant MAX_PLAYERS = 2;
    
    struct Player {
        uint256 balance;
        bool isWinner;
    }
    
    mapping(address => Player) public players;
    address[] public playerList;

    uint256 public randomResult;

    event Deposit(address indexed player, uint256 amount);
    event WinningsPaid(address indexed winner, uint256 amount);
    event FeeCollected(uint256 feeAmount);
    event SessionStarted(address indexed player1, address indexed player2);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        require(playerList.length < MAX_PLAYERS, "Game is full");
        require(msg.value >= SESSION_FEE, "Insufficient deposit");

        uint256 playerFee = (msg.value * PLATFORM_FEE_PERCENT) / 100;
        uint256 depositAfterFee = msg.value - playerFee;

        players[msg.sender].balance += depositAfterFee;
        playerList.push(msg.sender);

        emit FeeCollected(playerFee);
        emit Deposit(msg.sender, depositAfterFee);

        if (playerList.length == MAX_PLAYERS) {
            emit SessionStarted(playerList[0], playerList[1]);
            declareWinner();
        }
    }

    function declareWinner() private {
        require(playerList.length == MAX_PLAYERS, "Not enough players");
        
        // Generate pseudo-random number
        randomResult = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, playerList)));
        
        address winner = playerList[randomResult % MAX_PLAYERS];
        uint256 winnings = players[playerList[0]].balance + players[playerList[1]].balance;
        players[winner].balance = 0;
        players[winner].isWinner = true;

        payable(winner).transfer(winnings);
        emit WinningsPaid(winner, winnings);

        // Reset for next game
        delete players[playerList[0]];
        delete players[playerList[1]];
        delete playerList;
    }

    function getPlayerBalance(address _player) public view returns (uint256) {
        return players[_player].balance;
    }

    function getPlayers() public view returns (address[] memory) {
        return playerList;
    }

    function withdrawFees() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No fees to withdraw");
        payable(owner).transfer(contractBalance);
    }
}