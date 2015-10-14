#!/usr/bin/env ruby.exe

#no sql output in test environment

#---------------------------------- set color for pry

Pry.color=true
Pry.config.editor=proc { |file, line| "sublime #{file}:#{line}" }

#---------------------------------- connect with database

#ActiveRecord::Schema::check_pending!


#---------------------------------- check and reload model and controller files

#load "reloader.rb"
#reloader_initialize

#---------------------------------- other tools


# load usefull tools
if Rails.env=="test"
	$LOAD_PATH.push("./test")
	load "console_tester.rb" #adds run_test methods to run the test you whant
end

def xtry(to_load=false)
	load "try.rb"
	exec_my(to_load)
end

# The default print
Pry.config.print = proc do |output, value, _pry_|
	_pry_.pager.open do |pager|
		pager.print ""
		Pry::ColorPrinter.pp(value, pager, Pry::Terminal.width! - 1)
	end
end

def nopry_caller
	caller.select {|i| !i.include?("pry")}
end

class Pry
	class Output
		def puts(*objs)
			red_cod="\e[31m"
			clear_cod="\e[0m"
			width=Pry::Terminal.width! - 1
			return print "\n" if objs.empty?

			objs.each do |obj|
				if ary = Array.try_convert(obj)
					puts(*ary)
				else
					print Pry::Helpers::Text.red ("="*15)+">"+"   "+"#{obj.to_s.chomp}\n" 
				end
			end
			nil
		end
	end
end

