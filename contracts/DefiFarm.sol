// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DefiFarm is Ownable {
    struct User {
        address addr;
        mapping(address => uint256) token2Balance;
        address[] stakingTokens;
    }

    User[] public users;
    address[] public allowedTokens;
    mapping(address => address) public token2PriceFeed;
    IERC20 dappToken;

    constructor(address _dappToken) {
        dappToken = IERC20(_dappToken);
    }

    function stake(address _token, uint256 _amount) public {
        require(_token != address(0) && _amount > 0);
        require(
            isTokenAllowed(_token),
            "This token is not spport by our service!"
        );
        // sendFrom
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        // update user balance & add this user to list user
        (bool isExist, uint256 index) = findUser(msg.sender);

        if (isExist) {
            User storage user = users[index];
            user.token2Balance[_token] += _amount;
            addToken2ListTokenOfUser(_token, user);
        } else {
            User storage user = users.push();
            user.addr = msg.sender;
            user.token2Balance[_token] += _amount;
            addToken2ListTokenOfUser(_token, user);
        }
    }

    function getBalance(uint256 index, address _token)
        public
        view
        returns (uint256)
    {
        return users[index].token2Balance[_token];
    }

    function issueToken() public onlyOwner {
        for (uint256 index = 0; index < users.length; index++) {
            User storage user = users[index];
            uint256 totalReward = getTotalRewardAmount(user);
            if (totalReward > 0) {
                dappToken.transfer(user.addr, totalReward);
            }
        }
    }

    function unstake(address _token, uint256 _amount) public {
        (bool isExist, uint256 index) = findUser(msg.sender);
        require(isExist, "You have not staked anything!");
        require(_amount > 0, "The unstake amount must be greater than zero");
        require(
            isTokenAllowed(_token),
            "This token is not spport by our service!"
        );

        // transfer token
        User storage user = users[index];
        uint256 availableAmount = user.token2Balance[_token];
        uint256 unstakeAmount = getMax(availableAmount, _amount);
        IERC20(_token).transfer(msg.sender, unstakeAmount);

        // update token balance
        uint256 availableAmountAfterUnstaking = availableAmount - unstakeAmount;
        user.token2Balance[_token] = availableAmountAfterUnstaking;
    }

    function getMax(uint256 _availableAmount, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        if (_amount >= _availableAmount) {
            return _availableAmount;
        } else {
            return _amount;
        }
    }

    function getTotalRewardAmount(User storage _user)
        internal
        view
        returns (uint256)
    {
        // address[] memory stakingTokens = _user.stakingTokens;
        // mapping(address => uint256) memory token2Balance = _user.token2Balance;
        uint256 total = 0;
        //get reward amount in DAPP token for each token this user possess
        for (uint256 index = 0; index < _user.stakingTokens.length; index++) {
            address tokenAddr = _user.stakingTokens[index];
            uint256 tokenBalance = _user.token2Balance[tokenAddr];
            total += getRewardAmountOfSingleToken(tokenAddr, tokenBalance);
        }
        return total;
    }

    function getTotalRewardAmount2(uint256 idx) public view returns (uint256) {
        User storage _user = users[idx];
        // address[] memory stakingTokens = _user.stakingTokens;
        // mapping(address => uint256) memory token2Balance = _user.token2Balance;
        uint256 total = 0;
        //get reward amount in DAPP token for each token this user possess
        for (uint256 index = 0; index < _user.stakingTokens.length; index++) {
            address tokenAddr = _user.stakingTokens[index];
            uint256 tokenBalance = _user.token2Balance[tokenAddr];
            total += getRewardAmountOfSingleToken(tokenAddr, tokenBalance);
        }
        return total;
    }

    function getRewardAmountOfSingleToken(
        address _tokenAddress,
        uint256 _tokenBalance
    ) internal view returns (uint256) {
        //in case balance equals zero, return 0 without calling priceFeed contract
        if (_tokenBalance == 0) return 0;

        address priceFeedAddr = token2PriceFeed[_tokenAddress];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddr);

        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());

        return ((_tokenBalance * uint256(price)) / (10**decimals));
    }

    function addToken2ListTokenOfUser(address _token, User storage _user)
        internal
    {
        address[] storage stakingTokens = _user.stakingTokens;
        bool isAddedBefore = false;
        for (uint256 index = 0; index < stakingTokens.length; index++) {
            if (_token == stakingTokens[index]) isAddedBefore = true;
        }
        if (!isAddedBefore) _user.stakingTokens.push(_token);
    }

    function findUser(address _userAddress)
        internal
        view
        returns (bool, uint256)
    {
        for (uint256 index = 0; index < users.length; index++) {
            if (users[index].addr == _userAddress) return (true, index);
        }
        return (false, users.length);
    }

    function isTokenAllowed(address _address) internal view returns (bool) {
        for (uint256 index = 0; index < allowedTokens.length; index++) {
            if (allowedTokens[index] == _address) return true;
        }
        return false;
    }

    function setPriceFeed(address _token, address _priceFeed) public onlyOwner {
        token2PriceFeed[_token] = _priceFeed;
    }

    function addAllowedToken(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }
}
