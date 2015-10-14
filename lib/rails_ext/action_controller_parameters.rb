module ActionController
  class Parameters < ActiveSupport::HashWithIndifferentAccess

    def required_keys(*filters)
      params = self.class.new

      filters.flatten.each do |key_|
        case key_
        when Symbol, String
          if has_key?(key_) && permitted_scalar?(self[key_]) && !self[key_].blank?
            params[key_] = self[key_]
          elsif !has_key?(key_) || self[key_].blank?
              raise ParameterMissing.new(key_)
          end
          permitted_scalar_filter(params, key_)
        when Hash then
          hash_filter(params, key_)
        end
      end

      unpermitted_parameters!(params) if self.class.action_on_unpermitted_parameters

      params.permit!
    end


  end
end