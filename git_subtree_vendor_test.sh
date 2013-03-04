#!/bin/sh

set -e

state=$(git update-index -q --refresh; test -z "$(git diff-index --name-only HEAD --)" || echo -dirty)
branch_name=$(git rev-parse --abbrev-ref HEAD)

echo $(git config --get remote.github.url)/$branch_name@$(git rev-parse --short=7 HEAD)

root=/tmp
tmpdir=git_subtree_test_scratch_$(date +%Y%m%d%H%m%s)
scratch=$root/$tmpdir

mkdir -p $scratch

cd $scratch

rm -rf myproject
mkdir myproject
cd myproject
git init
echo test_mp >test_mp.txt
git add test_mp.txt
git commit -am "Add test_mp.txt"

cd $scratch

proj=myproject
git clone --bare $scratch/$proj
cd $scratch/$proj
git remote add origin $scratch/$proj.git
cp $scratch/$proj.git/hooks/post-update.sample \
    $scratch/$proj.git/hooks/post-update
chmod +x $scratch/$proj.git/hooks/post-update
perl -i.bak -pe 's{exec git-update-server-info}{exec git\
	 update-server-info}' $scratch/$proj.git/hooks/post-update
git push --set-upstream origin master

cd $scratch

rm -rf vendor
mkdir vendor
cd vendor
git init
echo test_v >test_v.txt
git add test_v.txt
git commit -am "Add test_v.txt"

cd $scratch

proj=vendor
git clone --bare $scratch/$proj
cd $scratch/$proj
git remote add origin $scratch/$proj.git
cp $scratch/$proj.git/hooks/post-update.sample \
    $scratch/$proj.git/hooks/post-update
chmod +x $scratch/$proj.git/hooks/post-update
perl -i.bak -pe 's{exec git-update-server-info}{exec git \
	update-server-info}' $scratch/$proj.git/hooks/post-update
git push --set-upstream origin master

# Add vendor to myproject

cd $scratch/myproject
git remote add vendor_remote $scratch/vendor.git
git fetch vendor_remote
git checkout -b vendor_branch vendor_remote/master
git checkout master
git read-tree -u vendor_branch --prefix=vendor/
git commit -am "Add vendor branch"
git push

# modify vendor file in myproject

cd $scratch/myproject
git checkout master ||:
echo edit from myproject >>vendor/test_v.txt
git commit -am "Add stuff to myproject now and we'll need to push to \
vendor later"
git push

# it should work the other way too, but I'm getting conflict when trying
# to push

git checkout vendor_branch
git merge --squash -s subtree --no-commit master
