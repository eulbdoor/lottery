import brownie, pytest
from brownie import Lottery, accounts

@pytest.fixture(scope="module", autouse=True)
def token(Lottery, deployer):
    return deployer.deploy(Lottery, 1000000000000000000, 10)

@pytest.fixture(scope="module", autouse=True)
def shared_state(token, deployer):
    token.start_lottery({'from': deployer})

# def test_end_lottery(token, deployer):
#     token.end_lottery({'from': deployer})