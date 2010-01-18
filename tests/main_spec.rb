require 'code/main'

describe Main do
	it 'should initialize correctly' do
		main = Main.new
		main.class.should == Main
	end
	
	it 'should read the config.yml file' do
		main = Main.new
		main.config["rspec_test_var"].should == true
	end
end