from brownie import accounts

def buy_ticket(token):
    token.buy_ticket({'from': accounts[0], 'value': 1000000000000000000 })

