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

    event soldProductEvent(address addr, string message);
    event soldOutProductEvent(address addr, string message);

    constructor() public  {
        owner = msg.sender;
    }

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

    function stockProduct(uint _id, uint _stock) public isOwner {
        require(isSavedProduct(_id),"Product not found");
        
        if(_stock <= 0) {
            revert("The amount has to be greater than zero");
        }

        Product storage result = products[_id];
        result.stock += _stock;
    }

    function isSavedProduct(uint _id) private view returns(bool) {
        return products[_id].saved;
    }

    function buyProduct(uint _id) public payable {
        require(isSavedProduct(_id),"Product not found");
        Product storage result = products[_id];
        require(result.status == StockStatus.Available, "Product sold out");
        require(msg.value == result.price * 1 ether, "The amount is not the required");

        //Discount one product of stock when a product is bought
        if(--result.stock == 0) {
            result.status = StockStatus.SoldOut;
            emit soldOutProductEvent(msg.sender, "The product is out of stock");
            return;
        }

        emit soldProductEvent(msg.sender, "The product were sold");
    }

    function transferToOwner(uint amount) public payable isOwner {
        require(address(this).balance >= amount, "Insufficient funds");
        owner.transfer(amount * 1 ether);
    }

    function getContractBalance() public view isOwner returns (uint) {
        return address(this).balance / 1e18;
    }

    function getProducts() public view returns(string memory) {
        string memory titles = "|";

        if(id == 0) {
            revert("No data");
        }

        for(uint i = 1; i <= id ; i++) {
            Product memory result = products[i];
            titles = string(abi.encodePacked(titles,result.videoGame.title,
            ": ", result.videoGame.subtitle,"|"));
        }

        return(titles);
    }

}