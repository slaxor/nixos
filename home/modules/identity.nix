{ lib, ... }:
{
  options.me.identity = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Primary full name";
    };

    email = lib.mkOption {
      type = lib.types.str;
      description = "Primary email address";
    };

    unixuser = lib.mkOption {
      type = lib.types.str;
      description = "The username for unix systems";
    };

    netuser = lib.mkOption {
      type = lib.types.str;
      description = "The username for the outside";
    };
  };
}
