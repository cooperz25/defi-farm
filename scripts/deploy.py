from brownie import accounts, config, network, TokenERC20, DefiFarm
from scripts import helper
import yaml, json, os, shutil


def main():
    acc = helper.getAccount()
    defiFarm, dapp = deploy(acc)

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
    updateFronEnd()


def deploy(acc):
    dapp = deployDapp(acc)
    defiFarm = deployDefiFarm(dapp, acc)
    dapp.transfer(defiFarm.address, (dapp.totalSupply() * 8) / 10, {"from": acc}).wait(
        1
    )  # transfer 80% dapp to defiFarm to create reward pool
    return defiFarm, dapp


def addAllowedTokens(defiFarm, tokensDict, acc):
    print(f"acc {acc}")
    for token in tokensDict:
        defiFarm.addAllowedToken(token, {"from": acc}).wait(1)
        defiFarm.setPriceFeed(token, tokensDict[token], {"from": acc}).wait(1)


def deployDapp(acc):
    dapp = TokenERC20.deploy(10 ** 27, "Dapp Token", "DAPP", {"from": acc})
    return dapp


def deployDefiFarm(dapp, acc):
    defiFarm = DefiFarm.deploy(
        dapp.address,
        {"from": acc},
        publish_source=False,
    )
    return defiFarm


def updateFronEnd():
    copyFolder("./build", "./front-end/src/chain-info")

    with open("./brownie-config.yaml", "r") as f:
        config_dict = yaml.load(f, Loader=yaml.FullLoader)
        with open("./front-end/src/brownie-config.json", "w") as brownie_config_json:
            json.dump(config_dict, brownie_config_json)


def copyFolder(src, dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)

    shutil.copytree(src, dst)
