Gemspec fields
==============

- original_platform


Questions
=========
- has a LICENSE file but no 'licenses' set
- no description
- no summary
- description and summary are the same

Data Quality
============
- Authors that are CSV's instead of Arrays
- Duplicated Authors in the authors fied
- Emails that are CSV's instead of Arrays
- Duplicated emails in the emails field
- Non-UTF8 characters in gem specifications
- Platform that attempts to include ruby version
  - s.version = "0.0.2" s.platform = %q{x86-mingw32-1.9.1}
  - s.version = "0.0.2" s.platform = %q{x86-mingw32-1.9.2}

Bugs?
=====
- riskman 0.22 gem has a Float version, that when .to_s is called returns a
  Float, this results in the inability to test for prerelease


