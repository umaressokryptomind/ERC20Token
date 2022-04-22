
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// 10550000000000000000
// 1000000000000000000000
// 1000000000000000000
// 200000000000000000000

// 400000000000000000000

// 200000000000000000000
//Question by Bilal Ahmad at Kryptomind


/*
            --- Question --


You have to make ERC20 Contract with Following Requirements:
1- Token will follow complete ERC20 Standards
2- Initial Token Supply will be 0
3- Tokens will only be minted by owner
4- Only Owner will set TAX percentage on each token transfer.
5- Percentage of token set by owner must be deducted and transferred to Owner
6- No TAX will be deducted if Owner is involved in transaction

*/


/*

        -- improvement Text by Mr. Bilal --

Some Improvements Required:

1- Token is not Following ERC20 standard, decimal is not defined.
2- Set percentage 0.001 or some decimal and check if it is working.
3-  balances[owner]+=deduction; instead of updating balances mapping directly, 
let the transfer functions to update your balance.
4-  _totalSupply-=tokens+deduction;

This statement is highly disturbing Supply concept. Figure out what actually total supply is?


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
    uint256 decimal;
    uint256 taxPercentage;

    constructor() public{
        name="UToken";
        symbol="UT";
        _totalSupply=0;
        decimal=18;
        balances[msg.sender]=_totalSupply;
        owner=msg.sender;
        taxPercentage=1000000000000000000;
        
    }



    //              Custom Functions

        function setTaxPercentage(uint256 txPercentage)public {
            taxPercentage=txPercentage;
        }

        function mint(uint256 tokens)public returns(bool){
            _totalSupply+=tokens;
            balances[owner]+=tokens;
            return true;
        }
        
    //              -----------------
    
    // modifiers

    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }



    function totalSupply()   external override view returns (uint){
        return _totalSupply;
    }
    function balanceOf(address tokenOwner) 
    public
    override 
    view 
    returns (uint balance)
    {
        return balances[tokenOwner];
    }
    function allowance(address tokenOwner, address spender)  
    external 
    override 
    view 
    returns (uint remaining)
    {
                return allowed[tokenOwner][spender];

    }
    function approve(address spender, uint tokens) 
    external 
    override 
    returns (bool success)
    {
        allowed[msg.sender][spender]=0;
        allowed[msg.sender][spender]=tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
        
    }
    
   function transfer(address to, uint tokens) 
    external 
    override 
    returns (bool success)
    {
        require(balanceOf(msg.sender)>=tokens);
        uint256 deduction=deduct(to,tokens);
        balances[msg.sender]-=tokens;        
        balances[to]=balances[to]+(tokens -deduction);
        emit Transfer(msg.sender,to,tokens);

        return true;
//  200000000000000000000
//        

    }
     function deduct(address to,uint256 tokens)internal returns(uint256){
        uint256 deduction;
        if( msg.sender==owner || to==owner ){
            deduction=0;
        }
        else
            deduction=calculateDeduction(tokens);
        balances[owner]+=deduction;
        return deduction;

    }

 
    function calculateDeduction(uint256 tokens)public view  returns(uint256){
        return (tokens*taxPercentage)/(100*(10**decimal));   
    }

function transferFrom(address from, address to, uint tokens)
     external 
     override
      returns (bool success)
      {
        require(balances[msg.sender]>=tokens);
        uint256 deduction=deduct(to,tokens);
        balances[from]-=tokens;
        balances[msg.sender]-=tokens;
        balances[to]=balances[to]+(tokens -deduction);
        emit Transfer(msg.sender,to,tokens);
        return true;


    }
    

    

}
