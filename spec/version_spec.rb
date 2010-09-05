require File.expand_path( File.join( File.dirname( __FILE__ ), "spec_helper" ) )

describe "Gemology::Version" do
    it "should have a major numbers that is >= 0" do
        Gemology::Version::MAJOR.should >= 0
    end 

    it "should have a minor number that is >= 0" do
        Gemology::Version::MINOR.should >= 0
    end 

    it "should have a tiny number that is >= 0" do
        Gemology::Version::PATCH.should >= 0
    end 

    it "should have an array representation" do
        Gemology::Version.to_a.should have(3).items
    end 

    it "should have a string representation" do
        Gemology::Version.to_s.should match(/\d+\.\d+\.\d+/)
    end 

    it "should have a hash representation" do
      [ :major, :minor, :patch].each do |k|
        Gemology::Version.to_hash[k].should_not be_nil
      end
    end

    it "should be accessable as a constant" do
        Gemology::VERSION.should match(/\d+\.\d+\.\d+/)
    end 
end

