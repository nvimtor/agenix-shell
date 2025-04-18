{
  config,
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
    callFlake = src:
      lib.fix (flake:
        (import src).outputs (inputs
          // {
            self = flake // {inherit inputs;};
            agenix-shell = config.flake;
          }));

    templateCheck = {
      template,
      flakeSrc ? "${templateSrc}/flake.nix",
      templateSrc ? template.path,
      ...
    } @ args:
      pkgs.callPackage ./template-check.nix (builtins.removeAttrs args ["flakeSrc" "template" "templateSrc"]
        // {
          src = templateSrc;
          flake = callFlake flakeSrc;
        });
  in {
    checks = {
      flake-parts-template = templateCheck {
        template = config.flake.templates.flake-parts;
      };

      basic-template = templateCheck {
        template = config.flake.templates.basic;
      };
    };
  };
}
