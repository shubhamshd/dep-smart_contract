//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract TokenGating is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter public tokenId;
    address payable contractAddress = payable(address(this));
    address public owner;

    mapping(uint256 => uint8) videoPrice;


    constructor() ERC721 ("Idea NFT", "DIP"){
        owner = msg.sender;
    }

    // encode the video metadata to base64 before setting it as tokenURI
    function getTokenURI(
        string memory _videoName, 
        string memory _videoUrl, 
        uint8 _videoPrice, 
        uint _moduleNumber, 
        string memory _moduleName, 
        string memory _courseName) private pure returns (string memory){

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"video_name": "',
            _videoName,
            '",',
            '"video_url": "',
            _videoUrl,
            '",',
            '"video_price": "',
            _videoPrice,
            '",',
            '"module_number": "',
            _moduleNumber,
            '"module_name": "',
            _moduleName,
            '",',
            '"course_name": "',
            _courseName,
            '"'
            "}"
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
    //@params video_number, video_name, video_data, module_number, module_name, course_name
    //mint NFT for every video uploaded with author/tutor as the owner of the NFT
    function createVideoNFT( 
        string memory _videoName, 
        string memory _videoUrl, 
        uint8 _videoPrice,
        uint _moduleNumber, 
        string memory _moduleName, 
        string memory _courseName) public payable returns (uint256){

        tokenId.increment();
        uint256 newTokenId = tokenId.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, getTokenURI(_videoName,  _videoUrl, _videoPrice,  _moduleNumber,  _moduleName,  _courseName));
        videoPrice[newTokenId] = _videoPrice;
        return newTokenId;
    }
    
}

