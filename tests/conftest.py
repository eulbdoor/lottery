import pytest 
from brownie import accounts

@pytest.fixture(scope="module")
def deployer():
    return accounts.load("deployment_account")