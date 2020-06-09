# PandaBot

Providing helpers and CLI to complete Assana missing functionality, PandaBot is here to help developers handle most daring Asana repetive tasks.
- Add Uuids to Asana tasks to link git branch and your kanban
- Can create task in Asana in a automated manner, feed him a file and let him work.
- Create/deploy release, moving all tasks from acolumn to another column
- Generate patchnote / reporting

## Installation

Clone the project & install the gem. Its not distributed in a distant repo atm so you'll need to build and install locally.  
Or just fire an irb and require it.
```
git clone git@gitlab.com:jeremira/panda_bot.git
cd panda_bot
gem build panda_bot
gem install panda_bot
```

## Usage

Setup your Asana token a env variable. Then, you can interact with the bot straight in your console.
```
ASANA_TOKEN=abcd1234whatever
please help
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jeremira/panda_bot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PandaBot project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hivency/panda_bot/blob/master/CODE_OF_CONDUCT.md).
