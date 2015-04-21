{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  name = "ttf-bitstream-vera-for-powerline-2354337";                      
  src = fetchgit {                                                   
      url = "https://gist.github.com/1695735.git";                        
      rev = "94d914017f1073b2f9b4c4045437bb5e8cf2a5ab";                   
      sha256 = "0131pgd62z7g1kxkydy7mxxsaya73rpinjf3haabmzvgcglv25j0";                
  };                                                                      
  buildPhase = "true";                                                    
  installPhase = "                                                        
      fontDir=$out/share/fonts/truetype                                   
      mkdir -p $fontDir                                                   
      cp *.ttf $fontDir                                                   
  ";                                                                      
}                       
