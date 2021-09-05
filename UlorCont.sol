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

contract UlorCon is ownable, Destroyable{
    Ulor Token = Ulor(0xF250AB1bf7207F493cB9c6451AF32D554cC6433c);
    
    //variables
    struct Member{
        uint id;
        address  ref; 
    }
    
    mapping(address => uint) private Ballances;
    mapping(address => Member) private Members;
    mapping(address => uint) private SwapedAcct;
    
    uint private TotalERCSupply;
    uint private JoinCst;
    uint private RefPercnt;
    uint private MembCount = 1;
    uint private SwapCnt = 1;
    
    bool private SwapEvtg;
    
    address[] private MembersAr;
    
    //modifiers
    modifier cost (uint _cost,address sendr){
        uint __cost = (_cost) * (10 ** uint256(18 ));
        require(Token.balanceOf(sendr) >= __cost,"transfer amount exceeds ULOR Token balance");
        _;
    }
    
    modifier checkRef (address _ref){
        require(Members[_ref].id > 0);
        _;
    }
    
    modifier whenSwapNotPaused(){
        require(!SwapEvtg);
        _;
    }
    
    modifier whenSwapPaused(){
        require(SwapEvtg);
        _;
    }
    
    //events
    event WithdrawedEvt(address account, uint amount,address perFormby);
    event JoinedEvt(address account, uint id, address ref);
    event SwapEvt(address account,uint paidAmt, uint TknAmtSwap);
    
    //functions
    constructor(uint _JoinCst,uint _RefPercnt) public{
        
        JoinCst = (_JoinCst) * (10 ** uint256(18 ));
        RefPercnt = _RefPercnt;
        SwapEvtg = false;
        
        Member memory newMember;
        newMember.id = MembCount;
        newMember.ref = owner;
        
        InsertPerson(newMember);
        MembersAr.push(msg.sender);
        
        assert(keccak256(abi.encodePacked(
            Members[msg.sender].id,
            Members[msg.sender].ref))
            ==
            keccak256(abi.encodePacked(
            newMember.id,
            newMember.ref))
        );
        
        MembCount += 1;
    }
    
    function resetContractDtl(uint _JoinCst,uint _RefPercnt) public onlyOwner{
        JoinCst = (_JoinCst) * (10 ** uint256(18 ));
        RefPercnt = _RefPercnt;
    }
    
    function InsertPerson(Member memory _newMember) private{
        address NewCreator = msg.sender;
        Members[NewCreator] = _newMember;
    }
    
    function swapTkn() public payable whenSwapNotPaused {
        require(SwapedAcct[msg.sender] <= 0,"YOU ALREADY SWAPPED YOUR TOKEN");
        require(msg.value >= 50 finney ,"VALUE MUST BE GREATER THAN 0.01");
        
        uint256 sndtk = (1) * (10 ** uint256(18 ));
        
        bool TranRec = Token.transfer(msg.sender,sndtk);
        
        if(TranRec){
            SwapedAcct[msg.sender] = SwapCnt;
            SwapCnt ++;
            emit SwapEvt(msg.sender,msg.value,sndtk);
        }else{
            
        }
    }
    
    function checkAddr(address adr) public view returns(uint SwapPos, uint AdrBal,uint memberID, address memberRef) {
        uint adrCnt = SwapedAcct[adr];
        uint adrBal = Ballances[adr];
        uint memid = Members[adr].id;
        address memadr = Members[adr].ref;
        return (adrCnt,adrBal,memid,memadr);
    }
    
    function checkConTract() public view onlyOwner returns
    (uint _TotalERCSupply, uint _JoinCst,uint _RefPercnt, uint _MembCount,uint _SwapCnt,bool _SwapEvtg) {
        return(TotalERCSupply,JoinCst,RefPercnt,MembCount,SwapCnt,SwapEvtg);
    }
    
    function Join(address _ref,uint _JoinCst) public payable cost(_JoinCst , msg.sender){
        require(Members[_ref].id > 0,"Ref address not on our system");
        require(_ref != msg.sender,"You can't refer your account");
        uint __JoinCst = (_JoinCst) * (10 ** uint256(18 ));
        require(__JoinCst >= JoinCst,"Too low join fee");
        
        Member memory newMember;
        newMember.id = MembCount;
        newMember.ref = _ref;
        
        InsertPerson(newMember);
        MembersAr.push(msg.sender);
        
        AddBal(_ref,_JoinCst);
        TotalERCSupply += ((_JoinCst) * (10 ** uint256(18 )));
        assert(Token.balanceOf(address(this)) >= TotalERCSupply);
        emit JoinedEvt (msg.sender, MembCount, _ref);
        MembCount++;
    }
    
    function withdraw() public payable whenNotPaused returns(uint){
        require(Ballances[msg.sender] > 0,"transfer amount exceeds ULOR Token balance");
        uint amoutToWith = Ballances[msg.sender];
        Ballances[msg.sender] = 0;
        assert(Ballances[msg.sender] == 0);
        Token.transfer(msg.sender,amoutToWith);
        
        TotalERCSupply -= amoutToWith;
        assert(Token.balanceOf(address(this)) >= TotalERCSupply);
        
        emit WithdrawedEvt(msg.sender,amoutToWith,msg.sender);
        return amoutToWith;
    }
    
    function emergencyWithdraw(address payable _adrToWith) public payable onlyOwner whenPaused returns(uint){
        require(Ballances[_adrToWith] > 0);
        uint amoutToWith = Ballances[_adrToWith];
        Ballances[_adrToWith] = 0;
        Token.transfer(_adrToWith,amoutToWith);
        
        assert(Ballances[_adrToWith] == 0);
        TotalERCSupply -= amoutToWith;
        assert(Token.balanceOf(address(this)) >= TotalERCSupply);
        
        emit WithdrawedEvt(_adrToWith,amoutToWith,msg.sender);
        return amoutToWith;
    }
    
    function AddBal(address _ref, uint _JoinCst) private{
        uint SnJoinCst = ((_JoinCst) * (10 ** uint256(18 )));
        uint payRef = ((SnJoinCst  * RefPercnt) / 100);
        uint diff = SnJoinCst - payRef;
        Ballances[_ref] += payRef;
        Ballances[owner] += diff;
        Token.transferFrom(msg.sender,address(this),SnJoinCst);
    }
    
    function withdrawBNB() public payable onlyOwner whenNotPaused returns(uint){
        uint conBal = address(this).balance;
        msg.sender.transfer(conBal);
        return conBal;
    }
    
    function withdrawUlor(uint amt) public onlyOwner whenNotPaused cost(amt,msg.sender) returns(uint){
        uint256 sndtk = (amt) * (10 ** uint256(18 )); 
        bool TranRec = Token.transfer(msg.sender,sndtk);
        if(TranRec){
            return sndtk;
        }
    }
    
    function ContractBal() public view onlyOwner returns(uint BNBBal,uint ULORBal){
        return (address(this).balance,Token.balanceOf(address(this)));
    } 
    
    function pauseSwap()public onlyOwner whenSwapNotPaused{
        SwapEvtg = true;
    }
    
    function unPauseSwap()public onlyOwner whenSwapPaused{
        SwapEvtg = false;
    }
}
