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
            curl
            kubectl
            kustomize
            kubernetes-helm
            krew
            k9s
            talosctl
            kubecm
          
          ];

          shellHook = ''
            set -a
            source <(kubectl completion bash)
            source <(kubecm completion bash)
            source <(helm completion bash)
            source <(argocd completion bash)
            source <(kustomize completion bash)
            source <(talosctl completion bash)
            set +a
            '';
        };
      }
    );
}
