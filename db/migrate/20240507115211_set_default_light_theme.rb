class SetDefaultLightTheme < ActiveRecord::Migration[7.1]
  def change
    User.find_each do |user|
      user.update(preferences: {'theme'=>'light'})
    end
  end
end
