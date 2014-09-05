(asdf:defsystem #:cl-tasker
  :name "cl-tasker"
  :author "David Pflug <david@pflug.email>"
  :maintainer "David Pflug <david@pflug.email"
  :description "Generator of Tasker XML files"
  :long-description "This is a package to help you create XML files that Tasker will import, so you can create projects, profiles, and tasks without fiddling with buttons and typing on a small touch screen."
  :depends-on (#:xml-emitter)
  :components ((:file "tasker")))
