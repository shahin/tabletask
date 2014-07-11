[![Build Status](https://travis-ci.org/shahin/data_task.svg?branch=master)](https://travis-ci.org/shahin/data_task)
[![Coverage Status](https://img.shields.io/coveralls/shahin/data_task.svg)](https://coveralls.io/r/shahin/data_task?branch=master)

# DataTask

DataTask extends Rake's dependency-based programming language to databases. This gem provides the `data` task, analogous to Rake's built-in `file` task but extended to work with pluggable backends beyond the local filesystem.

Adapters are included for Sqlite3, PostgreSQL, and Greenplum.

## Installation

Add this line to your application's Gemfile:

    gem 'data_task'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install data_task

## Usage

To write your first data task, connect to your database by instantiating an adapter:

```
postgres = Rake::DataTask::Postgres.new(
  'host' => 'localhost', 
  'port' => 5432, 
  'database' => 'example', 
  'username' => 'postgres'
  )
```

Then use this adapter instance as the target for a data task:

```
desc "Load a data file into PostgreSQL for analysis."
data postgres['raw'] => 'raw.txt' do
  # Add loading logic here
end
```

Rake will run this task if and only if (a) the table 'raw' is does not exist yet, or (b) the table 'raw' exists but has a timestamp earlier than the file 'raw.txt'. Since database tables now have timestamps associated with them, they can serve as targets or as dependencies in data tasks.

Here's a runnable example Rakefile:

```
require 'rake'
require 'data_task'

# connect to the database
postgres = Rake::DataTask::Postgres.new(
  'host' => 'localhost', 
  'port' => 5432, 
  'database' => 'example', 
  'username' => 'postgres'
  )

# mark raw.txt as a potential dependency
file 'raw.txt'

# define a loader for the postgres table 'raw', dependent on raw.txt
desc "Load a data file into PostgreSQL for analysis."
data postgres['raw'] => 'raw.txt' do
  postgres.create_table 'raw', nil, '(var1 text)'
  postgres.execute "copy raw from '#{File.join(File.dirname(__FILE__),'raw.txt')}'"
end
```

To run it: 

1. paste the example into a file named 'Rakefile',
2. make sure the PostgreSQL configuration matches your server,
3. in the same directory as your Rakefile, open a terminal and run the commands below:

```
$ echo "v1" > raw.txt
$ rake 'raw'
```

The contents of raw.txt should be in your table 'raw' on PostgreSQL. Running the rake command a second time will result in no operations as long as raw.txt hasn't changed. With big data files, this can be a big time-saver.


## Contributing

1. Fork it ( https://github.com/shahin/data_task/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
