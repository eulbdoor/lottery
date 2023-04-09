// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

// TODO: Adicionar setURI cm tem no OZ
// TODO: Enviar % dos lucros outra wallet
// TODO: Imagens NFTs
// TODO: Ter um JACKPOT
// TODO: Aceitar vários winning ticket ids
// TODO: Ler sobre re entrancy attacks

contract Lottery is ERC1155, ERC1155Burnable, Ownable {
    enum LOTTERY_STATE {
        CREATED,
        OPEN,
        CLOSED,
        CLAIMING,
        FINISHED
    }
    
    struct LotteryInfo {
        uint256 ticket_cost;
        uint256 max_tickets;
        uint256 starting_ticket_id;
        uint256 ending_ticket_id;
        uint256 tickets_bought;
        uint256 winning_ticket_id;
    }

    LotteryInfo[] public lotteries_infos;

    LOTTERY_STATE public lottery_state;
    LotteryInfo public lottery_info;
    uint256 public current_ticket_id;

    constructor(uint256 _ticket_cost, uint256 _max_tickets) ERC1155("") {
        _set_lottery_info(_ticket_cost, _max_tickets);
    }

    function create_lottery(uint256 _ticket_cost, uint256 _max_tickets) onlyOwner public {
        require(lottery_state == LOTTERY_STATE.FINISHED, "Invalid lottery state");

        lottery_state = LOTTERY_STATE.CREATED;
        _set_lottery_info(_ticket_cost, _max_tickets);
    }

    function _set_lottery_info(uint256 _ticket_cost, uint256 _max_tickets) private {
        lottery_info = LotteryInfo({
            ticket_cost: _ticket_cost,
            max_tickets: _max_tickets,
            starting_ticket_id: current_ticket_id,
            ending_ticket_id: current_ticket_id + _max_tickets,
            tickets_bought: 0,
            winning_ticket_id: 0
        });
    }

    function change_ticket_cost(uint256 _ticket_cost) onlyOwner public {
        require(lottery_state == LOTTERY_STATE.CREATED, "Invalid lottery state");
        lottery_info.ticket_cost = _ticket_cost;
    }

    function change_max_tickets(uint256 _max_tickets) onlyOwner public {
        require(lottery_state == LOTTERY_STATE.CREATED, "Invalid lottery state");
        lottery_info.max_tickets = _max_tickets;
    }

    function start_lottery() onlyOwner public {
        require(lottery_state == LOTTERY_STATE.CREATED, "Invalid lottery state");
        lottery_state = LOTTERY_STATE.OPEN;
    }

    // Usar _beforeTokenTransfer? - Hooks!
    // TODO: Emit an event
    function buy_ticket() public payable {
        require(lottery_state == LOTTERY_STATE.OPEN, "Invalid lottery state");
        require(current_ticket_id < lottery_info.ending_ticket_id, "Lottery is sold out");
        require(msg.value == lottery_info.ticket_cost, "Insufficient Ether"); // TODO: Verificar se o o msg.value vem em WEI 

        current_ticket_id += 1;
        _mint(_msgSender(), current_ticket_id, 1, "");
    }

    function end_lottery() onlyOwner public {
        require(lottery_state == LOTTERY_STATE.OPEN, "Invalid lottery state");

        lottery_state = LOTTERY_STATE.CLOSED;
        _set_tickets_bought();
        _set_winning_ticket_id();
        _add_lottery_info();
    }
    
    function _set_tickets_bought() private {
        require(lottery_state == LOTTERY_STATE.CLOSED, "Invalid lottery state");

        lottery_info.tickets_bought = current_ticket_id - lottery_info.starting_ticket_id;
    }

    function _set_winning_ticket_id() private {
        require(lottery_state == LOTTERY_STATE.CLOSED, "Invalid lottery state");

        lottery_info.winning_ticket_id = _get_random_number() % lottery_info.tickets_bought + lottery_info.starting_ticket_id;
        lottery_state = LOTTERY_STATE.CLAIMING;
    }

    function _get_random_number() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.number)));
    }

    function _add_lottery_info() private {
        lotteries_infos.push(lottery_info);
    }

    function claim(uint256 _ticket_id) public payable {
        require(lottery_state == LOTTERY_STATE.CLAIMING, "Invalid lottery state");
        require(balanceOf(_msgSender(), _ticket_id) == 1, "Ticket not found");
        require(_ticket_id == lottery_info.winning_ticket_id, "Ticket is not a winning ticket");

        _burn(_msgSender(), _ticket_id, 1);
        payable(_msgSender()).transfer(address(this).balance);

        lottery_state = LOTTERY_STATE.FINISHED;
    }
}