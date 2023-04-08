import pytest 
from brownie import Lottery, accounts

@pytest.fixture(scope="module")
def deployer():
      return accounts.load("deployment_account")

@pytest.fixture(scope="module")
def token(Lottery, deployer):
        deployer.deploy(Lottery, 0.19, 10)

def test_account_balance(token):
    balance = accounts[0].balance()
    accounts[0].transfer(accounts[1], "10 ether", gas_price=0)

    assert balance - "10 ether" == accounts[0].balance()