import pytest 
from brownie import Lottery, accounts

@pytest.fixture(scope="module")
def deployer():
      return accounts.load("deployment_account")

@pytest.fixture(scope="module")
def token(Lottery, deployer):
      return deployer.deploy(Lottery, 0.05, 10)

def test_start_lottery_with_owner(token, deployer):
      token.start_lottery({'from': deployer})