class User < ApplicationRecord
  include Settings::Common
  has_secure_password
  before_validation :auto_fill_password, if: ->{Rails.env.development?}
  
  def auto_fill_password
    if password_digest.nil?
      self.password = '111111'
      self.password_confirmation = '111111'
    end
  end

  def setting_children
    return @setting_children if @setting_children
    @setting_children = []
    settings = Setting.where(owner: self)
    owner_mapping = Hash.new Hash.new
    owner_mapping[self.class][id] = self
    while settings.length > 0
      settings.each do |child|
        child.setting_children = []
        owner_class = child.owner_type.constantize
        owner_id = child.owner_id
        child.owner = owner_mapping[owner_class][owner_id] # mapping object id
        owner_mapping[owner_class][owner_id].setting_children << child
        owner_mapping[child.class][child.id] = child
      end
      settings = Setting.where(owner: settings.pluck(:id))
    end
    @setting_children
  end
end
