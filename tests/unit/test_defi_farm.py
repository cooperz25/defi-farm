from scripts import deploy, helper
from brownie import network, exceptions
import pytest


def test_add_allowed_token_price_feed():
    if network.show_active() not in helper.DEV_NETWORK:
        print("For dev net only")
        pass

    acc = helper.getAccount()
    defiFarm, dapp = deploy.deploy(acc)

    priceFeed = helper.getContract("dai_fau_usd_price_feed_contract")

    defiFarm.addAllowedToken(dapp)
    assert defiFarm.allowedTokens(0) == dapp

    defiFarm.setPriceFeed(dapp, priceFeed)
    assert defiFarm.token2PriceFeed(dapp) == priceFeed

    acc2 = helper.getAccount(2)
    with pytest.raises(exceptions.VirtualMachineError):
        defiFarm.addAllowedToken(dapp, {"from": acc2})


def test_stake_token(amount_staked):
    if network.show_active() not in helper.DEV_NETWORK:
        print("For dev net only")
        pass

    acc = helper.getAccount()
    defiFarm, dapp = deploy.deploy(acc)

    # add allowed tokens
    ethTokenPriceFeed = helper.getContract("eth_usd_price_feed_contract")
    dappTokenPriceFeed = helper.getContract("dai_fau_usd_price_feed_contract")
    daiFauPriceFeed = helper.getContract("dai_fau_usd_price_feed_contract")

    ethToken = helper.getContract("eth_token")
    daiFauToken = helper.getContract("dai_fau_token")

    tokensDict = {
        ethToken: ethTokenPriceFeed,
        dapp: dappTokenPriceFeed,
        daiFauToken: daiFauPriceFeed,
    }
    addAllowedTokens(defiFarm, tokensDict, acc)
    ethToken.transfer(defiFarm, 9 * 10 ** 26, {"from": acc})
    ethToken.approve(defiFarm, amount_staked, {"from": acc})
    defiFarm.stake(ethToken, amount_staked, {"from": acc}).wait(1)

    print("user balance: ", defiFarm.getBalance(0, dapp))
    assert defiFarm.getBalance(0, ethToken) == amount_staked

    return defiFarm, dapp, acc


def test_issue(amount_staked):
    defiFarm, dapp, acc = test_stake_token(amount_staked)
    acc2 = helper.getAccount(5)
    with pytest.raises(exceptions.VirtualMachineError):
        defiFarm.issueToken({"from": acc2})

    addr = defiFarm.getTotalRewardAmount2(0, {"from": acc})
    print(f"total reward amount :", " ", addr)

    balanceBeforeIssue = dapp.balanceOf(acc)
    print(f"balance {balanceBeforeIssue}")
    defiFarm.issueToken({"from": acc}).wait(1)
    balanceAfterIssue = dapp.balanceOf(acc)
    print(f"balance {balanceAfterIssue}")

    assert balanceBeforeIssue + helper.INITIAL_PRICE[0] == balanceAfterIssue


def addAllowedTokens(defiFarm, tokensDict, acc):
    print(f"acc {acc}")
    for token in tokensDict:
        defiFarm.addAllowedToken(token, {"from": acc}).wait(1)
        defiFarm.setPriceFeed(token, tokensDict[token], {"from": acc}).wait(1)
