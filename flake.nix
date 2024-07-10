{
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
  
    utils.lib.eachDefaultSystem (
      system: let
        
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            argocd
            opentofu
            tflint
            terraform-docs
            k3sup
            curl
            kubectl
            kustomize
            kubernetes-helm
            krew
            k9s
            talosctl
          
          ];
          shellHook = ''
            set -a
            source ./secrets.env
            set +a
            '';
        };
      }
    );
}
