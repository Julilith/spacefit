#———————————————————————————————————Token class———————————————————————————————————#
#creates random and hashed tokens
module Token
		class Token
			attr_accessor :value

			def initialize
				@value=SecureRandom.urlsafe_base64
				self
			end

			def digest
				Digest::SHA256.hexdigest(self.value)
			end

			def self.digest(val)
				Digest::SHA256.hexdigest(val.to_s)
			end

			def self.digested
				Digest::SHA256.hexdigest(SecureRandom.urlsafe_base64)
			end

		end
end