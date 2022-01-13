Function Generate-PassPhrase {
<#
.SYNOPSIS

Generates a random passphrase.

.DESCRIPTION

Generates a random passphrase from a supplied list. Additional options available.

.INPUTS

Integer

.OUTPUTS

System.String.

.EXAMPLE

PS> Generate-PassPhrase -NonAlphaNumeric 5
FabulousBreakneckVampire-Squid-!]+(>

.EXAMPLE

PS> Generate-PassPhrase -Copy
Copied to Clipboard: ExquisiteFleetGreat-White-Shark

.NOTES

Author: Joseph Y
Website: https://github.com/exoup
#>
    [CmdletBinding()]
	param(
        [Parameter(ValueFromPipeline)]
        # Appends N NonAlphaNumeric characters to end of passphrase.
        [int32]$NonAlphaNumeric,

        [Parameter()]
        [Alias("C")]
        # Copies PassPhrase output to clipboard.
        [switch]$Copy
)

begin {
    Add-Type -AssemblyName System.Web
    $Super="Super","Excellent","Superb","Superlative","First-Rate","First-Class","Superior","Outstanding","Remarkable","Dazzling","Marvelous","Magnificent","Wonderful","Splendid","Fine","Exquisite","Exceptional","Glorious","Sublime","Peerless","Perfect","Of-The-First-Water","Brilliant","Great","Fantastic","Fabulous","Terrific","Awesome","Ace","Stellar","Divine","A1","Tip-Top","Top-Notch","Neat","Mega","Wicked","Cool","Banging","Crucial","Brill","Smashing","Cracking","On-Fleek"
    $Fast="Fast","Speedy","Quick","Swift","Rapid","Brisk","Nimble","Sprightly","Lively","Fast-Moving","High-Speed","Turbo","Sporty","Accelerated","Express","Flying","Whirlwind","Blistering","Breakneck","Pell-Mell","Meteoric","Smart","Hasty","Hurried","Unhesitating","Expeditious","Fleet-Footed","Nippy","Zippy","Spanking","Scorching","Blinding","Supersonic","Cracking","Fleet","Tantivy","Alacritous","Volant"
    $Animals="Abalone","Albacore","Anchovy","Angelfish","Barnacle","Barracuda","Blue-Crab","Blue-Whale","Bull-Shark","Cleaner-wrasse","Clownfish","Cod","Conch","Coral","Crown-of-Thorns","Cuttlefish","Dolphin","Dottyback","Dragonet","Driftfish","Dugong","Dungeness-Crab","Eel","Elephant-Seal","Emperor-Shrimp","Estuarine-Crocodile","Fan-Worm","Flounder","Flying-Fish","Fugu","Giant-Squid","Great-White-Shark","Grouper","Grunion","Haddock","Hake","Halibut","Herring","Humpback-Whale","Irukandji","Isopods","Jellyfish","John-Dory","Killer-Whale","King-Mackerel","Krill","Lamprey","Leafy-Sea-Dragon","Ling","Lionfish","Lobster","Mackerel","Mahi-mahi","Manatee","Manta-Ray","Megalodon","Mulloway","Mussel","Narwhal","Nautilus","Needle-Fish","Nemertea","Nudibranch","Oarfish","Octopus","Olive-Sea-Snake","Ostracod","Oyster","Pilchard","Plankton","Porcupine-Fish","Porpoise","Prawn","Pufferfish","Quahog","Queen-Conch","Queensland-Blenny","Quillfish","Red-Waratah-Anemone","Requiem-Shark","Ringed-Seal","Ross-Seal","Sea-Cucumber","Sea-Horse","Sea-Lion","Sea-Otter","Sea-Turtle","Sea-Urchin","Sponge","Starfish","Swordfish","Tiger-Shark","Tilefish","Trumpetfish","Tube-Worms","Tun-Shell","Umbrella-Shell","Unicornfish","Vampire-Squid","Velvet-Crab","Violet-Sea-Snail","Viper-Fish","Walrus","Whapuku","Whiting","Xiphias","Xiphosura","Yellowfin-Tuna","Yellowtail-Amberjack","Yellow-Tang","Zooplankton","Zebra-Turkeyfish"
}
process {
if ($NonAlphaNumeric) {
    $Chars=[System.Web.Security.Membership]::GeneratePassword($NonAlphaNumeric,$NonAlphaNumeric)
    $PassPhrase=($Super|Get-Random),($Fast|Get-Random),($Animals|Get-Random),'-',$Chars -join ""
} else {
    $PassPhrase=($Super|Get-Random),($Fast|Get-Random),($Animals|Get-Random) -join ""
}
}
end {
    if ($Copy) {
    $PassPhrase|Set-Clipboard
    "Copied to Clipboard: "+$PassPhrase
    } else {
    $PassPhrase
    }
}
}