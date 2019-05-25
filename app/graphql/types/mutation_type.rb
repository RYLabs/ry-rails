module Types
  class MutationType < Types::BaseObject
    field :sign_in, mutation: Mutations::SignIn
  end
end
