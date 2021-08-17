//SPDX-License-Identifier: MIT

pragma solidity >=0.4.22;

contract VideogameContract {

    address payable private owner;
    uint private id = 0;

    struct VideoGame {
        string title;
        string subtitle;
        string year;
    }

    struct Product {
        VideoGame videoGame;
        uint stock;
        StockStatus status;
        uint price;
        bool saved;
    }

    enum StockStatus {
        Available,
        SoldOut,
        PreOrder,
        Unavailable
    }

    modifier isOwner() {
        require(owner == msg.sender, "The sender has to be the owner.");
        _;
    }

    VideoGame private videoGame;
    Product private product;

    mapping(uint => Product) private products;

    function saveProduct(string memory _title, string memory _subtitle, string memory _year,
        uint _stock, uint _price) public isOwner returns(uint) {
        videoGame = VideoGame(_title, _subtitle, _year);
        product = Product(videoGame, _stock,StockStatus.Available ,_price, true);
        products[++id] = product;

        return id;
    }

    function getProduct(uint _id) public view returns (string memory, 
        string memory, string memory, uint, uint, StockStatus)  {
        require(isSavedProduct(_id),"Product not found");

        Product memory result = products[_id];

        return(result.videoGame.title, result.videoGame.subtitle , 
            result.videoGame.year ,result.stock, result.price, result.status);
    }

    function isSavedProduct(uint _id) private view returns(bool) {
        return products[_id].saved;
    }

}