BasicGem
========

An opinionated RubyGem structure. BasicGem provides no stand-alone functionality.  
Its purpose is to provide a repository for jump-starting a new RubyGem and provide 
a repository for cloned applications to pull future enhancements and fixes.


Features/Dependencies 
---------------------

* Bundler for dependency management [http://github.com/carlhuda/bundler](http://github.com/carlhuda/bundler)
* Rspec for unit testing [http://github.com/dchelimsky/rspec](http://github.com/dchelimsky/rspec)
* Cucumber for functional testing [http://github.com/aslakhellesoy/cucumber](http://github.com/aslakhellesoy/cucumber)
* Aruba for CLI testing [http://github.com/aslakhellesoy/aruba](http://github.com/aslakhellesoy/aruba)
* YARD for documentation generation [http://github.com/lsegal/yard/wiki](http://github.com/lsegal/yard/wiki)


Jump-starting a new gem with BasicGem
-----------------------------------------

The following steps illustrate creating a new gem called "mutagem" that handles file based mutexes.
See [http://github.com/robertwahler/mutagem](http://github.com/robertwahler/mutagem) for full source.

    cd ~/workspace
    git clone git://github.com/robertwahler/basic_gem.git mutagem
    cd mutagem


Setup repository for cloned project
-----------------------------------

We are going to change the origin URL to our own server and setup a remote
for pulling in future BasicGem changes. If our own repo is setup at
git@red:mutagem.git, change the URL with sed:

    sed -i 's/url =.*\.git$/url = git@red:mutagem.git/' .git/config

Push up the unchanged BasicGem repo

    git push origin master:refs/heads/master

Allow Gemlock.lock to be stored in the repo

    sed -i '/Gemfile\.lock$/d' .gitignore

Add BasicGem as remote

    git remote add basic_gem git://github.com/robertwahler/basic_gem.git


Rename your gem
---------------

We need to change the name of the gem from basic_gem to mutagem

    git mv lib/basic_gem.rb lib/mutagem.rb
    git mv lib/basic_gem lib/mutagem
    git mv basic_gem.gemspec mutagem.gemspec

    # BasicGem => Mutagem
    find . -name *.rb -exec sed -i 's/BasicGem/Mutagem/' '{}' +
    find . -name *.feature -exec sed -i 's/BasicGem/Mutagem/' '{}' +
    sed -i 's/BasicGem/Mutagem/' Rakefile
    sed -i 's/BasicGem/Mutagem/' mutagem.gemspec

    # basic_gem => mutagem
    find ./spec -type f -exec sed -i 's/basic_gem/mutagem/' '{}' +
    find . -name *.rb -exec sed -i 's/basic_gem/mutagem/' '{}' +
    find . -name *.feature -exec sed -i 's/basic_gem/mutagem/' '{}' +
    sed -i 's/basic_gem/mutagem/' Rakefile
    sed -i 's/basic_gem/mutagem/' mutagem.gemspec


Replace TODO's and update documentation
---------------------------------------

* Replace README.markdown
* Replace LICENSE
* Add author information and replace the TODO's in gemspec


Gem should now be functional
---------------------------

    rake spec
    rake features


Setup git copy-merge
--------------------
When we merge future basic_gem changes to our new gem, we want to always ignore 
some upstream documentation file changes.  

Set the merge type for the files we want to ignore in .git/info/attributes. You
could specify .gitattributes instead of .git/info/attributes but then if your
new gem is forked, your forked repos will miss out on document merges.

    echo "README.markdown merge=keep_local_copy" >> .git/info/attributes
    echo "HISTORY.markdown merge=keep_local_copy" >> .git/info/attributes
    echo "TODO.markdown merge=keep_local_copy" >> .git/info/attributes
    echo "LICENSE merge=keep_local_copy" >> .git/info/attributes


Setup the copy-merge driver. The "trick" is that the driver, keep_local_copy, is using 
the shell command "true" to return exit code 0.  Basically, the files marked with
the keep_local_copy merge type will always ignore upstream changes.

    git config merge.keep_local_copy.name "always keep the local copy during merge"
    git config merge.keep_local_copy.driver "true"


Commit
------

    git add Gemfile.lock
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


Rake tasks
----------

rake -T

    rake build         # Build mutagem-0.0.1.gem into the pkg directory
    rake doc:clean     # Remove generated documenation
    rake doc:generate  # Generate YARD Documentation
    rake features      # Run Cucumber features
    rake install       # Build and install mutagem-0.0.1.gem into system gems
    rake release       # Create tag v0.0.1 and build and push mutagem-0.0.1.gem to Rubygems
    rake spec          # Run specs
    rake test          # Run specs and features


Copyright
---------

Copyright (c) 2010 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.
