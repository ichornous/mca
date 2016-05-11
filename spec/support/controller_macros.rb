module ControllerMacros
  # Login user in a given role
  def with_user(role = :sales, args = [])
    let(:user) { FactoryGirl.create(role, *args) }
    before(:each) do
      sign_in :user, user
    end
  end
end