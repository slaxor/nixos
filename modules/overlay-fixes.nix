# Temporary build fixes for nixpkgs regressions; drop once upstream catches up.
{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      clipcat = prev.clipcat.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          find . -name Cargo.toml -exec sed -i -E \
          '/^(no_mangle_generic_items|repr_transparent_non_zst_fields|elided_lifetimes_in_associated_constant)[[:space:]]*=/d' {} +
        '';
      });
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyfinal: pyprev: {
          reuse = pyprev.reuse.overridePythonAttrs (old: {
            outputs = builtins.filter (o: o != "man") old.outputs;
          });
        })
      ];
    })
  ];
}
