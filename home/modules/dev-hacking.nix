{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # binwalk
      ghidra-bin
      ghidra-extensions.lightkeeper
      ghidra-extensions.machinelearning
      ghidra-extensions.ghidra-golanganalyzerextension
      ghidra-extensions.ret-sync
      ghidra-extensions.findcrypt
      ghidra-extensions.ghidra-delinker-extension
      ghidra-extensions.wasm
      ghidra-extensions.gnudisassembler
      # ghidra-extensions.ghidraninja-ghidra-scripts
      ghidra-extensions.ghidra-firmware-utils
      ghidra-extensions.sleighdevtools
      ghidra-extensions.kaiju
    ];

    sessionVariables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
