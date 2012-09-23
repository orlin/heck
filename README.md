# heck -- for http errors handling on node


## What

    Sometimes errors happen.
    Being humorous about it,
    or making them pretty,
    is what the heck does.


## Why

I like [isaacs/error-page](https://github.com/isaacs/error-page)
and [c9/vfs-http-adapter](http://github.com/c9/vfs-http-adapter).
This `heck` lets me use the former as an `errorHandler` for the latter.
It also adds a few configuration extras, such as debug info for `development`.


## Example

See this
[web app](https://github.com/astrolet/astrolin/blob/active/web/app.coffee)
for example use.


## Tests

[![Build Status](https://secure.travis-ci.org/astrolet/astrolin.png)](http://travis-ci.org/astrolet/astrolin)

Actually, there are no tests yet.

However [astrolin.org](http://github.com/astrolet/astrolin) and other web apps
do use `heck` and test for some errors. So, if the above build status is green
then `heck` is working. If it's red, it's not for sure that the issue is
with `heck`.


## Unlicense

This is free and unencumbered public domain software.
For more information, see <http://unlicense.org/> or the accompanying
[UNLICENSE](http://astrolet.github.com/there/UNLICENSE.html) file.

