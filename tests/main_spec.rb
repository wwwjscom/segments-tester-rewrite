require 'code/main'
require "spec"

describe Main do
	
	before(:all) do
		@main = Main.new
	end
	
	it 'should initialize correctly' do
		@main.class.should == Main
	end
	
	it 'should read the config.yml file' do
		@main.config["rspec_test_var"].should == true
	end
	
	it 'should be able to call run without error' do
		@main.run
	end
end