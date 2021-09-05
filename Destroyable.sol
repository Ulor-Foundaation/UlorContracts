import "./Ownable.sol";
pragma solidity 0.5.12;

contract Destroyable is ownable{
    
    function destroy() public onlyOwner {
        address payable recevier = msg.sender;
        selfdestruct(recevier);
    }
}
