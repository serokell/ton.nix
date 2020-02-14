# SPDX-FileCopyrightText: 2019 Serokell <https://serokell.io>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, lib, config, ... }:
let
  cfg = config.services.ton;
  server_config = {
    control = [{
      id = "@SERVER_B64@";
      port = cfg.ports.console;
      allowed =
        lib.mapAttrsToList (id: permissions: { inherit id permissions; })
          cfg.allowed_clients;
    }];
    liteservers = [{
      id = "@LITE_B64@";
      port = cfg.ports.lite;
    }];
  };
  config_merge_template =
    builtins.toFile "ton_config.json" (builtins.toJSON server_config);
in {
  options.services.ton = with lib; {
    enable = mkEnableOption "ton";
    ports.main = mkOption {
      example = 29108;
      type = types.port;
    };
    ports.console = mkOption {
      example = 29109;
      type = types.port;
    };
    ports.lite = mkOption {
      example = 29110;
      type = types.port;
    };
    allowed_clients = mkOption {
      example = { "jLl01+sOhXSANIe7kGtI/1mEYZTOf9YdzhzyDBnspVo=" = 15; };
      type = types.attrsOf types.int;
      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.ton pkgs.jq ];
    systemd.services.ton-full = {
      path = with pkgs; [ ton gawk curl jq ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "ton";
        RuntimeDirectory = "ton";
        Type = "simple";
        WorkingDirectory = "/var/lib/ton";
        ExecStart =
          "${pkgs.ton}/bin/validator-engine -C /var/lib/ton/etc/ton-global.config.json --db /var/lib/ton/db";
      };
      environment.HOME = "/var/lib/ton";
      # see https://test.ton.org/FullNode-HOWTO.txt
      preStart = ''
        mkdir -p etc db db/keyring
        if [ ! -e etc/ton-global.config.json ]; then
          curl https://test.ton.org/ton-global.config.json > etc/ton-global.config.json
        fi
        IP=$(curl https://ifconfig.me)
        rm -f db/config.json
        validator-engine -C $HOME/etc/ton-global.config.json --db $HOME/db --ip $IP:${
          toString cfg.ports.main
        }
        if [ ! -e server_id ]; then
          echo "generating server key"
          generate-random-id -m keys -n server | tee server_id
          mv server db/keyring/$(awk '{print $1}' server_id)
        fi
        SERVER_B64=$(awk '{print $2}' server_id)
        echo "server key | base64:"
        base64 server.pub
        if [ ! -e lite_id ]; then
          generate-random-id -m keys -n lite | tee lite_id
          mv lite db/keyring/$(awk '{print $1}' lite_id)
        fi      
        echo "lite key | base64:"
        base64 lite.pub
        LITE_B64=$(awk '{print $2}' lite_id)
        cp server.pub lite.pub /run/ton
        sed -e "s/@SERVER_B64@/$SERVER_B64/g" -e "s/@LITE_B64@/$LITE_B64/g" < ${config_merge_template} > config_merge.json
        mv db/config.json config_generated.json
        jq -s '.[0] * .[1]' config_generated.json config_merge.json > db/config.json
      '';
    };
  };
}
