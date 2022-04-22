
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;



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
    uint256  taxPercentage;
    uint256  taxDecimals;
    uint256   totalTaxDecimals;
    
    uint256 decimal;

    constructor() public{
        name="UToken";
        symbol="UT";
        _totalSupply=0;
        decimal=18;
        balances[msg.sender]=_totalSupply;
        owner=msg.sender;
        taxPercentage=1;
        taxDecimals=0;
    }
    
    // modifiers

    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }

function mint(bool isIntAllocation,uint256 intPart,uint256 floatPart,uint256 totalDecimals)public  returns(bool){

if(isIntAllocation==true)    
    IntergerMint(intPart);
else
    FloatMint(intPart,floatPart,totalDecimals);

}

    function IntergerMint(uint256 numTokens)internal {
        _totalSupply+=(numTokens*(10**decimal) );
        balances[owner]+=(numTokens*(10**decimal) );

    }
    function FloatMint(uint256 integerPart,uint256 floatPart,uint256 totalDecimals )internal returns(uint256){
        uint256 tokens=( (integerPart*(10**totalDecimals)) *(10**(decimal-totalDecimals)))+(floatPart*(10**(decimal-totalDecimals)));
        _totalSupply+=tokens;
        balances[owner]+=tokens;

        return tokens;
    }

function setTaxPercentage(bool isIntAllocation,uint256 intPart,uint256 floatPart,uint256 totalDecimals)public  onlyOwner returns (bool){

if(isIntAllocation==true)    
    setIntTaxPercentage(intPart);
else
    setFloatTaxPercentage(intPart,floatPart,totalDecimals);

}


    function setIntTaxPercentage(uint256 percentage)internal {
        taxPercentage=percentage;

    }

    function setFloatTaxPercentage(uint256 percentage,uint256 txDecimals,uint256 totalDecimals)internal{
        taxPercentage=percentage;
        taxDecimals= txDecimals;
        totalTaxDecimals=totalDecimals;

    }

    function calculateDeduction(uint256 tokens)public view  returns(uint256){
        
        uint256 taxPercentage_;
        uint256 taxDecimals_;
        taxPercentage_=taxPercentage*(10**decimal);
        taxDecimals_=taxDecimals*(10**(decimal-totalTaxDecimals));
        uint256 decimilizedTaxPercentage=taxPercentage_+taxDecimals_;
        uint256 leftside=tokens;
        uint256 rightside=(decimilizedTaxPercentage*(10**totalTaxDecimals))/(100*(10**totalTaxDecimals));
        
        return (leftside*rightside);


    }

    function totalSupply() external override view returns (uint){
        //return _totalSupply;
        return _totalSupply/(10**decimal);
        
    }
    
    function balanceOf(address tokenOwner) external override   view returns (uint balance){
        //return balances[tokenOwner];
        return balances[tokenOwner]/(10**decimal);

    }

    function allowance(address tokenOwner, address spender)public  override   view returns (uint remaining){
        return allowed[tokenOwner][spender];
    }
    

    function transfer(address to, uint tokens) external override   returns (bool success){

        require(balances[msg.sender]>=tokens);
        uint256 decimilizedToken=tokens*(10**decimal);

        uint256 deduction=deduct(to,tokens);

        balances[msg.sender]-=decimilizedToken;
        balances[to]=balances[to]+(decimilizedToken -deduction);
        emit Transfer(msg.sender,to,tokens);
        return true;

    }
    function deduct(address to,uint256 tokens)public returns(uint256){
        uint256 deduction;
        if( msg.sender==owner || to==owner ){
            deduction=0;
        }
        else
            deduction=calculateDeduction(tokens);
        balances[owner]+=deduction;
        return deduction;

    }

    function approve(address spender, uint tokens)external override  returns (bool success){
        allowed[msg.sender][spender]=(tokens*(10**decimal));
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
            deduction=calculateDeduction(tokens);

        balances[owner]+=deduction;
        
        balances[from]-=tokens;
        allowed[from][msg.sender]-=tokens;

        tokens=tokens-deduction;
        balances[to]+=tokens;  

        _totalSupply= _totalSupply - (tokens+deduction);
        emit Transfer(from,to,tokens);
        return true;

    }
    
 



}
