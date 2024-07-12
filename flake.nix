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
            kubecm
            curl
            kubectl
            kustomize
            kubernetes-helm
            krew
            k9s
            talosctl
            jq
            yq
          
          ];
          shellHook = ''
            set -a
            source ./secrets.env
            source <(kubectl completion bash)
            source <(kubecm completion bash)
            source <(helm completion bash)
            source <(argocd completion bash)
            source <(kustomize completion bash)
            srouce <(talosctl completion bash)
            set +a
            '';
        };
      }
    );
}
