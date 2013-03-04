# usage: make alias && source ./alias && make

# practice commiting to parent and getting those changes back into the
# vendor branch.

# See here:
# http://git-scm.com/book/en/Git-Tools-Subtree-Merging
# http://posterous.timocracy.com/git-sub-tree-merging-back-to-the-subtree-for

test:
	sh -x git_subtree_vendor_test.sh

alias: alias.tmpl
	@echo alias \'h=cd $(CURDIR)\' >$@
	@echo alias \'c=cd $(CURDIR) \&\& make clean\' >>$@
	@cat alias.tmpl >>$@
.PHONY: alias

clean:
	rm -rf /tmp/git_subtree_test_scratch_*
	rm -f alias
