module Permissions

	class Permissions

		def initialize(on_model=nil, params)
			@on=on_model
			@params=params
		end

		def self.on(on_model=nil, params)
			Permissions.new(on_model, params)
		end

		def type(type=nil)
			@on.kind_of?(type)
		end

		def itself
			if @params[:id].blank?
				false #some message that we are trying ti check the wrong stuff
			else
				@on==User.find(@params[:id]) if @on.kind_of?(User)
			end
		end

		def admin
			@on[:admin]==true
		end

		def signed_in
			!@on.name.nil?
		end

	end
	# if the condition in "is:"   evaluates to true  it will not continue with the action
	# if the condition in "isnt:" evaluates to false it will not continue with the action
	# if atleast one condition in "is_either:" evaluates to true it will continue with the action
		# if it's not in "is_either" it evaluates to false and it will not continue
		# if "is_either: []" it passes
	# all must pass to pass
	# "bu_is_either" works like "is_either" but if all others fail it still can pass
	def continue_if(on_ent, op={ els: [[:redirect_back]], is: [], isnt: [], or_is: [], but_is_either:[]})
		if !on_ent.blank?
			@pass=true
			p=Permissions.on(on_ent, params)
			#check it is and isnt 
			[Array(op[:is]), Array(op[:isnt])].each_with_index do |j, jin|
				j.each do |i|
					break if !(@pass&&=(jin==0 ? p.send(*i) : !p.send(*i)))
				end
			end
			#check if it is in the list
			if @pass && !op[:is_either].blank?
				@pass&&=Array(op[:is_either]).inject(false) {|ret, i| ret||=p.send(*i)}
			elsif !@pass && !op[:or_is].blank?
				@pass||=Array(op[:or_is]).inject(false) {|ret, i| ret||=p.send(*i)}
			end
			#if none pass do
			op[:els].each {|e| send(*e)} if !@pass
		end
	end

	#this method wanted to make the permission line more sintetic but fails since
	#fileter_accs is not recognized as defined in Usercontroller class
	def filter_accs(on_ent, op={})
		before_action except: op[:except], only: op[:only] do
			continue_if on_ent, op.except(:except, :only) end 
	end

	#before filters
	def soft_redirect
		[[:store_location],[:redirect_to, onmyway_path, notice: ("You need to sign in with correct account to access this page") ]]
	end
	def	simple_back
		[[:redirect_back]]
	end

	#redirects
	def redirect_back(op={}) #duplicated in controllers/application_controller.rb
		#flash[:success]="redirect_to :back, terror: #{op[:terror]}"
		redirect_to :back,op
	rescue ActionController::RedirectBackError
		redirect_to "/", op
	end

end
