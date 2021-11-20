// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Crowdfunding{
    
    enum Status { Active, Inactive }
    
    struct Contribution{
        address contributor;
        uint value;
    }
        
    struct Project{
        string id;
        string name; 
        Status status;
        uint goal;
        uint founds;
        address payable authorWallet;
        address author;
    }

    Project[] public projects;
    mapping ( string => Contribution[] ) public contributions;
    
    function createProject(string memory _id, string memory _name, uint _goal) public{
        Project memory project;
        project = Project(
                _id, 
                _name, 
                Status.Active, 
                _goal, 
                0, 
                payable(msg.sender), 
                msg.sender
        );
        projects.push(project);
    } 
    
    modifier onlyAuthor(uint idProject){
        require (   msg.sender == projects[idProject].author , 
                    "Only author can change the state of the project" );
        _;
    }
    
    modifier addFounds(uint idProject){
        require (   msg.sender != projects[idProject].author , 
                    "Author can not add found to their owns projects" );
        _;
    }
    
    event eFundProject(uint founds, string message);
    
    function fundProject(uint idProject) public payable addFounds(idProject){
        Project memory project = projects[idProject]; 
        
        require(msg.value > 0, "El aporte debe ser mayor a cero");
        require(project.status == Status.Active, "El proyecto debe estar activo");
        
        project.authorWallet.transfer(msg.value);
        project.founds += msg.value;
        
        contributions[project.id].push(Contribution(msg.sender, msg.value));
        emit eFundProject(project.founds, "Se recibieron los aportes");
        
        projects[idProject] = project;
    }
    
    event eChangeProjectState(Status state, string message);
    
    function  changeProjectState(uint idProject, Status newSatus) public onlyAuthor(idProject){
        Project memory project = projects[idProject];
        
        require(newSatus != project.status , "El estado debe ser diferente para actualizarlo");
        
        project.status = newSatus;
        
        emit eChangeProjectState(project.status, "Se cambio el estado del proyecto");
    }
    
    
}
