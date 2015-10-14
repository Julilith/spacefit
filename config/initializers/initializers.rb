#—————————————————————————————————————————————————————————————————————————————————#
#————                      >>>>>>>>>set omniauth<<<<<<<<<                     ————#
#—————————————————————————————————————————————————————————————————————————————————#

# OmniAuth initializer
Rails.application.config.middleware.use OmniAuth::Builder do
		#Facebook
		provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
		scope: ['email',
			'user_birthday',
			'user_relationship_details',
			'user_education_history',
			'user_work_history'].join(',')
		end

#—————————————————————————————————————————————————————————————————————————————————#
#————                      >>>>>>>>>initialize environment<<<<<<<<<           ————#
#—————————————————————————————————————————————————————————————————————————————————#


# ENV initializer
	#define a YAML file with env info
	env_file = File.join(Rails.root, 'config', 'app_env.yml')
	#read and set the variables
	YAML.load(File.open(env_file)).each do |key, value|
		ENV[key.to_s] = value.to_s
	end if File.exists?(env_file)


#—————————————————————————————————————————————————————————————————————————————————#
#————                      >>>>>>>>>load stuff<<<<<<<<<                       ————#
#—————————————————————————————————————————————————————————————————————————————————#

# Load all libraries
Dir[File.join(Rails.root, "lib", "*.rb")].each {|l_| require l_ }

# Load testers for test env
if Rails.env=="test"
	Dir[File.join(Rails.root, "lib", "assets", "ext", "test", "*.rb")].each {|l| require l }
end

include PrintingMethods
#—————————————————————————————————————————————————————————————————————————————————#
#————                      >>>>>>>>>secure token<<<<<<<<<                     ————#
#—————————————————————————————————————————————————————————————————————————————————#

	#set secure token
	require 'securerandom'
	token_file = Rails.root.join('.secret')
	if File.exist?(token_file)
		# Use the existing token.
		token = File.read(token_file).chomp
	else
		# Generate a new token and store it in token_file.
		token = SecureRandom.hex(64)
		File.write(token_file, token)
	end


#token="alkjsdfihbksd39und,fgf"
Spacefit::Application.config.secret_key_base=token