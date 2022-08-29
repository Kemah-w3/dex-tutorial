//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address cryptoDevTokenAddress;

    constructor(address _cryptoDevContract) ERC20("CryptoDev LP Token", "CDLP") {
        require(_cryptoDevContract != address(0), "The address is a null address!");
        cryptoDevTokenAddress = _cryptoDevContract;
    }

    function getReserve() public view returns(uint) {
        uint tokenBalance = ERC20(cryptoDevTokenAddress).balanceOf(address(this));
        return tokenBalance;
    }

    function addLiquidity(uint _amount) public payable returns(uint) {
        uint liquidity;
        uint ethBalance = address(this).balance;
        uint cryptoDevTokenReserve = getReserve();
        ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);

        if(cryptoDevTokenReserve == 0) {
            cryptoDevToken.transferFrom(msg.sender, address(this), _amount);
            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            //get current ETH reserve before the function call 
            uint ethReserve = ethBalance - msg.value;

            //formula to get the amount of cryptoDev token required
            uint cryptoDevTokenAmount = (msg.value * cryptoDevTokenReserve)/ethReserve;

            require(_amount >= cryptoDevTokenAmount, "The amount is not up to the required minimum!");
            cryptoDevToken.transferFrom(msg.sender, address(this), cryptoDevTokenAmount);

            //formular to get the amount of LP tokens to be minted
            liquidity = (totalSupply() * msg.value)/ethReserve;
            _mint(msg.sender, liquidity);
        }

        return liquidity;
    }

    function removeLiquidity(uint _amount) public returns(uint, uint) {
        require(_amount > 0, "Amount must be greater than 0!");
        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();
        uint cryptoDevTokenReserve = getReserve();
        ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);

        //formular to get amount of ETH to be returned to the user
        uint ethAmount = (ethReserve * _amount)/_totalSupply;

        //formular to get the amount of cryptoDev token to be returned to the user
        uint cryptoDevTokenAmount = (cryptoDevTokenReserve * _amount)/_totalSupply;
        
        //burn LP token sent from user's wallet 
        _burn(msg.sender, _amount);
        //transfer from user's wallet to the contract
        payable(msg.sender).transfer(ethAmount);
        cryptoDevToken.transfer(msg.sender, cryptoDevTokenAmount);
        return (ethAmount,cryptoDevTokenAmount);
    }

    function getAmountOfTokens(
        uint inputAmount,
        uint inputReserve,
        uint outputReserve
    ) public pure returns(uint) {
        require(inputReserve > 0 && outputReserve > 0, "Invalid Reserve");
        uint inputAmountWithFees = inputAmount * 99;

        uint numerator = inputAmountWithFees * outputReserve;
        uint denominator =  (inputReserve + 100) * inputAmountWithFees;
        return(numerator/denominator);
    }

    function ethToCryptoDevToken(uint _minToken) public payable {
        uint tokenReserve = getReserve();

        uint tokensBought =  getAmountOfTokens(
            msg.value, 
            address(this).balance - msg.value, 
            tokenReserve
        ); 

        require(tokensBought >= _minToken, "Insufficient output amount");
        ERC20(cryptoDevTokenAddress).transfer(msg.sender, tokensBought);
    }

    function cryptoDevTokenToEth(uint _tokenSold, uint _minEth) public payable {
        uint tokenReserve = getReserve();

        uint ethBought = getAmountOfTokens(
            _tokenSold, 
            tokenReserve, 
            address(this).balance
        );

        require(ethBought >= _minEth, "Insufficient output amount!");
        ERC20(cryptoDevTokenAddress).transferFrom(msg.sender, address(this), _tokenSold);
        payable(msg.sender).transfer(ethBought);
    }

}