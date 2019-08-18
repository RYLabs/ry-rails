# R&Y Labs' Rails Template

## Description

This is the Rails template I used for my Rails 5.2 projects as a freelance developer. Its goal is to allow to begin new rails application easily, with a modern and efficient configuration and with good set of defaults. The project is still very much a work in progress. So do not expect it to be 100% bug free. [Contributions][], ideas and help are really welcome.

This project is inspired by the template developed by Damien Le Thiec. Have a look [here](https://github.com/damienlethiec/modern-rails-template) to compare both.

## Requirements

This template currently works with:

* Ruby 2.6.3
* Rails 5.2.x
* PostgreSQL

## Usage

The super easy way:

```
\curl -sSL https://raw.githubusercontent.com/RYLabs/ry-rails/master/install | bash
```

Or, taking the more scenic route:

```
rails new <name_of_app> \
  --skip-coffee \
  --webpack \
  -d postgresql \
  --skip-test \
  --template=https://raw.githubusercontent.com/RYLabs/ry-rails/master/template.rb
```

To make this the default Rails application template on your system, create a `~/.railsrc` file with these contents:

```
--skip-coffee
--webpack
-d postgresql
--skip-test
--template=https://raw.githubusercontent.com/RYLabs/ry-rails/master/template.rb
```

Then all you would have to run is:

```
rails new <name_of_app>
```

## What does it do?

The template will perform the following steps:

1. Ask for which option you want in this project
1. Generate your application files and directories
1. Add useful gems and good configs
1. Add the optional config specified
1. Commit everything to git

## What is included?

Below is an extract of what this generator does. You can check all the features by following the code, especially in `template.rb` and in the `Gemfile`.

### Standard configuration

* Change the default generators config (`config/initializers/generators.rb`)
* Add [devise](https://github.com/plataformatec/devise) for authentication
* Add [cancancan](https://github.com/CanCanCommunity/cancancan) for authorization
* Add [awesome-print](https://github.com/awesome-print/awesome_print) for easier exploration in the terminal

### Additional options

When you launch a new rails app with the template, a few questions will be asked. Answer 'y' or 'yes' to unable the given option.

* Finally, you can choose to create a Github repository for you project and push it directly.

## How does it work?

This project works by hooking into the standard Rails application templates system, with some caveats. The entry point is the `template.rb` file in the root of this repository.

Normally, Rails only allows a single file to be specified as an application template (i.e. using the `-m <URL>` option). To work around this limitation, the first step this template performs is a `git clone` of the `RYLabs/ry-rails` repository to a local temporary directory.

This temporary directory is then added to the `source_paths` of the Rails generator system, allowing all of its ERb templates and files to be referenced when the application template script is evaluated.

Rails generators are very lightly documented; what you’ll find is that most of the heavy lifting is done by [Thor][]. The most common methods used by this template are Thor’s `copy_file`, `template`, and `gsub_file`.

## Contributing

If you want to contribute, please have a look to the issues in this repository and pick one you are interested in. You can then clone the project and submit a pull request. We also happily welcome new idea and, of course, bug reports.