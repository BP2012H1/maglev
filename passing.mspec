# -*-ruby-*-
# A config file for running mspec that runs all, and only, the files listed
# in svn/tests/rubytst/passingspecs.conf.  This is used by the rake tasks.
#
# Depends on default.mspec also being read
class MSpecScript
  spec_dir =  File.dirname(__FILE__) + '/spec/rubyspec/'
  conf_file = File.dirname(__FILE__) + '/../svn/tests/rubytst/passingspecs.conf'

  # Read the conf file, removing trailing newlines and filter out comments
  # and empty lines.
  passing_specs = IO.readlines(conf_file).map { |line| "#{spec_dir}#{line.chomp}"}
  passing_specs.reject! { |line| line =~ /#{spec_dir}\s*$|#{spec_dir}\s*#/ }

  # An ordered list of the directories containing specs to run
  set :files, passing_specs

end
