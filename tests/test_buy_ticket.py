import brownie, pytest 
from brownie import Lottery, accounts

# Fica a zero se meter 0.5
# token = accounts[0].deploy(Lottery, 1, 10)

@pytest.fixture(scope="module", autouse=True)
def token(Lottery, deployer):
    return deployer.deploy(Lottery, 1000000000000000000, 10)

@pytest.fixture(scope="module", autouse=True)
def shared_state(token, deployer):
    token.start_lottery({'from': deployer})

@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass

def buy_ticket(token):
    token.buy_ticket({'from': accounts[0], 'value': 1000000000000000000 })
    
def test_buy_ticket(token):
    buy_ticket(token)

def test_buy_ticket_sold_out(token):
    for i in range(10):
        buy_ticket(token)
    with brownie.reverts("Lottery is sold out"):
        buy_ticket(token)
        
def test_buy_ticket_insufficient_ether(token):
    with brownie.reverts("Insufficient Ether"):
        token.buy_ticket({'from': accounts[0], 'value': 0})