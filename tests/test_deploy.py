import pytest 
from brownie import Lottery, accounts

@pytest.fixture(scope="module")
def deployer():
      return accounts.load("deployment_account")

def test_deploy(Lottery, deployer):
      _ = deployer.deploy(Lottery, 0.05, 10)