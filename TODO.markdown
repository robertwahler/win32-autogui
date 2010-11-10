TODO
====

general
-------

* (1.0) stop changing $LOAD_PATH in specs and features, modify ENV[] in before and afters
* (1.0) implement Application.find and add option to not start application automatically, allows driving already running applications
* (1.0) application class should be a mixin, not classical inheritance 
* (1.0) "rake release" broken on Windows, create patch to fix Bundler.  For now, 'git tag v0.3.0 && rake build && gem push pkg/win32-autogui-0.3.0.gem'
* (1.0) unicode support for window text
