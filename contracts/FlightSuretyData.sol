pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;
    bool private operational = true;
    uint256 private authorizedAirlineCount = 0;
    uint256 private changeOperatingStatusVotes = 0;
    uint256 private MAX_NO_OF_AIRLINES = 4;

    struct Airline {
        string name;
        address account;
        bool isRegistered;
        bool isAuthorized;
        bool operationalVote;
    }

    mapping(address => Airline) airlines;


    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/
    event RegisteredAirline(address airline);

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor() public
    {
        contractOwner = msg.sender;
        airlines[contractOwner] = Airline({
            name : "Contract Owner Airline",
            account : contractOwner,
            isRegistered : true,
            isAuthorized : true,
            operationalVote : true
        });
        authorizedAirlineCount = authorizedAirlineCount.add(1);
        emit RegisteredAirline(contractOwner);
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */

    modifier requireIsAuthorized()
    {
        require(airlines[msg.sender].isAuthorized, "Airline needs to be authorized");
        _;
    }

    modifier requireIsOperational()
    {
        require(operational, "Contract is currently not operational");
        _;
        // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */
    function isOperational() public view returns (bool)
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */
    function setOperatingStatus(bool mode) external
    requireContractOwner
    {
        address caller = msg.sender;

        if (authorizedAirlineCount < MAX_NO_OF_AIRLINES) {
            operational = mode;
        } else { //use multi-party consensus amount authorized airlines to reach 50% aggreement
            changeOperatingStatusVotes = changeOperatingStatusVotes.add(1);
            airlines[caller].operationalVote = mode;
            if (changeOperatingStatusVotes >= (authorizedAirlineCount.div(2))) {
                operational = mode;
                changeOperatingStatusVotes = authorizedAirlineCount - changeOperatingStatusVotes;
            }
        }
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    /**
     * @dev Add an airline to the registration queue
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function registerAirline(string name, address airline) external
    requireIsOperational
    {
        require(!airlines[airline].isRegistered,"This airline is already registered.");

        if(authorizedAirlineCount <= MAX_NO_OF_AIRLINES){
            airlines[airline] = Airline({
                name: name,
                account: airline,
                isRegistered: true,
                isAuthorized: false,
                operationalVote: true
            });
            authorizedAirlineCount = authorizedAirlineCount.add(1);
        }
        emit RegisteredAirline(airline);
    }

    /**
     * @dev Check if an airline is registered or not.
     *
     */
    function isAirline(address airline) public returns (bool)
    {
        return airlines[airline].isRegistered;
    }

    /**
     * @dev Buy insurance for a flight
     *
     */
    function buy
    (
    )
    external
    payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
    (
    )
    external
    pure
    {
    }


    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
    (
    )
    external
    pure
    {
    }

    /**
     * @dev Initial funding for the insurance. Unless there are too many delayed flights
     *      resulting in insurance payouts, the contract should be self-sustaining
     *
     */
    function fund
    (
    )
    public
    payable
    {
    }

    function getFlightKey
    (
        address airline,
        string memory flight,
        uint256 timestamp
    )
    pure
    internal
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function()
    external
    payable
    {
        fund();
    }

}

