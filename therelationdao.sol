// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TheRelationDAO is ERC721 {
    uint256 public next_user;

    mapping(uint256 => string) profile;

    mapping(uint256 => uint256) follow_sum;
    mapping(uint256 => uint256) followed_sum;
    mapping(uint256 => mapping(uint256 => bool)) follow_table;

    event FollowEvt(uint256 indexed _from, uint256 indexed _to);
    event UnFollowEvt(uint256 indexed _from, uint256 indexed _to);
    event RegisterEvt(address indexed _owner, uint256 _from, string _profile);
    event ProfileEvt(uint256 indexed _from, string _profile);

    function mint(string memory _URI) external {
        uint256 id = next_user;
        _safeMint(msg.sender, id);
        profile[id] = _URI;
        next_user++;
        emit RegisterEvt(msg.sender, id, _URI);
    }

    function update(uint256 _from, string memory _URI) external {
        require(_isApprovedOrOwner(msg.sender, _from));
        profile[_from] = _URI;
        emit ProfileEvt(_from, _URI);
    }

    function follow(uint256 _from, uint256 _to) external {
        require(_from != _to, "TheRelationDao: error");
        require(_exists(_to), "TheRelationDao: nonexistent token");
        require(_isApprovedOrOwner(msg.sender, _from));
        require(!is_follow(_from, _to), "TheRelationDao: followed");

        follow_table[_from][_to] = true;

        follow_sum[_from]++;
        followed_sum[_to]++;

        emit FollowEvt(_from, _to);
    }

    function unfollow(uint256 _from, uint256 _to) external {
        require(_from != _to, "TheRelationDao: error");
        require(_exists(_to), "TheRelationDao: nonexistent token");
        require(_isApprovedOrOwner(msg.sender, _from));
        require(is_follow(_from, _to), "TheRelationDao: unfollow");

        follow_table[_from][_to] = false;

        follow_sum[_from]--;
        followed_sum[_to]--;

        emit UnFollowEvt(_from, _to);
    }

    function is_follow(uint256 _from, uint256 _to) public view returns (bool) {
        return follow_table[_from][_to];
    }

    function query_follow_sum(uint256 _from) public view returns (uint256) {
        return follow_sum[_from];
    }

    function query_followed_sum(uint256 _from) public view returns (uint256) {
        return followed_sum[_from];
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "TheRelationDao: nonexistent token");
        return profile[_tokenId];
    }

    constructor() ERC721("TheRelationDAO", "RELATION") {}
}
