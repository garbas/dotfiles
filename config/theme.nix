{ lib
, runCommand 
, writeScript
, base16-builder
, scheme ? "default"
, templates ? []
}:

let
  self = runCommand
    "base16-build-${scheme}"
    { buildInputs = [ base16-builder ];
      passthru.environment_etc = lib.flatten (map (x:
        [ { source = "${self}/${x}.${scheme}.dark";
            target = "base16/${x}.dark";
          }
          { source = "${self}/${x}.${scheme}.light";
            target = "base16/${x}.light";
          }
        ]
      ) templates);
    }
    ''
      mkdir $out

      for template in ${builtins.concatStringsSep " " templates}; do
        base16-builder -s ${scheme} -t $template -b light > $out/$template.light
        base16-builder -s ${scheme} -t $template -b dark  > $out/$template.dark
      done
    '';

in self
