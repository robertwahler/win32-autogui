Cloning from BasicGem
=====================

BasicGem provides no stand-alone functionality.  Its purpose is to 
provide a repository for jump-starting a new RubyGem and provide 
a repository for cloned applications to pull future enhancements and fixes.


Features/Dependencies 
---------------------

* Rspec for unit testing http://github.com/dchelimsky/rspec
* Cucumber for functional testing http://github.com/aslakhellesoy/cucumber
* Aruba for CLI testing http://github.com/aslakhellesoy/aruba


Jump-starting a new project with BasicGem
-----------------------------------------

The following steps illustrate creating a new application called "mutagem." 
See http://github.com/robertwahler/mutagem for full source.

    cd ~/workspace
    git clone git://github.com/robertwahler/basic_gem.git mutagem
    cd mutagem


Setup repository for cloned project
-----------------------------------

We are going to change the origin URL to our own server and setup a remote
for pulling in future BasicGem changes. If our own repo is setup at
git@red:mutagem.git, change the URL with sed:

    sed -i 's/url =.*\.git$/url = git@red:mutagem.git/' .git/config

Allow Gemlock.lock to be stored in the repo

    sed -i 's/Gemfile\.lock$//' .gitignore

Push it up

    git push origin master:refs/heads/master

Add BasicGem as remote

    git remote add basic_gem git://github.com/robertwahler/basic_gem.git


Rename your gem
---------------

We need to change the name of the gem from basic_gem to mutagem

    git mv bin/basic_gem bin/mutagem
    git mv lib/basic_gem.rb lib/mutagem.rb
    git mv lib/basic_gem lib/mutagem

    # BasicGem => Mutagem
    find ./bin -type f -exec sed -i 's/BasicGem/Mutagem/' '{}' +
    find . -name *.rb -exec sed -i 's/BasicGem/Mutagem/' '{}' +
    find . -name Rakefile -exec sed -i 's/BasicGem/Mutagem/' '{}' +
    # basic_gem => mutagem
    find ./bin -type f -exec sed -i 's/basic_gem/mutagem/' '{}' +
    find ./spec -type f -exec sed -i 's/basic_gem/mutagem/' '{}' +
    find . -name *.rb -exec sed -i 's/basic_gem/mutagem/' '{}' +
    find . -name *.feature -exec sed -i 's/basic_gem/mutagem/' '{}' +
    find . -name Rakefile -exec sed -i 's/basic_gem/mutagem/' '{}' +

Replace TODO's and update documentation

* Replace README.rdoc
* Replace LICENSE
* (OPTIONAL) git rm CLONING.rdoc
* Replace the TODO's in Rakefile and bin

Gem should now be functional, lets test it

    rake spec
    rake features

Looks OK, commit it

    git commit -a -m "renamed basic_gem to mutagem"


Merging future BasicGem changes
-------------------------------

Cherry picking method

    git fetch basic_gem
    git cherry-pick a0f9745

Merge 2-step method

    git fetch basic_gem
    git merge basic_gem/master

Trusting pull of HEAD

    git pull basic_gem HEAD

Conflicted?

    git mergetool
    git commit


Copyright
---------

Copyright (c) 2010 GearheadForHire, LLC. See LICENSE for details.
