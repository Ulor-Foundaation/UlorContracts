import "./Ownable.sol";
import "./Destroyable.sol";
pragma solidity  <= 0.5.12 < 0.9.0 ;

///First create interface 
contract Ulor{
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract casino is ownable, Destroyable{
    
    Ulor Token = Ulor(0xF250AB1bf7207F493cB9c6451AF32D554cC6433c);
    
    //variables
    struct Member{
        uint id;
        address  ref; 
    }
    
    struct adrNetwork{
        address refered1;
        address refered2;
        address refered3;
        address refered4;
        address refered5;
        address refered6;
        address refered7;
        address refered8;
        address refered9;
        address refered10;
        bool refCompleted;
    }
    
    mapping(address => uint) private Ballances;
    mapping(address => Member) private Creator;
    mapping(address => adrNetwork) private NetTree;
    
    address[] private Creators;
    
    uint private MembCount = 1;
    uint private TotalSupply;
    uint private JoinCst;
    uint private RefPercnt;
    //uint private FeeAmt = 20 finney;
    
    //modifiers
    modifier cost (uint _cost,address sendr){
        require(Token.balanceOf(sendr) >= _cost);
        _;
    }
    
    modifier checkRef (address _ref){
        require(!NetTree[_ref].refCompleted);
        require(Creator[_ref].id > 0);
        _;
    }
    
    //events
    event WithdrawedEvt(address account, uint amount,address perFormby);
    event JoinedEvt(address account, uint id, address ref);
    event UpgradeEvt(address account,uint paidAmt, uint upGraadeAmt, address PaidAdr);
    
    //functions
    constructor(uint _JoinCst,uint _RefPercnt) public{
        
        JoinCst = _JoinCst;
        RefPercnt = _RefPercnt;
        
        Member memory newMember;
        newMember.id = MembCount;
        newMember.ref = owner;
        
        adrNetwork memory newAdrNetwork;
        newAdrNetwork.refered1 = owner;
        newAdrNetwork.refered2 = owner;
        newAdrNetwork.refered3 = owner;
        newAdrNetwork.refered4 = owner;
        newAdrNetwork.refered5 = owner;
        newAdrNetwork.refered6 = owner;
        newAdrNetwork.refered7 = owner;
        newAdrNetwork.refered8 = owner;
        newAdrNetwork.refered9 = owner;
        newAdrNetwork.refered10 = owner;
        newAdrNetwork.refCompleted = false;
        
        InsertPerson(newMember,newAdrNetwork);
        Creators.push(msg.sender);
        
        assert(keccak256(abi.encodePacked(
            Creator[msg.sender].id,
            Creator[msg.sender].ref))
            ==
            keccak256(abi.encodePacked(
            newMember.id,
            newMember.ref))
        );
        
        MembCount += 1;
    }
    
    function getAddrDetails(address _adr) public view returns 
    (uint Bal, uint id,address referedBy ){
        uint _bal = Ballances[_adr];
        return (_bal,
        Creator[_adr].id,
        Creator[_adr].ref
        );
    }
    
    function Join(address _ref,uint _JoinCst) public payable checkRef(_ref) cost(JoinCst, msg.sender){
        require(_ref != msg.sender,"You can't refer your account");
        require(_JoinCst >= JoinCst,"You can't refer your account");
        Member memory newMember;
        newMember.id = MembCount;
        newMember.ref = _ref;
        
        adrNetwork memory newAdrNetwork;
        newAdrNetwork.refered1 = address(0);
        newAdrNetwork.refered2 = address(0);
        newAdrNetwork.refered3 = address(0);
        newAdrNetwork.refered4 = address(0);
        newAdrNetwork.refered5 = address(0);
        newAdrNetwork.refered6 = address(0);
        newAdrNetwork.refered7 = address(0);
        newAdrNetwork.refered8 = address(0);
        newAdrNetwork.refered9 = address(0);
        newAdrNetwork.refered10 = address(0);
        newAdrNetwork.refCompleted = false;
        
        InsertPerson(newMember,newAdrNetwork);
        Creators.push(msg.sender);
        
        adrNetwork memory Adr = NetTree[_ref];
        address refered1 = Adr.refered1;
        address refered2 = Adr.refered2;
        address refered3 = Adr.refered3;
        address refered4 = Adr.refered4;
        address refered5 = Adr.refered5;
        address refered6 = Adr.refered6;
        address refered7 = Adr.refered7;
        address refered8 = Adr.refered8;
        address refered9 = Adr.refered9;
        address refered10 = Adr.refered10;
        
        if(refered1 == address(0)){
            Adr.refered1 = msg.sender;
        }else if(refered2 == address(0)){
            Adr.refered2 = msg.sender;
        }else if(refered3 == address(0)){
            Adr.refered3 = msg.sender;
        }else if(refered4 == address(0)){
            Adr.refered4 = msg.sender;
        }else if(refered5 == address(0)){
            Adr.refered5 = msg.sender;
        }else if(refered6 == address(0)){
            Adr.refered6 = msg.sender;
        }else if(refered7 == address(0)){
            Adr.refered7 = msg.sender;
        }else if(refered8 == address(0)){
            Adr.refered8 = msg.sender;
        }else if(refered9 == address(0)){
            Adr.refered9 = msg.sender;
        }else if(refered10 == address(0)){
            Adr.refered10 = msg.sender;
            /*if(_ref != owner){
                Adr.refCompleted = true;
            }*/
        }
        
        assert(keccak256(abi.encodePacked(
            Creator[msg.sender].id,
            Creator[msg.sender].ref))
            ==
            keccak256(abi.encodePacked(
            newMember.id,
            newMember.ref))
        );
        
        //AddBal(_ref,_JoinCst);
        //TotalSupply += _JoinCst;
        //assert(Token.balanceOf(address(this)) >= TotalSupply);
        //emit JoinedEvt (msg.sender, MembCount, _ref);
        //MembCount += 1;
    }
    
    function InsertPerson(Member memory _newMember, adrNetwork memory _newAdrNetwork) private{
        address NewCreator = msg.sender;
        Creator[NewCreator] = _newMember;
        NetTree[NewCreator] = _newAdrNetwork;
    }
    
    function AddBal(address _ref, uint _JoinCst) private{
        uint payRef = _JoinCst * (RefPercnt / 100);
        uint diff = _JoinCst - payRef;
        Ballances[_ref] += payRef;
        Token.transfer(address(this),_JoinCst);
    }
    
    function ContractBal() public view onlyOwner returns(uint,uint ){
        return (address(this).balance,Token.balanceOf(address(this)));
    }
    
    function withdraw() public payable whenNotPaused returns(uint){
        require(Ballances[msg.sender] > 0);
        uint amoutToWith = Ballances[msg.sender];
        Ballances[msg.sender] = 0;
        Token.transfer(msg.sender,amoutToWith);
        
        assert(Ballances[msg.sender] == 0);
        TotalSupply -= amoutToWith;
        assert(Token.balanceOf(address(this)) >= TotalSupply);
        
        emit WithdrawedEvt(msg.sender,amoutToWith,msg.sender);
        return amoutToWith;
    }
    
    function withdrawEth() public payable onlyOwner whenNotPaused returns(uint){
        uint conBal = address(this).balance;
        msg.sender.transfer(conBal);
        return conBal;
    }
    
    function emergencyWithdraw(address payable _adrToWith) public payable onlyOwner whenPaused returns(uint){
        require(Ballances[_adrToWith] > 0);
        uint amoutToWith = Ballances[_adrToWith];
        Ballances[_adrToWith] = 0;
        Token.transfer(_adrToWith,amoutToWith);
        
        assert(Ballances[_adrToWith] == 0);
        TotalSupply -= amoutToWith;
        assert(Token.balanceOf(address(this)) >= TotalSupply);
        
        emit WithdrawedEvt(_adrToWith,amoutToWith,msg.sender);
        return amoutToWith;
    }
}
