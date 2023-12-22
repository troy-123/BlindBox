// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*

Project Title:
Blockchain Blind box

Problem statement:
In the real world, blind boxes come in various forms, such as toys, vending machines, and cloth items, I am interested in creating a virtual blockchain-based blind box.


Example scenario:
Each box is uploaded by individuals from around the world and can contain various types of information,
such as videos, images, texts, or interesting files. Before purchasing a box, we can obtain some information about its content,
but the exact content remains unknown. After purchasing the blind box, we will discover its content.
Additionally, we can utilize a virtual map to keep a record of purchase transactions, such as the locations of the buyers and sellers.

*/

contract BlindBox {
    struct Box {
        uint256 id;
        address uploader;
        string publicInfo;
        string city;
        uint256 price;
    }

    event buyBox(bool success, uint256 indexed id, address buyer, bytes data);

    uint256 private cursor;
    mapping(uint256 => Box) private boxes;

    mapping(uint256 => bytes32) private keys;
    mapping(bytes32 => string) private details;

    function upload(
        string memory _publicInfo,
        string memory _city,
        uint256 _price,
        string memory _detail
    ) external payable {
        require(
            msg.value == 1 ether,
            "Your should pay 1 Ether for the blind box you uploaded."
        );

        cursor += 1;
        boxes[cursor] = Box({
            id: cursor,
            uploader: msg.sender,
            publicInfo: _publicInfo,
            city: _city,
            price: _price
        });

        bytes32 key = keccak256(
            abi.encodePacked(
                block.timestamp,
                block.prevrandao,
                msg.sender,
                _publicInfo,
                _price,
                _detail
            )
        );
        keys[cursor] = key;
        details[key] = _detail;
    }

    function buy(uint256 _id) external payable returns (string memory) {
        Box memory box = boxes[_id];
        require(msg.value == box.price * 10**18, "Didn't pay enough, please try again.");
        
        boxes[_id] = Box({
            id: 0,
            uploader: 0x0000000000000000000000000000000000000000,
            publicInfo: "",
            city: "",
            price: 0
        });
        (bool sent, bytes memory data) = box.uploader.call{value: msg.value}(
            ""
        );
        emit buyBox(sent, _id, msg.sender, data);
        return details[keys[_id]];
    }

    function getBox(uint256 _id) public view returns (Box memory) {
        return boxes[_id];
    }
}
