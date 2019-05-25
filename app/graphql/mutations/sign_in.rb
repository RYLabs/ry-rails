class Mutations::SignIn < Mutations::BaseMutation

  argument :email, String, required: true
  argument :password, String, required: true

  type Types::AuthType

  def resolve(email:, password:)
    if user = User.find_for_database_authentication(email: email)
      if user.valid_password?(password)
        user.ensure_authentication_token!
        authentication_token = user.authentication_token
        return OpenStruct.new(authentication_token: authentication_token)
      else
        GraphQL::ExecutionError.new('Incorrect Email/Password')
      end
    else
      GraphQL::ExecutionError.new('User not registered on this application')
    end
  end
end