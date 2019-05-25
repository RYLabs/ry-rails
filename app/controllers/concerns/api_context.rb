module APIContext
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :null_session
    before_action :authenticate_user_by_token!
  end

  protected

    def build_api_context
      {
        current_user: current_user,
        current_ability: current_ability
      }
    end

    def authenticate_user_by_token!
      if (auth_header = request.headers['Authorization']).present?
        if m = auth_header.strip.match(/^Bearer\s+(.*?)$/)
          unless @user = User.find_for_token_authentication(auth_token: m[1])
            render_unauthorized
          end
        else
          render_unauthorized
        end
      end
    end

    def current_user
      @user
    end

    def render_unauthorized
      head :unauthorized
    end

end