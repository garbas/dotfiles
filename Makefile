FOLDERS=$$HOME/.*

create: clear
	ln -s `pwd`/weechat $$HOME/.weechat

clear:
	@for j in $$HOME/.*; do \
		if [[ `realpath $$j` == `pwd`* ]]; then \
			rm $$j; \
		fi; \
	done; \
