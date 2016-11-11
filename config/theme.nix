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
    }
    ''
      mkdir $out tmp-home
      export HOME=$PWD/tmp-home
      for template in ${builtins.concatStringsSep " " templates}; do
        base16-builder -s ${scheme} -t $template -b light > $out/$template.light
        base16-builder -s ${scheme} -t $template -b dark  > $out/$template.dark
      done
    '';

in self
