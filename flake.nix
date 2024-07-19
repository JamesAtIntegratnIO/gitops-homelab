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
      myScript = pkgs.writeShellScriptBin "my-script" ''
      #!/usr/bin/env bash
      echo "Hello, world!"
    '';
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

      (pkgs.writeShellScriptBin "yolo" ''
          #!/usr/bin/env bash
          set -euo pipefail

          SCRIPTDIR="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
          ROOTDIR=$SCRIPTDIR
          [[ -n "''${DEBUG:-}" ]] && set -x

          ''${ROOTDIR}/terraform/hub/deploy.sh

          # Loop through each directory in ''${ROOTDIR}/terraform/spokes/ and run deploy.sh
          for dir in ''${ROOTDIR}/terraform/spokes/*/; do
            if [[ -d "$dir" && -f "''${dir}deploy.sh" ]]; then
              echo "Running deploy.sh in $dir"
              chmod +x "''${dir}deploy.sh"
              "''${dir}deploy.sh"
            else
              echo "Skipping $dir, no deploy.sh found"
            fi
          done
        '')
      ];
      nativeBuildInputs = with pkgs; [
        
      ];

      shellHook = ''
      set -a
      source ./secrets.env
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
