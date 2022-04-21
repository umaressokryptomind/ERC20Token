
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;



abstract contract ERC20Interface  {
    function totalSupply()  public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint remaining);
    function transfer(address to, uint tokens) public virtual returns (bool success);
    function approve(address spender, uint tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint tokens) public virtual returns (bool success);
 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}


contract ERC20 is ERC20Interface{
    string name;
    string symbol;
    mapping(address=>uint256) balances;
    uint256 _totalSupply;
    mapping(address =>mapping(address=>uint256)) allowed;


    constructor() public{
        name="UToken";
        symbol="UT";
        _totalSupply=1000000;
        balances[msg.sender]=_totalSupply;

    }
    function totalSupply() public  override view returns (uint){
        return _totalSupply;

    }
    function balanceOf(address tokenOwner) public override view returns (uint balance){
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public override view returns (uint remaining){
        return allowed[tokenOwner][spender];
    }
    function transfer(address to, uint tokens) public override returns (bool success){
        require(balances[msg.sender]>=tokens);
        balances[msg.sender]-=tokens;
        balances[to]+=tokens;
        emit Transfer(msg.sender,to,tokens);

        return true;

    }

    function approve(address spender, uint tokens) public override returns (bool success){
        allowed[msg.sender][spender]=tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;

    }
    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        require(balances[from]>=tokens);
        require(allowance(from,msg.sender)>=tokens);
        balances[from]-=tokens;
        
        allowed[from][msg.sender]-=tokens;
        
        balances[to]+=tokens;
        
        emit Transfer(from,to,tokens);
        return true;

    }
    
 



}
