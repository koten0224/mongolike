class User < ApplicationRecord
  has_secure_password
  after_initialize :auto_fill_password, if: ->{Rails.env.development?}
  
  def auto_fill_password
    self.password = '111111'
    self.password_confirmation = '111111'
  end

  def setting
    HashableSetting.new(self)
  end
end
