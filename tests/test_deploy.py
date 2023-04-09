import pytest 
from brownie import Lottery, accounts

def test_deploy(Lottery, deployer):
    _= deployer.deploy(Lottery, 0.05, 10)