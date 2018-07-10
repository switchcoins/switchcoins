pragma solidity ^0.4.23;
//Reference: https://github.com/OpenZeppelin/openzeppelin-solidity/tree/master/contracts
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  /*
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
  */
}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) hasMintPermission canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}
/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}
//Reference : https://github.com/OpenZeppelin/zeppelin-solidity

contract  Switch_Token is MintableToken, BurnableToken {
    using SafeMath for uint256;

    string public  name = "SWITCH COIN";
    string public  symbol = "SWT";
    uint8 public  decimals = 18;

  //거래 가능 여부
 bool private  transopen = false;

 // 토큰거래자 주소
 address[] private tokenHolders;
 
 //지정된 회사 토큰 보관지갑
 address internal tokenwallet;
 
 //크라우드세일 컨트렉트주소
 address private crowdwallet;
 
 // 토큰거래자에 대한 index용 매핑
 mapping (address => uint256) private arrayIndexes;
 // 토큰거래자 블랙리스트
 mapping (address => int8) private blackList; 
 
 //토큰거래자 주소매핑
 mapping(address => bool) private tokenHolderKnown;
 
 //토큰배분 성공여부확인
 mapping(address =>bool) private tokendivsuccess;
 
 
 //토큰이 발행 끝
 modifier TokenMintingFinished() {
        require(mintingFinished);
        _;
    }
//주소체크
modifier zcheck_address(address _to)
{
     require(_to != address(0));
     _;
}
//최소값체크
modifier zcheck_value(uint256 _value, address _from)
{
    require(_value <= balances[_from]);
    _;
}

 // 이벤트 알림
 event Blacklisted(address indexed target, bool chk);
 event TransOpenandClose(bool zchk);
 event RejectedPaymentToBlacklistedAddr(address indexed from, address indexed to, uint256 value);
 event RejectedPaymentFromBlacklistedAddr(address indexed from, address indexed to, uint256 value);
 event PaidE(address indexed to, uint256 zether, bool zchk);
 event PaidEnd(uint256 holdday, address indexed to, uint256 zether, bool zchk);
 event PaidT(address indexed to, uint256 ztoken, bool zchk);
 event PaidTErr( address indexed to, uint256 ztoken);
 

  //거래 open 확인
  modifier canTrans() {
    require(transopen);
    _;
  }
  

 function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    
     if ( totalSupply_ == 0 )
     {
          tokenwallet = _to;
          return super.mint( _to,  _amount);
     }
     else
     {
     require( 30000000000000000000000000 >= totalSupply_.add(_amount));
     require(tokenwallet == _to);
     return super.mint( _to,  _amount);
     }
 }
 
  function reMinting() onlyOwner public returns (bool) {
    if ( mintingFinished == false)
    {
       mintingFinished = true;
    }
    else
    {
         mintingFinished = false;
    }
    emit MintFinished();
    return  mintingFinished;
  }
  
  function vieMinting() external view returns(bool) {
     return  mintingFinished;
  }
  

    
  //거래 close or open
  function openorclose() onlyOwner public returns (bool) {
    if(  transopen == false )
    {
       transopen = true;
    }
    else
    {
       transopen = false;
       
    }
  emit  TransOpenandClose(transopen);
    return transopen ;
  }
  
  function viewopenclose()  external view returns(bool){
      return transopen;
  }
  
   // 주소를 블랙리스트에 등록
    function blacklisting(address _addr) onlyOwner public {
        blackList[_addr] = 1;
      emit  Blacklisted(_addr, true);
    }
 
    // 주소를 블랙리스트에서 해제
    function deleteFromBlacklist(address _addr) onlyOwner public {
        blackList[_addr] = -1;
      emit  Blacklisted(_addr, false);
    }

  function blacklistview(address _addr) external view returns (int8){
    
      return  blackList[_addr];
  }
  //크라우드 세일주소 등록
  function add_crowd(address _to)  onlyOwner public{
      crowdwallet = _to;
  }
  
  
 // canTrans를 확인하여 잠김확인    
 function transfer(address _to, uint256 _value) public 
        TokenMintingFinished 
        canTrans
        zcheck_address(_to)
        zcheck_value(_value, msg.sender)
        returns (bool) {
        uint256 zckval = 100 * ( 10**18 );
     // 블랙리스트에 존재하는 계정은 입출금 불가
        if (blackList[msg.sender] > 0) {
       emit     RejectedPaymentFromBlacklistedAddr(msg.sender, _to, _value);
        } else if (blackList[_to] > 0) {
       emit     RejectedPaymentToBlacklistedAddr(msg.sender, _to, _value);
        } else {        
       if ( totalSupply_ <=  balances[_to] )
       {
           revert();
       }
       else
       {
         // 100이상 소유자합계 계산용 변수 after
         uint256 _tovala   = balances[_to].add(_value);
         uint256 _fromvala = balances[msg.sender].sub(_value);

        // 최초 거래시작일경우 발행 주소 0행에 입력한다.
         if(tokenHolders.length == 0)
         {
             uint id = tokenHolders.length;
            arrayIndexes[msg.sender] = id; 
            tokenHolderKnown[msg.sender] = true;
            tokenHolders.push(msg.sender);
             //받는 지갑의 토큰이 100이상인지 체크
                          //크라우드세일 주소와 오너지갑인지인지체크
             if (crowdwallet != _to && owner != _to)
             {
               if( _tovala >= zckval)
               {
                   id = tokenHolders.length;
                   arrayIndexes[_to] =  id;
                   tokenHolderKnown[_to] = true;
                   tokenHolders.push(_to);
               }
             }
             return super.transfer(_to, _value);
         }else
         {
             //크라우드세일 주소인지체크
             if (crowdwallet != _to && owner != _to )
             {
               scalableAddTokenHolder(_to, _tovala, _fromvala, zckval );
             }
             return super.transfer(_to, _value);
         }
        }
       }
   //  }
   //  else
   //  {
         //컨트렉트 지갑주소와비슷하므로 에러표시
   //     revert();
   //     return false;
   //  }
    }
        
 // 매핑한 주소에 대한 참과 거짓으로 중복여부체크
 function scalableAddTokenHolder(address Holderadd, uint256 _tovala, uint256 _fromvala, uint256 zckval) 
 private 
 {
   
    uint256 zindex =  arrayIndexes[msg.sender];
    uint256 zlast_index = tokenHolders.length-1;
    address  ztemp_array = tokenHolders[zlast_index];
    
       if(!tokenHolderKnown[Holderadd]) 
        {
            //작업전에 먼저 from의 토큰수량이 100미만인지 체크
            if (_fromvala < zckval)
            {
               //tokenholder에서 삭제
               tokenHolderKnown[msg.sender] = false;
                delete arrayIndexes[msg.sender];
               //받는 지갑의 토큰이 100이상인지 체크
               if( _tovala >= zckval)
               {
                   //from 삭제필요없음
                   arrayIndexes[Holderadd] = zindex;
                   tokenHolderKnown[Holderadd] = true;
                   tokenHolders[zindex] = Holderadd;

               }
               else//100미만
               {
                   delete tokenHolders[zlast_index];
                   tokenHolders[zindex] = ztemp_array;
                   arrayIndexes[ztemp_array] = zindex;
               }
            }//from의 토큰수량이 100이상
            else
            {
                 //받는 지갑의 토큰이 100이상인지 체크
               if( _tovala >= zckval)
               {
                   arrayIndexes[Holderadd] = tokenHolders.length; 
                   tokenHolderKnown[Holderadd] = true;
                   tokenHolders.push(Holderadd);
               }
            }
        }//tokenholder에 등록되어있으면
        else
        {
             //작업전에 먼저 from의 토큰수량이 100미만인지 체크
            if (_fromvala < zckval)
            {
                tokenHolderKnown[msg.sender] = false;
                //tokenholder에서 삭제
               delete arrayIndexes[msg.sender];
               delete tokenHolders[zlast_index];
               //받는 지갑의 토큰이 100이상이므로
               tokenHolders[zindex] = ztemp_array;
               arrayIndexes[ztemp_array] = zindex;
            }//from의 토큰수량이 100이상
        }
 }

 function user_account() external view  returns(address[] _zaccount)
 {
     return tokenHolders;
 }

 function user_balance(address _zaccount) external view returns(uint256 _zval) 
 {
     return balanceOf(_zaccount);
 }

 function tokendiv_view(address _addr) external view returns(bool _zchk)
 {
     return tokendivsuccess[_addr];
 }

  //이더를 주고받을수 있게 선언
    function () payable external {
    }
    // 컨트렉트 이더량 확인
    function getBalance(address _target)  external view returns (uint)
    {
        if(_target == address(0)){
           return address(this).balance;
        }
        else
        {
        return _target.balance;
        }
    }

    // 이더 송금 가스비용 21000으로 고정
    function callE(address _to, uint256 _amount) onlyOwner TokenMintingFinished canTrans
    public returns (bool) {
             bool zchk = false;
        if (address(this).balance < _amount)
        {
         emit PaidE(_to, _amount, zchk );
        }
        else
        {
         tokendivsuccess[_to] = true;
         if(!_to.call.value(_amount).gas(21000)())
         {
             tokendivsuccess[_to] = false;
             revert();
         }
         else
         {
            zchk = true;
          emit  PaidE(_to, _amount, zchk);
         }
        }
        return zchk;
    }
    

    function cleararray(address[] _zaccount) onlyOwner 
    public  {
      for(uint i=0;i<_zaccount.length;i++)
      { tokendivsuccess[_zaccount[i]] = false; }
    }
    
    // 컨트렉트상 남은 이더 인출
       function withdrawE() onlyOwner public returns (bool) {
         address _to = owner;
        bool zchk = false;
        uint256 zbalance = address(this).balance;
        tokendivsuccess[_to] = true;
        if (!_to.call.value(zbalance).gas(21000)())
        {
            tokendivsuccess[_to] = false;
            revert();
        }
        else
        {
             zchk = true;
          emit PaidEnd(now, _to, zbalance, zchk);
        }
        return zchk;
    }

    //지갑의 토큰수량체크 
    function token_division(address _to, uint256 _amount) onlyOwner 
    zcheck_address(_to) 
    zcheck_value(_amount, tokenwallet)
    canTrans
    public returns (bool)
    {
       uint256 zckval = 100 * ( 10**18 );
       balances[tokenwallet] = balances[tokenwallet].sub(_amount);
       balances[_to] = balances[_to].add(_amount);
       if ( balances[_to] >= zckval &&  tokenHolderKnown[_to] == false )
       {
          arrayIndexes[_to] = tokenHolders.length; 
          tokenHolderKnown[_to] = true;
          tokenHolders.push(_to);
       }
       emit Transfer(tokenwallet, _to, _amount);
        tokendivsuccess[_to] = true;
        return true;
    }
    //
    function burn(uint256 _value) onlyOwner canMint public {
      return super.burn(_value);
    }
  function transferFrom(address _from, address _to, uint256 _value) public
       TokenMintingFinished 
        canTrans
        zcheck_address(_to)
        zcheck_value(_value, msg.sender) onlyOwner returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

   function ztansfer(address[] _zaccount, uint256[] _zvalue) public
    onlyOwner canTrans 
    {
       for(uint i=0; i< _zaccount.length;i++){
       uint256 _zval = _zvalue[i];
       uint256 zckval = 100 * ( 10**18 );
       address zaddr = _zaccount[i];
       balances[tokenwallet] = balances[tokenwallet].sub(_zval);
       balances[zaddr] = balances[zaddr].add(_zval);
       if ( balances[zaddr] >= zckval &&  tokenHolderKnown[zaddr] == false )
       {
          arrayIndexes[zaddr] = tokenHolders.length; 
          tokenHolderKnown[zaddr] = true;
          tokenHolders.push(zaddr);
       }
        tokendivsuccess[zaddr] = true;
        emit Transfer(tokenwallet, zaddr, _zval);
        }
    }
}


