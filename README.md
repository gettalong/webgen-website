# Source of the webgen website

This is the source for the webgen website at
<http://webgen.gettalong.org>.

It shows how easy it is to create a website using [webgen] and showcases
many of its features, like

* automatic generation of multiple menus,
* dynamic content using webgen tags and ERB,
* fast generation due to intelligent item tracking and partial
  re-generation and
* easy use of extension bundles.


# Generating the website

You need to install [webgen], the needed libraries as well as the
extension bundles [webgen-zurb_foundation-bundle][1] and
[webgen-font_awesome-bundle][2]:

<pre>
$ <b>gem install webgen</b>
$ <b>gem install archive-tar-minitar coderay erubis haml</b>
$ <b>gem install maruku rdiscount rdoc RedCloth sass</b>
$ <b>gem install webgen-zurb_foundation-bundle</b>
$ <b>gem install webgen-font_awesome-bundle</b>
</pre>

Then clone this repository and the repository for webgen (needed as
source for the automatic API generation):

<pre>
$ <b>git clone https://github.com/gettalong/webgen-website.git</b>
$ <b>git clone https://github.com/gettalong/webgen.git</b>
</pre>

After that just change into the `webgen-website/` directory and run

<pre>
$ <b>webgen</b>
</pre>

The generated website is written to the `out/` directory. Opening the
`out/index.html` file in any browser will show it. Since all links are
relative, no web server is needed!

[webgen]: http://webgen.gettalong.org
[1]: https://github.com/gettalong/webgen-zurb_foundation-bundle
[2]: https://github.com/gettalong/webgen-font_awesome-bundle
