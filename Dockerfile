FROM nixos/nix
COPY example4 /example4
WORKDIR /example4
CMD nix-shell --run "flask run -h 0.0.0.0 -p 5555"