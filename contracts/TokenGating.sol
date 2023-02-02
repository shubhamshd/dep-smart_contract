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
    // uint256 public mintPrice;

    mapping(uint256 => address[]) userTokenAccess;
    mapping(address => mapping(uint256 => bool)) public userTokenAccess3d;
    mapping(uint256 => uint8) videoPrice;


    constructor() ERC721 ("Idea NFT", "DIP"){
        owner = msg.sender;

        //setting the mintPrice
        //mintPrice = _mintPrice;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }


    // encode the video metadata to base64 before setting it as tokenURI
    // "video 1", "http://test.xyz", 1, "1", "mod 1", "course 1"
    function getTokenURI(
        string calldata _videoName, 
        string calldata _videoUrl, 
        uint8 _videoPrice, 
        string calldata _moduleNumber, 
        string calldata _moduleName, 
        string calldata _courseName) private pure returns (string memory){

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
            '",',
            '"module_name": "',
            _moduleName,
            '",',
            '"course_name": "',
            _courseName,
            '"'
            "}"
        );

        return string(
            abi.encodePacked(dataURI)
        );
    }
    //@params video_number, video_name, video_data, module_number, module_name, course_name
    //mint NFT for every video uploaded with author/tutor as the owner of the NFT
    function createVideoNFT( 
        string calldata _videoName, 
        string calldata _videoUrl, 
        uint8 _videoPrice,
        string calldata _moduleNumber, 
        string calldata _moduleName, 
        string calldata _courseName) public payable returns (uint256){

        tokenId.increment();
        uint256 newTokenId = tokenId.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, getTokenURI(_videoName,  _videoUrl, _videoPrice,  _moduleNumber,  _moduleName,  _courseName));
        
        // uint output;
        // assembly {
        //     output := parseUnsignedInt(_videoPrice)
        // }

        videoPrice[newTokenId] = _videoPrice;
        return newTokenId;
    }

    function getCourseTokenURI(
        string calldata _courseName, 
        string calldata _courseImageUrl, 
        string calldata _tutorName, 
        string calldata _tutorIconUrl) private pure returns (string memory){

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"course_name": "',
            _courseName,
            '",',
            '"course_imageUrl": "',
            _courseImageUrl,
            '",',
            '"tutor_name": "',
            _tutorName,
            '",',
            '"tutor_iconUrl": "',
            _tutorIconUrl,
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
    function createCourseNFT( 
        string calldata _courseName, 
        string calldata _courseImageUrl, 
        string calldata _tutorName, 
        string calldata _tutorIconUrl) public payable returns (uint256){

        tokenId.increment();
        uint256 newTokenId = tokenId.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, getCourseTokenURI(_courseName,  _courseImageUrl, _tutorName,  _tutorIconUrl));
        return newTokenId;
    }

    function buyCourseVideoFor(address _address, uint256 _tokenId) public payable{

        /*
        need to check that the msg.sender has enough ether to buy the video
        and for that smart contract should have a way to access the price chart??
        */

        require(_tokenId > 0 && _tokenId <= tokenId.current(), "tokenId does not exist");
        require(msg.value > 0 && msg.value >= videoPrice[_tokenId], "Insufficient fund received");
        require(!isAddressInArray(_address, _tokenId), "User already has access to the video");

        // increment the contract balance
        // contractAddress.transfer(msg.value);

        userTokenAccess[_tokenId].push(_address);
        userTokenAccess3d[_address][_tokenId] = true;

    }

    /*
    instead of using loop to find the access
    we can use following mapping var to store the access ->     
    mapping(address => mapping(uint256 => bool)) public userTokenAccess; 
    */


    function isAddressInArray(address _address, uint256 _tokenId) public view returns (bool) {

        address[] memory _array = userTokenAccess[_tokenId];
        for (uint i = 0; i < _array.length; i++) {
            if (_array[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function checkAccess(address _address, uint256 _tokenId) public view returns(bool) {
        require(_tokenId > 0 && _tokenId <= tokenId.current(), "tokenId does not exist");
        return isAddressInArray(_address, _tokenId);
    }

    function optCheckAccess(address _address, uint256 _tokenId) public view returns(bool) {
        require(_tokenId > 0 && _tokenId <= tokenId.current(), "tokenId does not exist");
        return userTokenAccess3d[_address][_tokenId];
    }

    function transferContractBalance(address payable _to, uint _amount) public onlyOwner {
        _to.transfer(_amount);
    }
    
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