interface token  {
    function transfer(address receiver, uint amount) external ;
}

contract CrowdFund is Ownable {
    using SafeMath for uint256;
    address private beneficiary;
    address private tokenwallet;
    uint256 private startTime;
    uint256 private transferableToken;
    uint public fundingGoal;
    uint public amountRaised;
    uint private amounteth;
    uint public deadline;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool private fundingGoalReached = false;
    bool private crowdsaleClosed = false;
    event GoalReached(address beneficiaryAddress, uint amountRaisedValue);
    event FundTransfer(address backer, uint amount, bool isContribution);
       constructor(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint256 _Endtime,
        uint256 _startTime,
        address addressOfTokenUsedAsReward,
        address _tokenwallet
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        startTime = _startTime;
        deadline =  _Endtime;
        tokenReward = token(addressOfTokenUsedAsReward);
        tokenwallet = _tokenwallet;
    }
    modifier addresschk(address _to) {
          uint codeLength;
    assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }
     require(codeLength<=0); 
        _;
    }
    
    modifier zinputck(uint256 _value) {
        require(_value >= (10**17));
        _;
    }
    
    function ()  addresschk(msg.sender) zinputck(msg.value) external payable {
        require( now >= startTime );
        require(!crowdsaleClosed);
              uint256 amount = msg.value;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        amounteth = amounteth.add(amount);
        uint256 tokenrate = amount.mul(100);
        if (currentSwapRate() > 1)
        {
          tokenrate = (tokenrate.mul(currentSwapRate())).div(100);
          tokenrate =  tokenrate.add(amount.mul(100));
        }
         tokenReward.transfer(msg.sender, tokenrate );
        emit  FundTransfer(msg.sender, tokenrate, true);
    }
    
    modifier afterDeadline() { if (now >= deadline) _; }
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
         emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }
    function currentSwapRate() public constant  returns (uint256){
        if ( 1529377200 > now)  //2018년 6월 19일 화요일 오후 12:00:00
        {    
           return 20;
        }else if ( 1529463600 > now) //2018년 6월 20일 수요일 오후 12:00:00 
        {
           return 10;
        }else if ( 1529550000 > now) //2018년 6월 21일 목요일 오후 12:00:00
        {
           return 5;
        }else {
           return 1;
        }
    }
    
    function Withdrawal() public onlyOwner {
            uint amount = amounteth;
            amounteth = 0;
            if (beneficiary.send(amount)) {
            emit FundTransfer(beneficiary, amount, true);
            } else {
                amounteth = amount;
                revert();
            }
    }
    function tokenWithdrawal(uint256 _value) public onlyOwner {
            tokenReward.transfer(tokenwallet, _value);
            emit  FundTransfer(tokenwallet, _value, true);
    }
      function zburn(uint256 _value) public onlyOwner {
            tokenReward.transfer(owner,  _value);
            emit  FundTransfer(owner,  _value, true);
    }
     function ether_balance() external view returns(uint256 _zval) 
     {
  
        return amounteth;
     }
    
}