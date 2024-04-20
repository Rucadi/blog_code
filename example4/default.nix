{
  request_type,
  queryJson,
  path
}:
let
query = builtins.fromJSON queryJson; 
endpoints = import ./root {inherit query;};
asset_endpoint = import ./assets {inherit query;};
splitString = (import <nixpkgs> { }).lib.splitString;
adquireNixObjectByPath = endpoint: pathToSearch: 
                          if pathToSearch == "" then endpoint 
                          else builtins.foldl' (a: b: a."${b}") endpoint (splitString "/" pathToSearch);

in 
{
  process = (adquireNixObjectByPath endpoints path).${request_type};
}