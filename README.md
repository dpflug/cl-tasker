# cl-tasker

This is a Common Lisp library for [Tasker](https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm) users. I don't know how many Tasker users know/are willing to learn Lisp, but if nothing else, I want to stop fiddling with my tiny touch screen to script my phone.

If you've not seen Tasker, go check it out. It's well worth the $3.

## So, what does it do?

It turns this:
```lisp
(task "Hello World"
 (flash "Yo!" :label "foo" :if (~ "%bar" "baz"))
```

Into this:
```XML
<TaskerData sr="" dvi="1" tv="1.6u2">
  <Task sr="task47">
    <cdate>1409519732766</cdate>
    <edate>1409593553574</edate>
    <id>47</id>
    <nme>Hello World</nme>
    <Action sr="act0" ve="3">
      <code>548</code>
      <lhs>%bar</lhs>
      <op>1</op>
      <rhs>baz</rhs>
      <label>foo</label>
      <Str sr="arg0" ve="3">yo</Str>
      <Int sr="arg1" val="0"></Int>
    </Action>
  </Task>
</TaskerData>
'''

## So, how much is done?

Um, not even as much as shown. I'm working on it. :)

So far, I can create actions with `(action <its ActionCode> <other-stuff (args, if clauses, labels, etc)>)`. Tasks and Profiles are on my to-do.