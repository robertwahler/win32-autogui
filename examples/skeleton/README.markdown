Skeleton README
===============

This is a template of the file structure needed for jump-starting
GUI testing with the Win32-autogui RubyGem.


Usage Example
=============
Create a new Win32 application testing structure for the binary quicknote.exe.

NOTE: Replace 'quicknote' with the name of your application.

get the source for Win32-autogui

    cd ~/workspace
    git clone git://github.com/robertwahler/win32-autogui.git

copy the skeleton example to a new folder 'quicknote'

    cp -r ~/workspace/win32-autogui/examples/skeleton quicknote

check it into SCM

    cd quicknote
    git init
    git add .
    git commit -m "initial commit"

rename skeleton app to 'quicknote'

    git mv lib/myapp.rb lib/quicknote.rb
    git mv spec/myapp spec/quicknote

    # MyApp => QuickNote
    find . -name *.rb -exec sed -i -b 's/MyApp/QuickNote/' '{}' +

    # Myapp => Quicknote
    find . -name *.rb -exec sed -i -b 's/Myapp/Quicknote/' '{}' +

    # myapp => quicknote
    find . -name *.rb -exec sed -i -b 's/myapp/quicknote/' '{}' +

customize docs

    vim README.markdown LICENSE

test it

    bundle install
    bundle exec rake spec
    bundle exec rake features

commit it

    git add .
    git commit -m "renamed skelton app to MyApp"


Copyright
---------

Copyright (c) 2010 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.
