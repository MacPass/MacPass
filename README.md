####Why?
The point of this branch is to make a nice looking website that might attract users and give a very general overview of MacPass plus links.

####Some things that aren't done yet include:
* making the site *completely* mobile friendly

####Environment Setup
* This project uses [Jekyll](http://jekyllrb.com/) for site generation and is hosted by [Github](http://www.github.com) using [Github Pages](https://pages.github.com/). There are several dependencies to get ready for development.

1. This project uses [RVM](https://rvm.io/) for ruby and gem version management. To install RVM execute <pre class="code code-shell-cmd" title="triple click to select command">\curl -sSL https://get.rvm.io | bash -s stable</pre> At the time of this writing the stable version of ruby is 2.1.2 which is the version that this project uses.

2. Next clone this repo and cd into the cloned directory. By default it will clone as MacPass.

3. This project uses [bundler](http://bundler.io/) to manage the projects dependencies. To install bundler run <pre class="code code-shell-cmd">gem install bundler</pre> You should see something similar to "Successfully installed bundler-1.7.2" amongst several other successfully installed dependencies.

4. We now need to install all the projects dependencies using bundler. Execute <pre class="code code-shell-cmd">bundle install</pre> and once that is complete everything that is needed to run the project should be installed.

5. Execute <pre class="code code-shell-cmd">jekyll serve --watch</pre> and navigate a browser to localhost:4000 and the site should be displayed.

6. If any changes are made Jekyll should pick them up and automatically process the files because we passed the "--watch" flag to the Jekyll processor. Refreshing the browser should display the changes.

####Some Credits:

* Design of the Pratt website template by http://blacktie.co
* Font Awesome by Dave Gandy - http://fontawesome.io
* [Michael Starke](https://github.com/mstarke) and [everyone else who contributes to MacPass](https://github.com/mstarke/MacPass/blob/master/README.md#contribtuions)
