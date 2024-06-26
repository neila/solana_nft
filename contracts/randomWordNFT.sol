// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/base64.sol";

contract randomWordNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // We split the SVG at the part where it asks for the background color.
    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = [
        "Time",
        "Complex",
        "Queen",
        "Mob",
        "Ra-",
        "Runaway",
        "Operation",
        "Employee",
        "Phatty",
        "Cactoid",
        "WildWild",
        "InterPlanetary",
        "Exquisite",
        "Oriental",
        "Mind-bending"
    ];
    string[] secondWords = [
        "Mofo",
        "Vigilante",
        "Android",
        "Sampa",
        "Christ",
        "Family",
        "Crew",
        "Energy",
        "Photosynthesis",
        "Juvenile",
        "Punk",
        "Anarchist",
        "SendThemAllUp",
        "BreakfastInNewOrleans",
        "Champ" 
    ];
    string[] thirdWords = [
        "OnTour",
        "MiamiTrip",
        "Electronica",
        "TrappedInLA",
        "Stayin'Strong",
        "Sendin'Love",
        "DanceParty",
        "GoesToSpace"
        "HuntsUnicorns",
        "InGuantanamoBay",
        "BoredInApeForm",
        "CrashesCar",
        "WinsLottery",
        "Dogfight",
        "SingingInTheShower"
    ];

    string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green", "#5816cc", "#91e615", "#9a4175", "#a0c588", "#eb7717"];

    event newTokenMinted(address sender, uint256 tokenId);

    constructor() ERC721("EpisodicNFT", "EPS") {
        console.log("This is my NFT contract. Woah!");
    }

    // functions to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // seed the random generator.
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
        rand = rand % colors.length;
        return colors[rand];
    }


    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function mintNFT() public {
        uint256 newItemId = _tokenIds.current();

        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        string memory randomColor = pickRandomColor(newItemId);


        // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(
            abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>")
        );
        
        // Get all the JSON metadata in place and base64 encode it.
        
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', combinedWord,
                        '", "description": "Random people doing random shit.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encoded svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );


        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();

        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        emit newTokenMinted(msg.sender, newItemId);
    }
}
