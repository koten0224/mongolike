class FakeHash
  attr_reader :owner
  def initialize(owner)
    @owner = owner
    @keys = []
    @children = owner.setting_children ||= []
    @children.each do |child|
      @keys << child.key
      child_set(child.key, child)
      value_set(child.key, child.value)
    end
  end

  def [](key)
    value_get(key)
  end

  def []=(key, value)
    if key.in? @keys
      child = child_get(key)
      child.value = value
    else
      child_set(key, child)
      @keys << key
      child = Setting.new(owner: @owner, key: key, value: value)
      @children << child
    end
    if child.changed?
      value_set(key, child.value)
      owner = @owner
      while owner.present?
        owner.setting_changed += 1
        owner = owner.try(:owner)
      end
    end
  end

  def to_s
    str = '{'
    @keys.each_with_index do |key, index|
      str += key.inspect
      str += ': '
      str += value_get(key).inspect
      if index < @keys.length - 1
        str += ', '
      end
    end
    str += '}'
    str
  end

  def inspect
    to_s
  end

  def save
    @children.each do |child|
      child.save if child.changed?
    end
  end

  # private

  def child_set(key, child)
    instance_variable_set("@child_#{key}", child)
  end

  def child_get(key)
    instance_variable_get("@child_#{key}")
  end

  def value_set(key, value)
    instance_variable_set("@_#{key}", value)
  end

  def value_get(key)
    instance_variable_get("@_#{key}")
  end
end