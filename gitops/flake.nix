{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        scaleDownMedia = pkgs.writeShellScriptBin "scale-down-media" ''
          #!/usr/bin/env bash
          set -euo pipefail
          echo "Scaling all deployments in 'media' namespace to 0 replicas..."
          kubectl -n media get deploy -o json |
            jq -r '.items[].metadata.name' |
            xargs -I{} kubectl -n media scale deploy {} --replicas=0
        '';

        listMediaReplicas = pkgs.writeShellScriptBin "list-media-replicas" ''
          #!/usr/bin/env bash
          set -euo pipefail
          echo "Saving current replicas of all deployments in 'media'..."
          kubectl -n media get deploy -o json |
            jq -r '.items[] | "\(.metadata.name): \(.spec.replicas)"' > media-replicas.txt
          echo "Saved to media-replicas.txt"
        '';

        scaleUpMedia = pkgs.writeShellScriptBin "scale-up-media" ''
          #!/usr/bin/env bash
          set -euo pipefail

          SNAPSHOT_FILE="media-replicas.txt"

          if [[ ! -f "$SNAPSHOT_FILE" ]]; then
            echo "Snapshot file '$SNAPSHOT_FILE' not found. Run list-media-replicas first." >&2
            exit 1
          fi

          while IFS=":" read -r name replicas; do
            name=$(echo "$name" | xargs)
            replicas=$(echo "$replicas" | xargs)
            echo "Scaling $name to $replicas replicas..."
            kubectl -n media scale deploy "$name" --replicas="$replicas"
          done < "$SNAPSHOT_FILE"
        '';
      in {
        packages.default = pkgs.buildEnv {
          name = "media-tools";
          paths = [ scaleDownMedia listMediaReplicas scaleUpMedia ];
        };

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
            jq
          ] ++ [ scaleDownMedia listMediaReplicas scaleUpMedia ];

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
