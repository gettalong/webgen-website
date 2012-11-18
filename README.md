# Source of the webgen website

This is the source for the webgen website at
<http://webgen.rubyforge.org>.

It shows how easy it is to create a website using [webgen] and showcases
many of its features, like

* automatic generation of multiple menus,
* dynamic content using webgen tags and ERB,
* fast generation due to intelligent item tracking and partial
  re-generation and
* easy use of extension bundles.


# Generating the website

You need to install [webgen], [webgen-sass_twitter_bootstrap-bundle][1] and
[webgen-font_awesome-bundle][2]:

<pre>
$ <b>gem install webgen</b>
$ <b>gem install webgen-sass_twitter_bootstrap-bundle</b>
$ <b>gem install webgen-font_awesome-bundle</b>
</pre>

After that just change into the website directory and run

<pre>
$ <b>webgen</b>
</pre>

[webgen]: http://webgen.rubyforge.org
[1]: https://github.com/gettalong/webgen-sass_twitter_bootstrap-bundle
[2]: https://github.com/gettalong/webgen-font_awesome-bundle
