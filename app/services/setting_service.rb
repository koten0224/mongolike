class SettingService
  attr_reader :owner, :children
  def initialize(owner)
    @owner = owner
    @children = Setting.where(owner: owner)
  end
end