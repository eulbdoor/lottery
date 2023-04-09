import brownie, pytest 
from brownie import Lottery, accounts 

@pytest.fixture(scope="module")
def deployer():
    return accounts.load("deployment_account")

@pytest.fixture(scope="module", autouse=True)
def token(Lottery, deployer):
    return deployer.deploy(Lottery, 0.05, 10)

@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass

def test_start_lottery(token, deployer):
    token.start_lottery({'from': deployer})

def test_start_lottery_twice(token, deployer):
    token.start_lottery({'from': deployer})
    with brownie.reverts(""):
        token.start_lottery({'from': deployer})

def test_start_lottery_not_authorized(token):
    with brownie.reverts("Ownable: caller is not the owner"):
        token.start_lottery({'from': accounts[0]})


# Validar com o erro.