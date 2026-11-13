# Temporary build fixes for nixpkgs regressions; drop once upstream catches up.
{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
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
