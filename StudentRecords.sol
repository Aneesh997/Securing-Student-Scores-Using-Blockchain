// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentRecords {
    struct Student {
        string firstName;
        string lastName;
        string email;
        string gender;
        uint absenceDays;
        string extracurricularActivities;
        string careerAspiration;
        uint mathScore;
        uint historyScore;
        uint physicsScore;
        uint chemistryScore;
        uint biologyScore;
        uint englishScore;
        uint geographyScore;
        uint totalScore;
        uint percentage;
    }

    struct User {
        string userType; 
        uint otp; 
        bool isVerified; 
    }
    mapping(address => User) private users;
    mapping(uint => Student) private students;
    uint public studentCount;

    address private teacherAddress = 0xBf4b1f5CeEA3B03eF1095fBBb4922C9c7b7b08dF;
    address private studentAddress = 0xC0888f2d46d0d8b350Fa6B8a823a03588bA62235;

    event StudentAdded(uint studentId);
    event UserRegistered(address user, string userType);
    event OTPGenerated(address user, uint otp);
    event OTPVerified(address user);
    event StudentUpdated(uint studentId);

    modifier onlyTeacher() {
        require(
            msg.sender == teacherAddress,
            "Not authorized. Only the teacher can perform this action."
        );
        require(users[msg.sender].isVerified, "User not verified. Complete OTP verification first.");
        _;
    }

    modifier onlyStudent() {
        require(
            msg.sender == studentAddress,
            "Not authorized. Only students can perform this action."
        );
        require(users[msg.sender].isVerified, "User not verified. Complete OTP verification first.");
        _;
    }

    modifier verifiedUser() {
        require(users[msg.sender].isVerified, "User not verified. Complete OTP verification first.");
        _;
    }

    function generateOTP() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10000;
    }

    function registerUser(string memory userType) public {
        require(
            (keccak256(bytes(userType)) == keccak256(bytes("student")) && msg.sender == studentAddress) ||
            (keccak256(bytes(userType)) == keccak256(bytes("teacher")) && msg.sender == teacherAddress),
            "Invalid user type or address"
        );
        
        uint otp = generateOTP();
        users[msg.sender] = User(userType, otp, false);
        emit UserRegistered(msg.sender, userType);
        emit OTPGenerated(msg.sender, otp);
    }

    function verifyOTP(uint otp) public {
        require(users[msg.sender].otp == otp, "Invalid OTP");
        users[msg.sender].isVerified = true;
        emit OTPVerified(msg.sender);
    }

    function addStudent(
        string memory _firstName,
        string memory _lastName,
        string memory _email,
        string memory _gender,
        uint _absenceDays,
        string memory _extracurricularActivities,
        string memory _careerAspiration,
        uint[7] memory scores
    ) public onlyTeacher {
        studentCount++;
        students[studentCount] = Student(
            _firstName,
            _lastName,
            _email,
            _gender,
            _absenceDays,
            _extracurricularActivities,
            _careerAspiration,
            scores[0],
            scores[1],
            scores[2],
            scores[3],
            scores[4],
            scores[5],
            scores[6],
            scores[0] + scores[1] + scores[2] + scores[3] + scores[4] + scores[5] + scores[6],
            (scores[0] + scores[1] + scores[2] + scores[3] + scores[4] + scores[5] + scores[6]) / 7
        );
        emit StudentAdded(studentCount);
    }

    function editStudent(
        uint studentId,
        string memory _firstName,
        string memory _lastName,
        string memory _email,
        string memory _gender,
        uint _absenceDays,
        string memory _extracurricularActivities,
        string memory _careerAspiration,
        uint[7] memory scores
    ) public onlyTeacher {
        require(studentId <= studentCount, "Invalid student ID");

        Student storage student = students[studentId];
        student.firstName = _firstName;
        student.lastName = _lastName;
        student.email = _email;
        student.gender = _gender;
        student.absenceDays = _absenceDays;
        student.extracurricularActivities = _extracurricularActivities;
        student.careerAspiration = _careerAspiration;
        student.mathScore = scores[0];
        student.historyScore = scores[1];
        student.physicsScore = scores[2];
        student.chemistryScore = scores[3];
        student.biologyScore = scores[4];
        student.englishScore = scores[5];
        student.geographyScore = scores[6];
        student.totalScore = scores[0] + scores[1] + scores[2] + scores[3] + scores[4] + scores[5] + scores[6];
        student.percentage = student.totalScore / 7;

        emit StudentUpdated(studentId);
    }

    function getStudent(uint studentId) public view verifiedUser returns (Student memory) {
        require(studentId <= studentCount, "Invalid student ID");
        return students[studentId];
    }
}
