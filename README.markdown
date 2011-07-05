BasicGem
========

An opinionated RubyGem structure. BasicGem provides no stand-alone functionality.  Its purpose is
to provide a repository for jump-starting a new RubyGem and provide a repository for cloned
applications to pull future enhancements and fixes.


Features/Dependencies
---------------------

* Bundler for dependency management <http://github.com/carlhuda/bundler>
* Rspec for unit testing <http://github.com/dchelimsky/rspec>
* Cucumber for functional testing <http://github.com/aslakhellesoy/cucumber>
* Aruba for CLI testing <http://github.com/aslakhellesoy/aruba>
* YARD for documentation generation <http://github.com/lsegal/yard>
* Kramdown for documentation markup processing <https://github.com/gettalong/kramdown>


Jump-starting a new gem with BasicGem
-----------------------------------------
The following steps illustrate creating a new gem called "mutagem" that handles file based mutexes.
See <http://github.com/robertwahler/mutagem> for full source.

**NOTE:** _We are cloning from [BasicGem](http://github.com/robertwahler/basic_gem) directly.  Normally, you will want to clone from your own fork of BasicGem so that you can control and fine-tune which future BasicGem modifications you will support._

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

Allow Gemlock.lock and .gemfiles to be stored in the repo

    sed -i '/Gemfile\.lock$/d' .gitignore
    sed -i '/\.gemfiles$/d' .gitignore

Add BasicGem as remote

    git remote add basic_gem git://github.com/robertwahler/basic_gem.git


Rename your gem
---------------

Change the name of the gem from basic_gem to mutagem.  Note that
renames will be tracked in future merges since Git is tracking content and
the content is non-trivial.

    git mv lib/basic_gem.rb lib/mutagem.rb
    git mv basic_gem.gemspec mutagem.gemspec

    # commit renames now
    git commit -m "rename basic_gem files"

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
* Replace HISTORY.markdown
* Replace TODO.markdown
* Replace LICENSE
* Replace VERSION
* Modify .gemspec, add author information and replace the TODO's


Gem should now be functional
---------------------------

    bundle exec rake spec
    bundle exec rake features


Setup git copy-merge
--------------------
When we merge future BasicGem changes to our new gem, we want to always ignore
some upstream documentation file changes.

Set the merge type for the files we want to ignore in .git/info/attributes. You
could specify .gitattributes instead of .git/info/attributes but then if your
new gem is forked, your forked repos will miss out on document merges.

    echo "README.markdown merge=keep_local_copy" >> .git/info/attributes
    echo "HISTORY.markdown merge=keep_local_copy" >> .git/info/attributes
    echo "TODO.markdown merge=keep_local_copy" >> .git/info/attributes
    echo "LICENSE merge=keep_local_copy" >> .git/info/attributes
    echo "VERSION merge=keep_local_copy" >> .git/info/attributes


Setup the copy-merge driver. The "trick" is that the driver, keep_local_copy, is using
the shell command "true" to return exit code 0.  Basically, the files marked with
the keep_local_copy merge type will always ignore upstream changes if a merge conflict occurs.

    git config merge.keep_local_copy.name "always keep the local copy during merge"
    git config merge.keep_local_copy.driver "true"


Commit
------

    git add Gemfile.lock
    git commit -a -m "renamed basic_gem to mutagem"


Add code to project's namespace
-------------------------------

    mkdir lib/mutagem
    vim lib/mutagem/mutex.rb


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

Conflict resolution

*NOTE: Most conflicts can be resolved with 'git mergetool' but 'CONFLICT (delete/modify)' will
need to be resolved by hand.*

    git mergetool
    git commit


Rake tasks
----------

bundle exec rake -T

    rake build         # Build mutagem-0.0.1.gem into the pkg directory
    rake doc:clean     # Remove generated documenation
    rake doc:generate  # Generate YARD Documentation
    rake features      # Run Cucumber features
    rake install       # Build and install mutagem-0.0.1.gem into system gems
    rake release       # Create tag v0.0.1 and build and push mutagem-0.0.1.gem to Rubygems
    rake spec          # Run specs
    rake test          # Run specs and features


Autotesting with Watchr
-------------------------

[Watchr](http://github.com/mynyml/watchr) provides a flexible alternative to Autotest.  A
jump start script is provided in spec/watchr.rb.

### Install watchr ###

    gem install watchr

### Run watchr ###

    watchr spec/watchr.rb

outputs a menu

    Ctrl-\ for menu, Ctrl-C to quit

Watchr will now watch the files defined in 'spec/watchr.rb' and run Rspec or Cucumber, as appropriate.
The watchr script provides a simple menu.

Ctrl-\

    MENU: a = all , f = features  s = specs, l = last feature (none), q = quit


Copyright
---------

Copyright (c) 2010-2011 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.
