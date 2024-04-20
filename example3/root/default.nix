{query}:
let
    randomNumber =  builtins.readFile (builtins.fetchurl http://www.randomnumberapi.com/api/v1.0/random);
    randomNumberList = builtins.fromJSON randomNumber;
    randomNumberStr = toString (builtins.elemAt randomNumberList 0);
in
{
    random.GET = randomNumberStr;
}