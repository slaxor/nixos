{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    xkbcomp
  ];

  # xkbcomp $DISPLAY - | less

  services.xserver.xkb.extraLayouts.us-german-umlaut = {
    description = "English (US, international with German umlaut)";
    languages = [
      "eng"
      "deu"
    ];

    # §	section
    # °	degree
    # €	EuroSign
    # µ	mu or Greek_mu
    # π	Greek_pi
    # λ	Greek_lambda
    # α	Greek_alpha
    # β	Greek_beta
    # ∞	infinity
    # ≠	notequal
    # ≤	lessthanequal
    # ≥	greaterthanequal
    # | XKB key  | Physical key |
    # | -------- | ------------ |
    # | `<AD01>` | Q            |
    # | `<AD02>` | W            |
    # | `<AD03>` | E            |
    # | `<AD04>` | R            |
    # | `<AC01>` | A            |
    # | `<AC02>` | S            |
    # | `<AB01>` | Z            |

    # | Prefix | Row        |
    # | ------ | ---------- |
    # | `AE`   | number row |
    # | `AD`   | QWERTY row |
    # | `AC`   | ASDF row   |
    # | `AB`   | ZXCV row   |

    # | Key      | Meaning          |
    # | -------- | ---------------- |
    # | `<AE05>` | number-row 5 key |
    # | `<AD10>` | P key            |
    # | `<AC04>` | F key            |
    # | `<AB07>` | M key            |

    # [ a, A, adiaeresis, Adiaeresis ]

    # | Level       | Produced |
    # | ----------- | -------- |
    # | normal      | `a`      |
    # | Shift       | `A`      |
    # | AltGr       | `ä`      |
    # | Shift+AltGr | `Ä`      |

    symbolsFile = pkgs.writeText "us-german-umlaut" ''
      default partial alphanumeric_keys
      xkb_symbols "basic" {
        include "us(altgr-intl)"
        include "level3(caps_switch)"
        name[Group1] = "English (US, international with German umlaut)";
        key <AB07> { [ m, M, Greek_mu, Greek_MU ] };
        key <AC01> { [ a, A, adiaeresis, Adiaeresis ] };
        key <AC02> { [ s, S, ssharp ] };
        key <AC03> { [ d, D, Greek_delta, Greek_DELTA ] };
        key <AC04> { [ f, F, Greek_phi, Greek_PHI ] };
        key <AC05> { [ g, G, Greek_gamma, Greek_GAMMA ] };
        key <AD02> { [ w, W, Greek_omega, Greek_OMEGA ] };
        key <AD03> { [ e, E, EuroSign, cent ] };
        key <AD05> { [ t, T, Greek_theta, Greek_THETA ] };
        key <AD07> { [ u, U, udiaeresis, Udiaeresis ] };
        key <AD09> { [ o, O, odiaeresis, Odiaeresis ] };
        key <AD10> { [ p, P, Greek_pi, Greek_PI ] };
        key <AE05> { [ 5, percent, EuroSign, Greek_epsilon ] };
      };
    '';
  };
}
