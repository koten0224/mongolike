module Settings
  module Common
    def self.included(base)
      base.class_eval do
        attribute :setting_changed, default: 0
        attr_accessor :setting_children
        after_save :save_setting, if: ->{setting_changed?}
        before_destroy :kill_children
      end
    end

    def setting
      @setting ||= FakeHash.new(self)
    end
  
    def save_setting
      setting.save
    end

    def kill_children
      Setting.where(owner: self).destroy_all
    end
  end
end