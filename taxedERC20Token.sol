
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;



//Question by Bilal Ahmad at Kryptomind


/*

You have to make ERC20 Contract with Following Requirements:
1- Token will follow complete ERC20 Standards
2- Initial Token Supply will be 0
3- Tokens will only be minted by owner
4- Only Owner will set TAX percentage on each token transfer.
5- Percentage of token set by owner must be deducted and transferred to Owner
6- No TAX will be deducted if Owner is involved in transaction

*/


 interface ERC20Interface  {
    function totalSupply()   external  view returns (uint);
    function balanceOf(address tokenOwner) external  view returns (uint balance);
    function allowance(address tokenOwner, address spender)   external view returns (uint remaining);
    function transfer(address to, uint tokens)  external  returns (bool success);
    function approve(address spender, uint tokens) external  returns (bool success);
    function transferFrom(address from, address to, uint tokens) external  returns (bool success);
 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}


contract ERC20 is ERC20Interface{
    string name;
    string symbol;
    mapping(address=>uint256) balances;
    uint256 _totalSupply;
    mapping(address =>mapping(address=>uint256)) allowed;
    address owner;
    uint256 taxPercentage;
    constructor() public{
        name="UToken";
        symbol="UT";
        _totalSupply=0;
        balances[msg.sender]=_totalSupply;
        owner=msg.sender;
        taxPercentage=1;
    }
    
    // modifiers

    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }

    function mint(uint256 numTokens)public onlyOwner{
        _totalSupply+=numTokens;
        balances[owner]+=numTokens;
    }
    function setTaxPercentage(uint256 percentage)public onlyOwner{
        taxPercentage=percentage;
    }


    function totalSupply() external override view returns (uint){
        return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) external override   view returns (uint balance){
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender)public  override   view returns (uint remaining){
        return allowed[tokenOwner][spender];
    }
    
    function transfer(address to, uint tokens) external override   returns (bool success){
        
        require(balances[msg.sender]>=tokens);

        uint256 deduction;
        if( msg.sender==owner || to==owner ){
            deduction=0;
        }
        else
            deduction=(tokens*taxPercentage)/100;
        
        balances[owner]+=deduction;

        balances[msg.sender]-=tokens;
        tokens=tokens-deduction;
        balances[to]+=tokens;

        _totalSupply-=tokens+deduction;

        emit Transfer(msg.sender,to,tokens);
        return true;

    }

    function approve(address spender, uint tokens)external override  returns (bool success){
        allowed[msg.sender][spender]=tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens) external override  returns (bool success){
        require(balances[from]>=tokens); // checking if the balance really exists in the account to transfer coins from
        require(allowance(from,msg.sender)>=tokens);

        uint256 deduction;
        if( msg.sender==owner || to==owner ){
            deduction=0;
        }
        else
            deduction=(tokens*taxPercentage)/100;

        balances[owner]+=deduction;
        
        balances[from]-=tokens;
        allowed[from][msg.sender]-=tokens;

        tokens=tokens-deduction;
        balances[to]+=tokens;  

        _totalSupply-=tokens+deduction;
        emit Transfer(from,to,tokens);
        return true;

    }
    
 



}
