require File.expand_path( File.join( File.dirname( __FILE__ ), "spec_helper.rb" ) )

require 'gemology/paths'

describe Gemology::Paths do
  it "can access the root dir of the project" do
    Gemology::Paths.root_dir.should == File.expand_path( File.join( File.dirname( __FILE__ ), ".." ) ) + ::File::SEPARATOR
  end

  it "can access the lib path of the project" do
    Gemology::Paths.lib_path.should == File.expand_path( File.join( File.dirname( __FILE__ ), "..", "lib" ) ) + ::File::SEPARATOR
  end
end

