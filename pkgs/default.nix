{ pkgs ? import <nixpkgs> {}
}:
{ 
  weechat = pkgs.weechat.override {
    extraBuildInputs = [ pkgs.pythonPackages.websocket_client ];
  };

  ttf_bitstream_vera = pkgs.callPackage ./ttf_bitstream_vera {
    inherit (pkgs) stdenv fetchgit;
  };

  neovim = pkgs.neovim.override {
    vimAlias = true;
    configure = {
      customRC = ''
        if has('nvim')
          tnoremap <Esc> <C-\><C-n>
          tnoremap <C-h> <C-\><C-n><C-w>h
          tnoremap <C-j> <C-\><C-n><C-w>j
          tnoremap <C-k> <C-\><C-n><C-w>k
          tnoremap <C-l> <C-\><C-n><C-w>l
          autocmd BufWinEnter,WinEnter term://* startinsert
          autocmd BufLeave term://* stopinsert
        endif

        let mapleader = "\<Space>"
        let maplocalleader = ","

        let g:ctrlp_dont_split = 'NERD_tree_2'
        let g:ctrlp_extensions = ['undo', 'bookmarkdir', 'funky']
        let g:ctrlp_jump_to_buffer = 0
        let g:ctrlp_map = '<leader><leader>'
        let g:ctrlp_match_window_reversed = 1
        let g:ctrlp_max_height = 20
        let g:ctrlp_open_new_file = 'v'
        let g:ctrlp_open_multiple_files = '2vjr'
        let g:ctrlp_split_window = 0
        let g:ctrlp_working_path_mode = 'ra'
        let g:ctrlp_follow_symlinks = 1

        nnoremap <leader>b :CtrlPBuffer<cr>
        nnoremap <leader>B :CtrlPBookmarkDir<cr>
      '';
      vam.pluginDictionaries = [
        { names = [ "ctrlp" "youcompleteme" "vim-airline" ]; }
      ];
    };
  };
}

#pkgs.buildEnv {
#  name = "dotfiles";
#  paths = with pkgs; [
#    (vim_configurable.customize {
#      name = "vim-garbas";
#      vimrcConfig = {
#        customRC = ''
#          set hidden
#        '';
#        vam.knownPlugins = pkgs.vimPlugins;
#        vam.pluginDictionaries = [
#          { names = [
#              "youcompleteme"
#              "ctrlp"
#            ];
#          }
#        ];
#      };
#    })
#  ];
#}
